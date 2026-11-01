-- CourtConnect - Deliverable 3
-- 02_insert_data.sql
-- Sample data for testing the CourtConnect database

INSERT INTO users (full_name, email, password_hash, role) VALUES
('Alex Carter', 'alex@courtconnect.test', 'demo_hash_1', 'PLAYER'),
('Jordan Lee', 'jordan@courtconnect.test', 'demo_hash_2', 'PLAYER'),
('Taylor Morgan', 'taylor@courtconnect.test', 'demo_hash_3', 'PLAYER'),
('Morgan Smith', 'manager@courtconnect.test', 'demo_hash_4', 'FACILITY_MANAGER'),
('CourtConnect Admin', 'admin@courtconnect.test', 'demo_hash_5', 'ADMIN');

INSERT INTO sports (sport_name) VALUES
('Basketball'),
('Tennis'),
('Soccer'),
('Pickleball');

INSERT INTO player_profiles (user_id, skill_level, bio) VALUES
(1, 'INTERMEDIATE', 'Enjoys basketball and weekend games.'),
(2, 'BEGINNER', 'Looking for tennis and pickleball partners.'),
(3, 'ADVANCED', 'Competitive soccer player.');

INSERT INTO player_sports (user_id, sport_id) VALUES
(1, 1),
(2, 2),
(2, 4),
(3, 3);

INSERT INTO facilities
(manager_user_id, facility_name, address, city, state, phone) VALUES
(4, 'Campus Sports Center', '100 College Drive', 'Baltimore', 'MD', '410-555-0100'),
(4, 'Riverside Athletic Club', '250 Riverside Road', 'Baltimore', 'MD', '410-555-0110');

INSERT INTO courts
(facility_id, sport_id, court_name, indoor, hourly_rate) VALUES
(1, 1, 'Basketball Court A', TRUE, 35.00),
(1, 2, 'Tennis Court 1', FALSE, 20.00),
(2, 3, 'Soccer Field A', FALSE, 60.00),
(2, 4, 'Pickleball Court 1', TRUE, 18.00);

INSERT INTO court_availability
(court_id, available_date, start_time, end_time, is_available) VALUES
(1, '2026-11-02', '17:00', '18:00', TRUE),
(1, '2026-11-02', '18:00', '19:00', TRUE),
(2, '2026-11-03', '15:00', '16:00', TRUE),
(3, '2026-11-04', '18:00', '20:00', TRUE),
(4, '2026-11-05', '16:00', '17:00', TRUE);

INSERT INTO reservations
(user_id, court_id, reservation_date, start_time, end_time, status, total_price) VALUES
(1, 1, '2026-11-02', '17:00', '18:00', 'CONFIRMED', 35.00),
(2, 2, '2026-11-03', '15:00', '16:00', 'CONFIRMED', 20.00);

INSERT INTO games
(creator_user_id, sport_id, court_id, game_date, start_time, max_players, required_skill_level, status) VALUES
(1, 1, 1, '2026-11-02', '17:00', 10, 'INTERMEDIATE', 'OPEN'),
(2, 4, 4, '2026-11-05', '16:00', 4, 'ANY', 'OPEN');

INSERT INTO game_players (game_id, user_id) VALUES
(1, 1),
(1, 3),
(2, 2);

-- Test queries
-- Show all courts with their facility and sport
SELECT
    c.court_id,
    c.court_name,
    f.facility_name,
    s.sport_name,
    c.indoor,
    c.hourly_rate
FROM courts c
JOIN facilities f ON c.facility_id = f.facility_id
JOIN sports s ON c.sport_id = s.sport_id
ORDER BY c.court_id;

-- Show all reservations
SELECT
    r.reservation_id,
    u.full_name,
    c.court_name,
    r.reservation_date,
    r.start_time,
    r.end_time,
    r.status
FROM reservations r
JOIN users u ON r.user_id = u.user_id
JOIN courts c ON r.court_id = c.court_id
ORDER BY r.reservation_id;

-- Show open games and current players
SELECT
    g.game_id,
    s.sport_name,
    g.game_date,
    g.start_time,
    g.max_players,
    COUNT(gp.user_id) AS current_players
FROM games g
JOIN sports s ON g.sport_id = s.sport_id
LEFT JOIN game_players gp ON g.game_id = gp.game_id
WHERE g.status = 'OPEN'
GROUP BY g.game_id, s.sport_name, g.game_date, g.start_time, g.max_players
ORDER BY g.game_id;
