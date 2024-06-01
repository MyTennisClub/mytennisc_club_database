drop table if exists SimpleUsers;
CREATE TABLE if not exists SimpleUsers (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    user_first_name VARCHAR(255) not null,
    user_last_name VARCHAR(255) not null,
    user_birth_date DATE not null,
    user_email VARCHAR(100) not null,
    user_phone VARCHAR(50) not null,
    user_address VARCHAR(255) not null,
    user_identification_file BLOB,
    user_doctors_file BLOB,
    user_solemn_declaration_file BLOB,
    user_has_children BOOLEAN not null default false,
    user_acc_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    referred_by INT,
    FOREIGN KEY (referred_by) REFERENCES SimpleUsers(user_id)
);

drop table if exists TennisClub;
CREATE TABLE if not exists TennisClub (
    club_id INT AUTO_INCREMENT PRIMARY KEY,
    club_name VARCHAR(255),
    club_description TEXT,
    club_address VARCHAR(255),
    club_email VARCHAR(255),
    club_website VARCHAR(255),
    club_latitude DECIMAL(9,6) NOT NULL,
    club_longitude DECIMAL(9,6) NOT NULL,
    club_start_time time NOT NULL,
    club_end_time time NOT NULL,
    club_start_for_public time NOT NULL,
    club_end_for_public time NOT NULL,
    club_max_people_court  int not null DEFAULT 0
);

drop table if exists ClubsPhone;
create table if not exists ClubsPhone(
    club_phone varchar(255) primary key not null ,
    club_id int not null ,
    FOREIGN KEY (club_id) REFERENCES TennisClub(club_id) on delete cascade
);

drop table if exists Clubs_Users;
create table if not exists Clubs_Users(
    club_id int,
    user_id int,
    user_type ENUM('GUEST','ATHLETE','MEMBER') not null,
    PRIMARY KEY (club_id, user_id),
    FOREIGN KEY (club_id) REFERENCES TennisClub(club_id) on delete cascade,
    FOREIGN KEY (user_id) REFERENCES SimpleUsers(user_id) on delete cascade
);

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
    FOREIGN KEY (court_club_id) REFERENCES TennisClub(club_id) ON DELETE CASCADE
);


-- Drop and create the CourtReservations table
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
    FOREIGN KEY (res_club_id) REFERENCES TennisClub(club_id) ON DELETE CASCADE,
    FOREIGN KEY (res_court_id) REFERENCES Courts(court_id) ON DELETE CASCADE
);

ALTER TABLE CourtReservations AUTO_INCREMENT=1000000;

drop table if exists Users_Reservations;
create table if not exists Users_Reservations(
    user_id int,
    res_id bigint,
    PRIMARY KEY (user_id, res_id),
    FOREIGN KEY (user_id) REFERENCES SimpleUsers(user_id),
    FOREIGN KEY (res_id) REFERENCES CourtReservations(res_id)
);

drop table if exists Request;
CREATE TABLE if not exists Request(
    req_id INT AUTO_INCREMENT PRIMARY KEY,
    status ENUM('PENDING', 'APPROVED', 'REJECTED'),
    type ENUM('SIMPLE','KID'),
    to_become ENUM('MEMBER','ATHLETE'),
    club_id INT,
    user_id INT,
    child_id INT,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES SimpleUsers(user_id),
    FOREIGN KEY (club_id) REFERENCES TennisClub(club_id)
);

INSERT INTO TennisClub (
    club_name,
    club_description,
    club_address,
    club_email,
    club_website,
    club_latitude,
    club_longitude,
    club_start_time,
    club_end_time,
    club_start_for_public,
    club_end_for_public,
    club_max_people_court
) VALUES (
    'Sample Tennis Club',
    'A sample tennis club for testing purposes.',
    '123 Sample Street, Sample City, SS 12345',
    'contact@sampletennisclub.com',
    'http://www.sampletennisclub.com',
    40.712776,
    -74.005974,
    '08:00:00',
    '23:00:00',
    '08:00:00',
    '22:00:00',
    4
);

-- Insert sample data into the Courts table
INSERT INTO Courts (
    court_title, field_type, court_status, court_covered, court_athlete_capacity, court_only_for_members,
    court_equipment, court_equipment_price, court_public_equipment, court_price, court_club_id
) VALUES
    ('Court 1', 'CLAY', 'AVAILABLE', TRUE, 10, FALSE, TRUE, 5.00, TRUE, 20.00, 1),
    ('Court 2', 'GRASS', 'AVAILABLE', FALSE, 10, TRUE, FALSE, 0.00, FALSE, 15.00, 1),
    ('Court 3', 'HARD', 'MAINTENANCE', TRUE, 10, FALSE, TRUE, 7.50, TRUE, 25.00, 1),
    ('Court 4', 'CARPET', 'AVAILABLE', FALSE, 10, TRUE, FALSE, 0.00, FALSE, 18.00, 1);

-- Insert sample data into the CourtReservations table ensuring no overlaps
INSERT INTO CourtReservations (
    res_type, res_status, res_start_date, res_end_date, res_no_people, res_court_id, res_equipment, res_club_id
) VALUES
    -- Court 1 reservations (non-overlapping)
    ('RESERVATION', 'PENDING', '2024-06-01 08:00:00', '2024-06-01 09:00:00', 8, 1, TRUE, 1),
    ('RESERVATION', 'COMPLETED', '2024-06-01 09:00:00', '2024-06-01 10:00:00', 6, 1, FALSE, 1),
    ('RESERVATION', 'PENDING', '2024-06-01 10:00:00', '2024-06-01 11:00:00', 5, 1, TRUE, 1),
    ('SESSION', 'COMPLETED', '2024-06-01 11:00:00', '2024-06-01 12:00:00', 7, 1, FALSE, 1),
    ('RESERVATION', 'PENDING', '2024-06-01 12:00:00', '2024-06-01 13:00:00', 9, 1, TRUE, 1),

    -- Court 2 reservations (non-overlapping)
    ('RESERVATION', 'PENDING', '2024-06-01 08:00:00', '2024-06-01 09:00:00', 8, 2, TRUE, 1),
    ('RESERVATION', 'COMPLETED', '2024-06-01 09:00:00', '2024-06-01 10:00:00', 6, 2, FALSE, 1),
    ('RESERVATION', 'PENDING', '2024-06-01 10:00:00', '2024-06-01 11:00:00', 5, 2, TRUE, 1),
    ('SESSION', 'COMPLETED', '2024-06-01 11:00:00', '2024-06-01 12:00:00', 7, 2, FALSE, 1),
    ('RESERVATION', 'PENDING', '2024-06-01 12:00:00', '2024-06-01 13:00:00', 9, 2, TRUE, 1),

    -- Court 3 reservations (non-overlapping)
    ('RESERVATION', 'PENDING', '2024-06-01 08:00:00', '2024-06-01 09:00:00', 8, 3, TRUE, 1),
    ('RESERVATION', 'COMPLETED', '2024-06-01 09:00:00', '2024-06-01 10:00:00', 6, 3, FALSE, 1),
    ('RESERVATION', 'PENDING', '2024-06-01 10:00:00', '2024-06-01 11:00:00', 5, 3, TRUE, 1),
    ('SESSION', 'COMPLETED', '2024-06-01 11:00:00', '2024-06-01 12:00:00', 7, 3, FALSE, 1),
    ('RESERVATION', 'PENDING', '2024-06-01 12:00:00', '2024-06-01 13:00:00', 9, 3, TRUE, 1),

    -- Court 4 reservations (non-overlapping)
    ('SESSION', 'PENDING', '2024-06-01 08:00:00', '2024-06-01 09:30:00', 10, 4, TRUE, 1),
    ('RESERVATION', 'COMPLETED', '2024-06-01 09:30:00', '2024-06-01 11:00:00', 4, 4, FALSE, 1),
    ('SESSION', 'PENDING', '2024-06-01 11:00:00', '2024-06-01 12:30:00', 8, 4, TRUE, 1),
    ('RESERVATION', 'COMPLETED', '2024-06-01 12:30:00', '2024-06-01 14:00:00', 6, 4, FALSE, 1),
    ('SESSION', 'PENDING', '2024-06-01 14:00:00', '2024-06-01 15:30:00', 9, 4, TRUE, 1);



INSERT INTO SimpleUsers (user_first_name, user_last_name, user_birth_date, user_email, user_phone, user_address, user_has_children)
VALUES
('John', 'Doe', '1980-01-01', 'john.doe@example.com', '1234567890', '123 Main St', false),
('Jane', 'Doe', '1980-02-02', 'jane.doe@example.com', '0987654321', '456 Main St', true);

INSERT INTO TennisClub (club_name, club_description, club_address, club_email, club_website, club_latitude, club_longitude, club_start_time, club_end_time, club_start_for_public, club_end_for_public, club_max_people_court)
VALUES
('Club 1', 'Description 1', 'Address 1', 'email1@example.com', 'http://www.example1.com', 40.712776, -74.005974, '08:00:00', '23:00:00', '08:00:00', '22:00:00', 4),
('Club 2', 'Description 2', 'Address 2', 'email2@example.com', 'http://www.example2.com', 40.712776, -74.005974, '08:00:00', '23:00:00', '08:00:00', '22:00:00', 4);

INSERT INTO ClubsPhone (club_phone, club_id)
VALUES
('1234567890', 1),
('0987654321', 2);

INSERT INTO Clubs_Users (club_id, user_id, user_type)
VALUES
(1, 1,'GUEST'),
(1, 2,'ATHLETE'),
(2, 1,'GUEST'),
(2, 2,'ATHLETE');
;

INSERT INTO Courts (court_title, field_type, court_status, court_covered, court_athlete_capacity, court_only_for_members, court_equipment, court_equipment_price, court_public_equipment, court_price, court_club_id)
VALUES
('Court 1', 'CLAY', 'AVAILABLE', TRUE, 10, FALSE, TRUE, 5.00, TRUE, 20.00, 1),
('Court 2', 'GRASS', 'AVAILABLE', FALSE, 10, TRUE, FALSE, 0.00, FALSE, 15.00, 1);

INSERT INTO Request (status, type, to_become, club_id, user_id, child_id)
VALUES
('PENDING', 'SIMPLE', 'MEMBER', 1, 1, NULL),
('APPROVED', 'KID', 'ATHLETE', 2, 2, 1);

drop procedure if exists getClubs;
DELIMITER $$
create procedure getClubs()
begin
    SELECT TennisClub.club_id,club_name,club_address,club_latitude,club_longitude,field_type,court_covered,court_equipment
    FROM TennisClub RIGHT JOIN Courts ON TennisClub.club_id = Courts.court_club_id
    WHERE court_only_for_members=0
    and Courts.court_status='AVAILABLE';
end $$
DELIMITER ;


DROP PROCEDURE IF EXISTS getAvailableCourtsCoach;
DELIMITER $$
CREATE PROCEDURE getAvailableCourtsCoach(
    IN entered_club_id INT,
    IN entered_date DATE,
    IN entered_duration TIME,
    IN coach_ID INT,
    IN num_of_athletes INT
)
BEGIN
    DECLARE club_open TIME;
    DECLARE club_close TIME;
    DECLARE current_slot_start TIME;
    DECLARE current_slot_end TIME;
    DECLARE next_slot_starts TIME DEFAULT '00:30:00';
    DECLARE current_court_id INT;
    DECLARE current_court_title VARCHAR(255);
    DECLARE done INT DEFAULT FALSE;

    DECLARE court_cursor CURSOR FOR
    SELECT court_id, court_title
    FROM Courts
    WHERE court_club_id = entered_club_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT club_start_time, club_end_time INTO club_open, club_close
    FROM TennisClub
    WHERE club_id = entered_club_id;

    DROP TEMPORARY TABLE IF EXISTS temp_available_slots;

    CREATE TEMPORARY TABLE temp_available_slots (
        slot_court_id INT,
        slot_court_title VARCHAR(255),
        slot_start_time TIME,
        slot_end_time TIME
    );

    DROP TEMPORARY TABLE IF EXISTS club_reservations;
    CREATE TEMPORARY TABLE club_reservations (
        old_court_id INT,
        old_res_start TIME,
        old_res_end TIME
    );

    INSERT INTO club_reservations (old_court_id, old_res_start, old_res_end)
    SELECT res_court_id, TIME(res_start_date), TIME(res_end_date)
    FROM CourtReservations
    WHERE res_club_id = entered_club_id
      AND DATE(res_start_date) = entered_date
      AND res_status = 'PENDING';

    OPEN court_cursor;

    court_loop: LOOP
        FETCH court_cursor INTO current_court_id, current_court_title;
        IF done THEN
            LEAVE court_loop;
        END IF;

        SET current_slot_start = club_open;
        SET current_slot_end = ADDTIME(current_slot_start, entered_duration);

        while_test: WHILE current_slot_start <= club_close DO
            IF current_slot_end < club_close THEN
                IF NOT EXISTS (
                    SELECT 1 FROM club_reservations
                    WHERE old_court_id = current_court_id
                      AND (current_slot_start < old_res_end AND current_slot_end > old_res_start)
                ) THEN
                    INSERT INTO temp_available_slots (slot_court_id, slot_court_title, slot_start_time, slot_end_time)
                    VALUES (current_court_id, current_court_title, current_slot_start, current_slot_end);
                END IF;

                SET current_slot_start = ADDTIME(current_slot_start, next_slot_starts);
                SET current_slot_end = ADDTIME(current_slot_start, entered_duration);
            ELSE
                 INSERT INTO temp_available_slots (slot_court_id, slot_court_title, slot_start_time, slot_end_time)
                 VALUES (current_court_id, current_court_title, current_slot_start, current_slot_end);
                 leave while_test;
            END IF;
        END WHILE while_test;
    END LOOP;

    CLOSE court_cursor;

    SELECT * FROM temp_available_slots;

    DROP TEMPORARY TABLE IF EXISTS temp_available_slots;
    DROP TEMPORARY TABLE IF EXISTS club_reservations;

END $$
DELIMITER ;

# CALL getAvailableCourtsCoach(1, '2024-06-01', '03:00:00', 12345, 4);





