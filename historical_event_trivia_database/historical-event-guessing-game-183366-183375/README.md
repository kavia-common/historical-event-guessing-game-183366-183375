# historical-event-guessing-game-183366-183375

This project implements a Historical Event Trivia Game with a PostgreSQL database, a backend API, and a React frontend.

Database (PostgreSQL) defaults:
- POSTGRES_HOST=localhost
- POSTGRES_PORT=5000
- POSTGRES_DB=myapp
- POSTGRES_USER=appuser
- POSTGRES_PASSWORD=dbuser123
- DATABASE_URL=postgresql://appuser:dbuser123@localhost:5000/myapp

Database quick start:
1) Initialize and start the database:
   - cd historical_event_trivia_database
   - ./startup.sh
2) Connect using:
   - psql -h localhost -U appuser -d myapp -p 5000
   - Or use the saved command in historical_event_trivia_database/db_connection.txt
3) The schema (startup.sql) and seed data (seed.sql) are applied automatically by startup.sh.
   - Tables: events, clues, game_sessions
   - Indexes: events(month, day), clues(event_id, order_index), game_sessions(event_id)
   - Seed ensures one event matches today’s month/day and includes two additional events with five clues each.

DB Viewer (optional):
- A simple database viewer is available under historical_event_trivia_database/db_visualizer.
- To use:
  - source db_visualizer/postgres.env
  - npm start (from within db_visualizer)
  - Visit http://localhost:3000 and select Postgres.
