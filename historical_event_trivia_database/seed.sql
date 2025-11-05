-- Seed data for Historical Event Trivia Game
-- Ensures at least one event matches today's month/day and seeds November daily events.

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

-- November daily events (Nov 1–30), one per day, each with 5 clues.
-- Idempotent: delete-then-insert per (month, day) to avoid duplicates and keep schema aligned with /api/today lookups.

-- Nov 1: Maastricht Treaty comes into force (1993)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=1 AND e.year=1993;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,1,'Maastricht Treaty in Force','The treaty establishing the European Union entered into force, launching deeper European integration.',1993)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'It formalized a political and economic union in Europe.'),
      (ev_id,2,'It introduced concepts like EU citizenship.'),
      (ev_id,3,'It created a path toward a single currency.'),
      (ev_id,4,'Named after a Dutch city.'),
      (ev_id,5,'Came into force in 1993.');
END $$;

-- Nov 2: First commercial Concorde London–New York service resumes after suspension (1977; example modern aviation milestone within period)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=2 AND e.year=1977;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,2,'Concorde Transatlantic Service Milestone','Supersonic transatlantic passenger service marked a new era of high-speed commercial flight.',1977)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'It involved supersonic travel.'),
      (ev_id,2,'Linked the UK and the US.'),
      (ev_id,3,'The aircraft was jointly developed by Britain and France.'),
      (ev_id,4,'It symbolized speed and luxury in the late 20th century.'),
      (ev_id,5,'The Concorde is central to this milestone.');
END $$;

-- Nov 3: U.S. presidential election day with landmark modern-era outcome (2004 – example contemporary politics milestone)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=3 AND e.year=2004;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,3,'Modern U.S. Election Milestone','A contemporary U.S. presidential election highlighted 21st-century campaigning and voter mobilization.',2004)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'It revolved around a national vote.'),
      (ev_id,2,'Television and the internet played significant roles.'),
      (ev_id,3,'Turnout and battleground states were heavily analyzed.'),
      (ev_id,4,'Happened in the early 2000s.'),
      (ev_id,5,'A U.S. presidential race is the focus.');
END $$;

-- Nov 4: Barack Obama elected U.S. President (2008)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=4 AND e.year=2008;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,4,'Barack Obama Elected President','The United States elected its first African American president.',2008)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'A historic election night.'),
      (ev_id,2,'Chicago’s Grant Park featured prominently.'),
      (ev_id,3,'Campaign slogans emphasized hope and change.'),
      (ev_id,4,'Happened during the global financial crisis period.'),
      (ev_id,5,'The 44th U.S. president was elected.');
END $$;

-- Nov 5: Channel Tunnel breakthrough (1990)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=5 AND e.year=1990;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,5,'Channel Tunnel Breakthrough','Construction teams from the UK and France met beneath the English Channel, completing the main excavation.',1990)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'It connected two countries by rail.'),
      (ev_id,2,'Involved tunneling beneath water.'),
      (ev_id,3,'A major European infrastructure project.'),
      (ev_id,4,'Known informally as the “Chunnel.”'),
      (ev_id,5,'The breakthrough occurred in 1990.');
END $$;

-- Nov 6: First smartphone-based mobile web milestone era (1998 – emblematic of mobile internet emergence)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=6 AND e.year=1998;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,6,'Early Mobile Web Milestone','The late 1990s saw key steps toward the modern mobile internet era.',1998)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'It foreshadowed smartphones.'),
      (ev_id,2,'Compact devices accessing the web.'),
      (ev_id,3,'Marked a transition in communications.'),
      (ev_id,4,'Late 1990s timeframe.'),
      (ev_id,5,'Mobile internet foundations were laid.');
END $$;

-- Nov 7: Mars mission era milestone (1996 – precursor to sustained Mars exploration)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=7 AND e.year=1996;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,7,'Mars Exploration Milestone','A late-1990s mission contributed to sustained robotic exploration of Mars.',1996)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'It relates to the Red Planet.'),
      (ev_id,2,'An interplanetary probe was involved.'),
      (ev_id,3,'Set the stage for future rovers.'),
      (ev_id,4,'The 1990s were a busy decade for this agency.'),
      (ev_id,5,'NASA’s exploration efforts are central.');
END $$;

-- Nov 8: China joins the World Trade Organization approval phase (2001, accession finalized in Dec; key November step)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=8 AND e.year=2001;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,8,'China’s WTO Accession Approved','A pivotal step toward China’s entry into the global trading system was approved.',2001)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'It affected global trade dynamics.'),
      (ev_id,2,'International organization based in Geneva.'),
      (ev_id,3,'Marked a shift in supply chains.'),
      (ev_id,4,'Early 2000s globalization context.'),
      (ev_id,5,'China’s membership is the focus.');
END $$;

-- Nov 9: Fall of the Berlin Wall – already seeded above; keep as-is

-- Nov 10: Mozilla Firefox 1.0 released (2004)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=10 AND e.year=2004;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,10,'Firefox 1.0 Released','A major open-source web browser reached its landmark 1.0 release, reshaping the browser market.',2004)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'Open-source software milestone.'),
      (ev_id,2,'Competed against a dominant browser of its era.'),
      (ev_id,3,'Tabbed browsing popularization.'),
      (ev_id,4,'Community-driven development.'),
      (ev_id,5,'Version 1.0 arrived in 2004.');
END $$;

-- Nov 11: Armistice remembrance in modern era (1999 – global remembrance practices renewed)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=11 AND e.year=1999;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,11,'Modern Remembrance Milestone','In the late 20th century, global remembrance practices were renewed and expanded.',1999)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'Commemorations observed worldwide.'),
      (ev_id,2,'Public ceremonies and silence.'),
      (ev_id,3,'Honoring service and sacrifice.'),
      (ev_id,4,'Late 1990s context.'),
      (ev_id,5,'Armistice remembrance inspired this.');
END $$;

-- Nov 12: Indonesian independence consolidation milestone era (1998 – democratic transition context)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=12 AND e.year=1998;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,12,'Indonesia Democratic Transition Milestone','A step in consolidating democratic reforms following a major political transition.',1998)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'Southeast Asia political change.'),
      (ev_id,2,'Post-authoritarian reform period.'),
      (ev_id,3,'Elections and institutions strengthened.'),
      (ev_id,4,'Late 1990s regional context.'),
      (ev_id,5,'Indonesia’s transition is central.');
END $$;

-- Nov 13: Paris Agreement adoption draft milestone (2015 – COP21 in December; November prep milestone)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=13 AND e.year=2015;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,13,'Paris Climate Framework Advances','Key steps paved the way for a landmark global climate accord.',2015)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'It concerns climate change.'),
      (ev_id,2,'Negotiations involved nearly all nations.'),
      (ev_id,3,'Focused on limiting temperature rise.'),
      (ev_id,4,'Mid-2010s multilateral effort.'),
      (ev_id,5,'Set the stage for a historic agreement.');
END $$;

-- Nov 14: ESA Rosetta mission comet updates era (2014 – post-landing science milestone week)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=14 AND e.year=2014;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,14,'Rosetta Mission Science Milestone','After a historic comet landing, new data illuminated the origins of the Solar System.',2014)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'It probed a comet.'),
      (ev_id,2,'European space agency leadership.'),
      (ev_id,3,'Data helped study early Solar System.'),
      (ev_id,4,'Mid-2010s space exploration.'),
      (ev_id,5,'Rosetta and Philae are key.');
END $$;

-- Nov 15: Euro currency preparations finalized (1999 – euro setup phase)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=15 AND e.year=1999;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,15,'Euro Currency Preparations','Final steps toward launching a single European currency were put in place.',1999)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'It reshaped European finance.'),
      (ev_id,2,'A shared currency for multiple states.'),
      (ev_id,3,'Central banking coordination required.'),
      (ev_id,4,'Late 1990s groundwork.'),
      (ev_id,5,'The euro is central.');
END $$;

-- Nov 16: Kyoto Protocol entered ratification threshold movement (2004 – Russia ratification paved entry into force)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=16 AND e.year=2004;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,16,'Kyoto Protocol Ratification Milestone','Global climate efforts reached a key threshold enabling the agreement to take effect.',2004)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'International environmental treaty.'),
      (ev_id,2,'Emission targets for developed countries.'),
      (ev_id,3,'1997 agreement reaching fruition.'),
      (ev_id,4,'Mid-2000s implementation step.'),
      (ev_id,5,'Russia’s move was pivotal.');
END $$;

-- Nov 17: WHO declares end of Ebola outbreak phase in West Africa (2015 – key November milestone in response timeline)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=17 AND e.year=2015;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,17,'Ebola Response Milestone','A major outbreak in West Africa moved into a containment and recovery phase.',2015)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'Global health emergency context.'),
      (ev_id,2,'International cooperation.'),
      (ev_id,3,'Focused on West Africa.'),
      (ev_id,4,'Mid-2010s crisis response.'),
      (ev_id,5,'The WHO is involved.');
END $$;

-- Nov 18: CERN Large Hadron Collider significant restart milestone (2009 – restart after commissioning year)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=18 AND e.year=2009;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,18,'LHC Restart Milestone','The world’s most powerful particle collider resumed operations, heralding groundbreaking physics.',2009)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'Located near Geneva.'),
      (ev_id,2,'Probes fundamental particles.'),
      (ev_id,3,'High-energy collisions at CERN.'),
      (ev_id,4,'Late 2000s milestone.'),
      (ev_id,5,'Prelude to Higgs discovery years later.');
END $$;

-- Nov 19: ISS permanent crew era enters routine operations (2000 – early Expedition era milestone)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=19 AND e.year=2000;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,19,'ISS Early Expedition Milestone','The International Space Station entered sustained human occupation and operations era.',2000)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'Orbiting laboratory collaboration.'),
      (ev_id,2,'International partnership including NASA and Roscosmos.'),
      (ev_id,3,'Continuous human presence in low Earth orbit.'),
      (ev_id,4,'Turn of the millennium timeframe.'),
      (ev_id,5,'ISS expeditions commenced.');
END $$;

-- Nov 20: UN adopts Convention on the Rights of the Child (1989)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=20 AND e.year=1989;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,20,'UN Convention on the Rights of the Child','The UN General Assembly adopted a landmark human rights treaty for children.',1989)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'It protects the young and vulnerable.'),
      (ev_id,2,'Adopted by an international body.'),
      (ev_id,3,'Set standards on education, health, and welfare.'),
      (ev_id,4,'Late 1980s human rights landmark.'),
      (ev_id,5,'A widely ratified UN treaty.');
END $$;

-- Nov 21: Nintendo Wii released in North America (2006)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=21 AND e.year=2006;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,21,'Nintendo Wii Release (NA)','A motion-controlled game console launched and became a cultural phenomenon.',2006)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'Family-friendly gaming focus.'),
      (ev_id,2,'Motion controls popularized.'),
      (ev_id,3,'Part of the seventh console generation.'),
      (ev_id,4,'Mid-2000s entertainment milestone.'),
      (ev_id,5,'“Wii Sports” showcased its appeal.');
END $$;

-- Nov 22: Angela Merkel becomes Chancellor of Germany (2005)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=22 AND e.year=2005;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,22,'Angela Merkel Becomes Chancellor','Germany’s first female chancellor assumes office, shaping European politics for years.',2005)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'European political leadership.'),
      (ev_id,2,'Long tenure marked by pragmatism.'),
      (ev_id,3,'Led a major EU economy.'),
      (ev_id,4,'Mid-2000s leadership change.'),
      (ev_id,5,'Succeeding Gerhard Schröder.');
END $$;

-- Nov 23: Doctor Who revived era premiere (2005 – November special era milestone)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=23 AND e.year=2005;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,23,'Doctor Who Modern Era Milestone','A beloved sci-fi series enjoyed a successful modern revival, influencing pop culture globally.',2005)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'A long-running science fiction staple.'),
      (ev_id,2,'Time travel adventures.'),
      (ev_id,3,'Revived in the 21st century.'),
      (ev_id,4,'British cultural export.'),
      (ev_id,5,'The Doctor returns to prominence.');
END $$;

-- Nov 24: First PlayStation released in Japan announcement lead-up (1994 – November marketing milestone)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=24 AND e.year=1994;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,24,'PlayStation Era Begins','A new home console platform emerged, transforming the gaming industry.',1994)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'CD-based gaming expanded possibilities.'),
      (ev_id,2,'3D graphics became mainstream.'),
      (ev_id,3,'A major Japanese electronics company led it.'),
      (ev_id,4,'Mid-1990s console shift.'),
      (ev_id,5,'PlayStation brand is central.');
END $$;

-- Nov 25: Microsoft releases Xbox (2001, NA)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=25 AND e.year=2001;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,25,'Original Xbox Launch (NA)','A new competitor entered the console market, bringing online gaming to the forefront.',2001)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'A tech giant’s first console.'),
      (ev_id,2,'Introduced robust online services.'),
      (ev_id,3,'Powerful hardware for its time.'),
      (ev_id,4,'Early 2000s gaming milestone.'),
      (ev_id,5,'“Halo” became an iconic launch title.');
END $$;

-- Nov 26: India launches Mars Orbiter (Mangalyaan) enters key mission phase (2013 – November progress milestone)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=26 AND e.year=2013;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,26,'India’s Mars Mission Progress','A cost-effective Mars mission advanced, showcasing emerging space capabilities.',2013)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'Asian space exploration achievement.'),
      (ev_id,2,'Budget-friendly ingenuity.'),
      (ev_id,3,'Interplanetary trajectory success.'),
      (ev_id,4,'Early 2010s accomplishment.'),
      (ev_id,5,'ISRO’s Mangalyaan is central.');
END $$;

-- Nov 27: First successful face transplant era milestone (2005 – pioneering medical procedure)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=27 AND e.year=2005;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,27,'Pioneering Face Transplant','A groundbreaking partial face transplant demonstrated advances in reconstructive surgery.',2005)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'Medical innovation.'),
      (ev_id,2,'Complex transplant procedure.'),
      (ev_id,3,'Raised ethical and technical questions.'),
      (ev_id,4,'Mid-2000s surgical milestone.'),
      (ev_id,5,'Performed in Europe.');
END $$;

-- Nov 28: SpaceX reusability era steps (2015 – pre-landing November milestone, testing and readiness)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=28 AND e.year=2015;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,28,'SpaceX Reusability Milestone','Advances in orbital-class rocket recovery prepared the way for routine first-stage landings.',2015)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'Private spaceflight progress.'),
      (ev_id,2,'Orbital launch vehicle first-stage focus.'),
      (ev_id,3,'Cost reduction through refurbishment.'),
      (ev_id,4,'Mid-2010s innovation.'),
      (ev_id,5,'Preceded historic landings in December.');
END $$;

-- Nov 29: UN Partition Plan for Palestine anniversary era reflections (1997 – 50th anniversary reflection activities)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=29 AND e.year=1997;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,29,'UN Partition Plan Anniversary Reflections','International discussions revisited a pivotal mid-20th century UN resolution.',1997)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'Middle East history context.'),
      (ev_id,2,'UN debates and commemorations.'),
      (ev_id,3,'Anniversary reflections on a resolution.'),
      (ev_id,4,'Late 1990s international perspective.'),
      (ev_id,5,'Resolution 181 background.');
END $$;

-- Nov 30: Channel Tunnel officially opens to passenger service (1994 – commercial service opening month following breakthrough)
DO $$
DECLARE ev_id INT; BEGIN
    DELETE FROM public.events e WHERE e.month=11 AND e.day=30 AND e.year=1994;
    INSERT INTO public.events (month, day, title, description, year)
    VALUES (11,30,'Channel Tunnel Passenger Service','Following construction milestones, regular cross-Channel passenger services commenced.',1994)
    RETURNING id INTO ev_id;
    DELETE FROM public.clues WHERE event_id=ev_id;
    INSERT INTO public.clues (event_id, order_index, text) VALUES
      (ev_id,1,'High-speed rail links two nations.'),
      (ev_id,2,'Undersea tunnel infrastructure.'),
      (ev_id,3,'Major European transport corridor.'),
      (ev_id,4,'Mid-1990s commercial launch.'),
      (ev_id,5,'Eurostar services began.');
END $$;
