DROP TABLE IF EXISTS CourtReservations;
CREATE TABLE IF NOT EXISTS CourtReservations(
    res_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    res_type ENUM('RESERVATION', 'SESSION') NOT NULL,
    res_status ENUM('PENDING', 'COMPLETED', 'CANCELLED') NOT NULL,
    res_start_date DATETIME NOT NULL,
    res_end_date DATETIME NOT NULL,
    res_no_people INT NOT NULL,
    res_court_id INT,
    res_equipment BOOLEAN,
    res_club_id INT,
    res_secreatary_scaned INT,
    res_created_at DATETIME DEFAULT NOW(),
    res_completed_at DATETIME,
    res_cancelled_at DATETIME,
    res_scanded_at DATETIME,
    res_qr_code BLOB,
    CONSTRAINT  res_secretary FOREIGN KEY (res_secreatary_scaned) REFERENCES Employees_Clubs(employee_id),
    constraint res_club FOREIGN KEY (res_club_id) REFERENCES TennisClub(club_id) ON DELETE CASCADE on update cascade,
    constraint res_court FOREIGN KEY (res_court_id) REFERENCES Courts(court_id) ON DELETE CASCADE on update cascade
);
ALTER TABLE CourtReservations AUTO_INCREMENT=1000000;
