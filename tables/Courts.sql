drop table if exists Guest;

CREATE TABLE if not exists courts(
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    field_type ENUM('CLAY', 'GRASS', 'HARD', 'CARPET') NOT NULL,
    status ENUM('AVAILABLE', 'MAINTENANCE') NOT NULL,
    covered BOOLEAN NOT NULL,
    athlete_capacity INT NOT NULL,
    only_for_members BOOLEAN NOT NULL,
    equipment BOOLEAN NOT NULL,
    equipment_price DECIMAL(10, 2) NOT NULL,
    public_equipment BOOLEAN NOT NULL,
    court_price DECIMAL(10, 2) NOT NULL,
    club_id INT,
    FOREIGN KEY (club_id) REFERENCES TennisClub(id) on delete cascade
);
