drop table if exists court_reservations;

CREATE TABLE court_reservations (
    res_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    type ENUM('RESERVATION', 'SESSION') NOT NULL ,
    status ENUM('PENDING', 'COMPLETED', 'CANCELLED') NOT NULL ,
    start_date DATETIME NOT NULL ,
    end_date DATETIME NOT NULL ,
    no_people INT NOT NULL ,
    court_id INT,
    equipment BOOLEAN,
    guest_id INT,
    club_id INT,
    FOREIGN KEY (guest_id) REFERENCES Guest(id) on delete  cascade,
    FOREIGN KEY (club_id) REFERENCES TennisClub(id) on delete cascade,
    FOREIGN KEY (court_id) REFERENCES courts(id) on delete cascade
);

ALTER TABLE court_reservations AUTO_INCREMENT=1000000;