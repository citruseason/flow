const crypto = require('crypto');
const http = require('http');
const fs = require('fs');
const path = require('path');

// ========== WebSocket Protocol (RFC 6455) ==========

const OPCODES = { TEXT: 0x01, CLOSE: 0x08, PING: 0x09, PONG: 0x0A };
const WS_MAGIC = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';

function computeAcceptKey(clientKey) {
  return crypto.createHash('sha1').update(clientKey + WS_MAGIC).digest('base64');
}

function encodeFrame(opcode, payload) {
  const fin = 0x80;
  const len = payload.length;
  let header;

  if (len < 126) {
    header = Buffer.alloc(2);
    header[0] = fin | opcode;
    header[1] = len;
  } else if (len < 65536) {
    header = Buffer.alloc(4);
    header[0] = fin | opcode;
    header[1] = 126;
    header.writeUInt16BE(len, 2);
  } else {
    header = Buffer.alloc(10);
    header[0] = fin | opcode;
    header[1] = 127;
    header.writeBigUInt64BE(BigInt(len), 2);
  }

  return Buffer.concat([header, payload]);
}

function decodeFrame(buffer) {
  if (buffer.length < 2) return null;

  const secondByte = buffer[1];
  const opcode = buffer[0] & 0x0F;
  const masked = (secondByte & 0x80) !== 0;
  let payloadLen = secondByte & 0x7F;
  let offset = 2;

  if (!masked) throw new Error('Client frames must be masked');

  if (payloadLen === 126) {
    if (buffer.length < 4) return null;
    payloadLen = buffer.readUInt16BE(2);
    offset = 4;
  } else if (payloadLen === 127) {
    if (buffer.length < 10) return null;
    payloadLen = Number(buffer.readBigUInt64BE(2));
    offset = 10;
  }

  const maskOffset = offset;
  const dataOffset = offset + 4;
  const totalLen = dataOffset + payloadLen;
  if (buffer.length < totalLen) return null;

  const mask = buffer.slice(maskOffset, dataOffset);
  const data = Buffer.alloc(payloadLen);
  for (let i = 0; i < payloadLen; i++) {
    data[i] = buffer[dataOffset + i] ^ mask[i % 4];
  }

  return { opcode, payload: data, bytesConsumed: totalLen };
}

// ========== Constants ==========

const HOST = '127.0.0.1';
const IDLE_TIMEOUT_MS = 30 * 60 * 1000; // 30 minutes
const DEBOUNCE_MS = 200;
const DASHBOARD_PATH = path.join(__dirname, 'kanban-dashboard.html');

// ========== CLI Argument Parsing ==========

function parseArgs(argv) {
  const args = { kanban: null, port: 0 };
  for (let i = 2; i < argv.length; i++) {
    if (argv[i] === '--kanban' && i + 1 < argv.length) {
      args.kanban = path.resolve(argv[++i]);
    } else if (argv[i] === '--port' && i + 1 < argv.length) {
      args.port = Number(argv[++i]);
    }
  }
  return args;
}

// ========== Structured Logging ==========

function log(entry) {
  process.stdout.write(JSON.stringify(entry) + '\n');
}

// ========== KanbanState Builder ==========

function buildKanbanState(raw) {
  const topic = raw.topic || '';
  const phase = raw.phase || '';
  const steps = { done: [], in_progress: [], backlog: [] };

  if (raw.steps && typeof raw.steps === 'object') {
    if (Array.isArray(raw.steps.done)) steps.done = raw.steps.done;
    if (Array.isArray(raw.steps.in_progress)) steps.in_progress = raw.steps.in_progress;
    if (Array.isArray(raw.steps.backlog)) steps.backlog = raw.steps.backlog;
  }

  return { type: 'kanban-state', topic, phase, steps };
}

// ========== Server ==========

function startServer() {
  const args = parseArgs(process.argv);
  if (!args.kanban) {
    process.stderr.write('Usage: kanban-server.cjs --kanban <path> [--port <port>]\n');
    process.exit(1);
  }

  const kanbanPath = args.kanban;
  const port = args.port;
  const clients = new Set();
  let cachedState = null;
  let debounceTimer = null;
  let idleTimer = null;
  let watcher = null;
  let server = null;
  const startTime = Date.now();

  // -- Idle timeout management --

  function resetIdleTimer() {
    if (idleTimer) clearTimeout(idleTimer);
    idleTimer = setTimeout(() => {
      log({ type: 'idle-timeout', minutes: 30 });
      shutdown('idle timeout');
    }, IDLE_TIMEOUT_MS);
    idleTimer.unref();
  }

  // -- Read and cache kanban state --

  function readKanbanFile() {
    try {
      if (!fs.existsSync(kanbanPath)) {
        log({ type: 'error', message: 'Kanban file not found', file: kanbanPath });
        return null;
      }
      const content = fs.readFileSync(kanbanPath, 'utf-8');
      const raw = JSON.parse(content);
      return buildKanbanState(raw);
    } catch (err) {
      log({ type: 'error', message: 'Failed to read kanban file', error: err.message });
      return null;
    }
  }

  // -- Broadcast to all connected clients --

  function broadcast(msg) {
    const frame = encodeFrame(OPCODES.TEXT, Buffer.from(JSON.stringify(msg)));
    for (const socket of clients) {
      try {
        socket.write(frame);
      } catch (e) {
        clients.delete(socket);
      }
    }
  }

  // -- HTTP request handler --

  function handleRequest(req, res) {
    if (req.method === 'GET' && req.url === '/') {
      try {
        const html = fs.readFileSync(DASHBOARD_PATH, 'utf-8');
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(html);
      } catch (err) {
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end('Dashboard file not found');
      }
      return;
    }

    if (req.method === 'GET' && req.url === '/health') {
      const uptime = Math.floor((Date.now() - startTime) / 1000);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ status: 'ok', uptime }));
      return;
    }

    res.writeHead(404);
    res.end('Not found');
  }

  // -- WebSocket upgrade handler --

  function handleUpgrade(req, socket) {
    if (req.url !== '/ws') {
      socket.destroy();
      return;
    }

    const key = req.headers['sec-websocket-key'];
    if (!key) {
      socket.destroy();
      return;
    }

    const accept = computeAcceptKey(key);
    socket.write(
      'HTTP/1.1 101 Switching Protocols\r\n' +
      'Upgrade: websocket\r\n' +
      'Connection: Upgrade\r\n' +
      'Sec-WebSocket-Accept: ' + accept + '\r\n\r\n'
    );

    let buffer = Buffer.alloc(0);
    clients.add(socket);
    log({ type: 'client-connected', total: clients.size });

    // Send cached state immediately on connection
    if (cachedState) {
      const frame = encodeFrame(OPCODES.TEXT, Buffer.from(JSON.stringify(cachedState)));
      try {
        socket.write(frame);
      } catch (e) {
        clients.delete(socket);
      }
    }

    socket.on('data', (chunk) => {
      buffer = Buffer.concat([buffer, chunk]);
      while (buffer.length > 0) {
        let result;
        try {
          result = decodeFrame(buffer);
        } catch (e) {
          socket.end(encodeFrame(OPCODES.CLOSE, Buffer.alloc(0)));
          clients.delete(socket);
          log({ type: 'client-disconnected', total: clients.size });
          return;
        }
        if (!result) break;
        buffer = buffer.slice(result.bytesConsumed);

        switch (result.opcode) {
          case OPCODES.TEXT:
            // No client messages expected; ignore
            break;
          case OPCODES.CLOSE:
            socket.end(encodeFrame(OPCODES.CLOSE, Buffer.alloc(0)));
            clients.delete(socket);
            log({ type: 'client-disconnected', total: clients.size });
            return;
          case OPCODES.PING:
            socket.write(encodeFrame(OPCODES.PONG, result.payload));
            break;
          case OPCODES.PONG:
            break;
          default: {
            const closeBuf = Buffer.alloc(2);
            closeBuf.writeUInt16BE(1003);
            socket.end(encodeFrame(OPCODES.CLOSE, closeBuf));
            clients.delete(socket);
            log({ type: 'client-disconnected', total: clients.size });
            return;
          }
        }
      }
    });

    socket.on('close', () => {
      if (clients.delete(socket)) {
        log({ type: 'client-disconnected', total: clients.size });
      }
    });

    socket.on('error', () => {
      if (clients.delete(socket)) {
        log({ type: 'client-disconnected', total: clients.size });
      }
    });
  }

  // -- File watcher with debounce --

  function startWatcher() {
    // Watch the directory containing the kanban file, filtering for the target filename.
    // This handles cases where the file doesn't exist yet or is recreated.
    const watchDir = path.dirname(kanbanPath);
    const watchFilename = path.basename(kanbanPath);

    try {
      watcher = fs.watch(watchDir, (eventType, filename) => {
        if (filename !== watchFilename) return;

        if (debounceTimer) clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => {
          debounceTimer = null;
          log({ type: 'file-changed', file: kanbanPath });

          const state = readKanbanFile();
          if (!state) return; // malformed or missing — skip broadcast

          cachedState = state;
          resetIdleTimer();
          broadcast(cachedState);
          log({ type: 'state-broadcast', clients: clients.size, topic: cachedState.topic });
        }, DEBOUNCE_MS);
      });

      watcher.on('error', (err) => {
        log({ type: 'error', message: 'fs.watch error', error: err.message });
      });
    } catch (err) {
      log({ type: 'error', message: 'Failed to start file watcher', error: err.message });
    }
  }

  // -- Graceful shutdown --

  function shutdown(reason) {
    log({ type: 'server-stopped', reason });

    // Close all WebSocket connections
    for (const socket of clients) {
      try {
        socket.end(encodeFrame(OPCODES.CLOSE, Buffer.alloc(0)));
      } catch (e) {
        // ignore
      }
    }
    clients.clear();

    // Clean up timers
    if (debounceTimer) clearTimeout(debounceTimer);
    if (idleTimer) clearTimeout(idleTimer);

    // Close file watcher
    if (watcher) {
      try { watcher.close(); } catch (e) { /* ignore */ }
    }

    // Close HTTP server
    if (server) {
      server.close(() => process.exit(0));
      // Force exit after 3 seconds if server.close hangs
      setTimeout(() => process.exit(0), 3000).unref();
    } else {
      process.exit(0);
    }
  }

  // -- Signal handlers --

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));

  // -- Initialize --

  // Read initial state
  cachedState = readKanbanFile();

  // Start file watcher
  startWatcher();

  // Start idle timer
  resetIdleTimer();

  // Start HTTP server
  server = http.createServer(handleRequest);
  server.on('upgrade', handleUpgrade);

  server.listen(port, HOST, () => {
    const actualPort = server.address().port;
    log({
      type: 'server-started',
      port: actualPort,
      host: HOST,
      url: 'http://localhost:' + actualPort,
      kanban: kanbanPath
    });
  });
}

// ========== Entry Point ==========

if (require.main === module) {
  startServer();
}

module.exports = { computeAcceptKey, encodeFrame, decodeFrame, OPCODES };
