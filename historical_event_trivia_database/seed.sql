-- Seed data for Historical Event Trivia Game
-- Ensures at least one event matches today's month/day.

-- Helper DO block: ensure at least one "today" event exists
DO $$
DECLARE
    today_month INT := EXTRACT(MONTH FROM NOW())::INT;
    today_day   INT := EXTRACT(DAY FROM NOW())::INT;
    today_event_id INT;
BEGIN
    -- If an event for today doesn't already exist, create one
    IF NOT EXISTS (
        SELECT 1 FROM public.events e WHERE e.month = today_month AND e.day = today_day
    ) THEN
        INSERT INTO public.events (month, day, title, description, year)
        VALUES (
            today_month,
            today_day,
            'A Pivotal Day in History',
            'On this day in history, a notable event changed the course of events.',
            1969
        )
        RETURNING id INTO today_event_id;

        -- Insert 5 clues for the event of today
        INSERT INTO public.clues (event_id, order_index, text) VALUES
            (today_event_id, 1, 'It happened on this calendar date.'),
            (today_event_id, 2, 'The late 1960s set the stage for this moment.'),
            (today_event_id, 3, 'Technological achievement and global attention were involved.'),
            (today_event_id, 4, 'Broadcasts reached millions worldwide.'),
            (today_event_id, 5, 'A “giant leap” often comes to mind when recalling this era.');

    ELSE
        -- If a "today" event already exists, ensure it has at least 5 clues
        SELECT id INTO today_event_id
        FROM public.events
        WHERE month = today_month AND day = today_day
        ORDER BY id
        LIMIT 1;

        IF (SELECT COUNT(*) FROM public.clues WHERE event_id = today_event_id) < 5 THEN
            -- Top up clues to reach 5 clues
            WITH existing AS (
                SELECT COUNT(*) AS cnt FROM public.clues WHERE event_id = today_event_id
            )
            INSERT INTO public.clues (event_id, order_index, text)
            SELECT today_event_id, s.ord, s.t
            FROM (
                VALUES
                    (1, 'It happened on this calendar date.'),
                    (2, 'The late 1960s set the stage for this moment.'),
                    (3, 'Technological achievement and global attention were involved.'),
                    (4, 'Broadcasts reached millions worldwide.'),
                    (5, 'A “giant leap” often comes to mind when recalling this era.')
            ) AS s(ord, t)
            WHERE s.ord NOT IN (SELECT order_index FROM public.clues WHERE event_id = today_event_id)
            ORDER BY s.ord;
        END IF;
    END IF;
END
$$;

-- Insert two additional static events with 5 clues each if not present

-- Event 1: Fall of the Berlin Wall (Nov 9, 1989)
DO $$
DECLARE
    ev_id INT;
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.events WHERE month = 11 AND day = 9 AND year = 1989
    ) THEN
        INSERT INTO public.events (month, day, title, description, year)
        VALUES (11, 9, 'Fall of the Berlin Wall',
                'The barrier separating East and West Berlin was opened, symbolizing the end of the Cold War divide.',
                1989)
        RETURNING id INTO ev_id;

        INSERT INTO public.clues (event_id, order_index, text) VALUES
            (ev_id, 1, 'It took place in Europe.'),
            (ev_id, 2, 'It symbolized the easing of Cold War tensions.'),
            (ev_id, 3, 'A concrete structure had split a city for decades.'),
            (ev_id, 4, 'Crowds gathered as checkpoints were opened.'),
            (ev_id, 5, 'The Wall fell in 1989.');
    END IF;
END
$$;

-- Event 2: Declaration of Independence (July 4, 1776)
DO $$
DECLARE
    ev_id INT;
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.events WHERE month = 7 AND day = 4 AND year = 1776
    ) THEN
        INSERT INTO public.events (month, day, title, description, year)
        VALUES (7, 4, 'United States Declaration of Independence',
                'Thirteen colonies announced their separation, marking the birth of a new nation.',
                1776)
        RETURNING id INTO ev_id;

        INSERT INTO public.clues (event_id, order_index, text) VALUES
            (ev_id, 1, 'A seminal document in North American history.'),
            (ev_id, 2, 'Drafted by a committee including Jefferson.'),
            (ev_id, 3, 'Signed in Philadelphia.'),
            (ev_id, 4, 'Announced a separation from a European power.'),
            (ev_id, 5, 'Its date is celebrated annually with fireworks.');
    END IF;
END
$$;
