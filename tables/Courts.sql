DROP TABLE IF EXISTS Courts;
CREATE TABLE IF NOT EXISTS Courts(
    court_id INT AUTO_INCREMENT PRIMARY KEY,
    court_title VARCHAR(255) NOT NULL,
    field_type ENUM('CLAY', 'GRASS', 'HARD', 'CARPET') NOT NULL,
    court_status ENUM('AVAILABLE', 'MAINTENANCE') NOT NULL,
    court_covered BOOLEAN NOT NULL,
    court_athlete_capacity INT NOT NULL,
    court_only_for_members BOOLEAN NOT NULL,
    court_equipment BOOLEAN NOT NULL,
    court_equipment_price DECIMAL(10, 2) NOT NULL,
    court_public_equipment BOOLEAN NOT NULL,
    court_price DECIMAL(10, 2) NOT NULL,
    court_club_id INT,
    constraint court_club FOREIGN KEY (court_club_id) REFERENCES TennisClub(club_id) on delete cascade on update cascade
);
