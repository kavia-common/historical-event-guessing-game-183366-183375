-- Historical Event Trivia Game - PostgreSQL schema initialization

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create events table
CREATE TABLE IF NOT EXISTS public.events (
    id SERIAL PRIMARY KEY,
    month INT NOT NULL CHECK (month BETWEEN 1 AND 12),
    day INT NOT NULL CHECK (day BETWEEN 1 AND 31),
    title TEXT NOT NULL,
    description TEXT,
    year INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index to support lookups by month/day
CREATE INDEX IF NOT EXISTS idx_events_month_day ON public.events (month, day);

-- Create clues table
CREATE TABLE IF NOT EXISTS public.clues (
    id SERIAL PRIMARY KEY,
    event_id INT NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
    order_index INT NOT NULL CHECK (order_index >= 1),
    text TEXT NOT NULL
);

-- Index to support efficient retrieval of clues in order for an event
CREATE INDEX IF NOT EXISTS idx_clues_event_order ON public.clues (event_id, order_index);

-- Create game_sessions table
-- Prefer pgcrypto's gen_random_uuid(); fallback to uuid-ossp if needed
CREATE TABLE IF NOT EXISTS public.game_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id INT NOT NULL REFERENCES public.events(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    attempts_used INT NOT NULL DEFAULT 0,
    clues_revealed INT NOT NULL DEFAULT 1,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    is_success BOOLEAN NOT NULL DEFAULT FALSE
);

-- Index for querying sessions by event
CREATE INDEX IF NOT EXISTS idx_game_sessions_event ON public.game_sessions (event_id);
