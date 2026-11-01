-- CourtConnect - Deliverable 3
-- 01_create_tables.sql
-- PostgreSQL 15

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'PLAYER'
        CHECK (role IN ('PLAYER', 'FACILITY_MANAGER', 'ADMIN')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sports (
    sport_id SERIAL PRIMARY KEY,
    sport_name VARCHAR(60) UNIQUE NOT NULL
);

CREATE TABLE player_profiles (
    user_id INT PRIMARY KEY,
    skill_level VARCHAR(20)
        CHECK (skill_level IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED')),
    bio VARCHAR(300),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE player_sports (
    user_id INT NOT NULL,
    sport_id INT NOT NULL,
    PRIMARY KEY (user_id, sport_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id)
        ON DELETE CASCADE
);

CREATE TABLE facilities (
    facility_id SERIAL PRIMARY KEY,
    manager_user_id INT,
    facility_name VARCHAR(120) NOT NULL,
    address VARCHAR(200) NOT NULL,
    city VARCHAR(80) NOT NULL,
    state VARCHAR(30) NOT NULL,
    phone VARCHAR(25),
    FOREIGN KEY (manager_user_id) REFERENCES users(user_id)
        ON DELETE SET NULL
);

CREATE TABLE courts (
    court_id SERIAL PRIMARY KEY,
    facility_id INT NOT NULL,
    sport_id INT NOT NULL,
    court_name VARCHAR(100) NOT NULL,
    indoor BOOLEAN NOT NULL DEFAULT FALSE,
    hourly_rate DECIMAL(8,2) NOT NULL CHECK (hourly_rate >= 0),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (facility_id) REFERENCES facilities(facility_id)
        ON DELETE CASCADE,
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id)
        ON DELETE RESTRICT
);

CREATE TABLE court_availability (
    availability_id SERIAL PRIMARY KEY,
    court_id INT NOT NULL,
    available_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (end_time > start_time),
    FOREIGN KEY (court_id) REFERENCES courts(court_id)
        ON DELETE CASCADE,
    UNIQUE (court_id, available_date, start_time, end_time)
);

CREATE TABLE reservations (
    reservation_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    court_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED'
        CHECK (status IN ('PENDING', 'CONFIRMED', 'CANCELLED')),
    total_price DECIMAL(8,2) CHECK (total_price >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (end_time > start_time),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    FOREIGN KEY (court_id) REFERENCES courts(court_id)
        ON DELETE CASCADE,
    UNIQUE (court_id, reservation_date, start_time, end_time)
);

CREATE TABLE games (
    game_id SERIAL PRIMARY KEY,
    creator_user_id INT NOT NULL,
    sport_id INT NOT NULL,
    court_id INT,
    game_date DATE NOT NULL,
    start_time TIME NOT NULL,
    max_players INT NOT NULL CHECK (max_players >= 2),
    required_skill_level VARCHAR(20)
        CHECK (required_skill_level IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'ANY')),
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN'
        CHECK (status IN ('OPEN', 'FULL', 'CANCELLED', 'COMPLETED')),
    FOREIGN KEY (creator_user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id)
        ON DELETE RESTRICT,
    FOREIGN KEY (court_id) REFERENCES courts(court_id)
        ON DELETE SET NULL
);

CREATE TABLE game_players (
    game_id INT NOT NULL,
    user_id INT NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (game_id, user_id),
    FOREIGN KEY (game_id) REFERENCES games(game_id)
        ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- Helpful indexes for common CourtConnect searches
CREATE INDEX idx_courts_sport ON courts(sport_id);
CREATE INDEX idx_courts_facility ON courts(facility_id);
CREATE INDEX idx_availability_date ON court_availability(available_date);
CREATE INDEX idx_reservations_user ON reservations(user_id);
CREATE INDEX idx_reservations_court_date ON reservations(court_id, reservation_date);
CREATE INDEX idx_games_sport_date ON games(sport_id, game_date);
