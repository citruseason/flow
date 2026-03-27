# Blueprint: Realtime Kanban

## Components

- **kanban-server.cjs** -- WebSocket/HTTP server that watches kanban.json and pushes state to connected clients
- **kanban-dashboard.html** -- Self-contained HTML/CSS/JS dashboard file (served via HTTP by kanban-server.cjs) with 3-column board and WebSocket client
- **start-kanban.sh** -- Shell script to launch server in background, store PID, output connection JSON
- **stop-kanban.sh** -- Shell script to gracefully terminate server using PID file

## Connections

```
kanban.json (fs.watch) --> kanban-server.cjs
kanban-server.cjs --HTTP--> kanban-dashboard.html (serves static file)
kanban-server.cjs --WebSocket--> kanban-dashboard.html (pushes KanbanState)
start-kanban.sh --> kanban-server.cjs (spawns process)
stop-kanban.sh --> kanban-server.cjs (kills process via PID)
/implement SKILL.md --> start-kanban.sh (auto-start at begin)
/lint SKILL.md --> stop-kanban.sh (auto-stop on completion)
```

## External Boundaries

- **kanban.json** -- Existing topic kanban file, written by /implement skill, read-only for this system
- **skills/implement/SKILL.md** -- Integration point for auto-start hook (best-effort)
- **skills/lint/SKILL.md** -- Integration point for auto-stop hook (best-effort)
- **skills/meeting/scripts/** -- Host directory for lifecycle scripts (existing infrastructure)
- **server.cjs (Visual Companion)** -- Existing server in same directory; kanban-server.cjs is independent, shares no code or port
