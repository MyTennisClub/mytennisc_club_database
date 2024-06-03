drop database if exists mytennis_azure;
create database if not exists mytennis_azure;
use mytennis_azure;

SELECT @@time_zone;
SET @time_zone = '+06:00';


SELECT * FROM CourtReservations;

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
    FOREIGN KEY (referred_by) REFERENCES SimpleUsers(user_id) on delete set null
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
    review_date  DATE,
    review_stars INT,
    review_description TEXT,
    review_likes INT DEFAULT 0,
    review_check BOOL DEFAULT FALSE,
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
    constraint court_club FOREIGN KEY (court_club_id) REFERENCES TennisClub(club_id) on delete cascade on update cascade
);


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
    res_sec_scan INT,
    res_qr_code BLOB,
    constraint res_sec_sca foreign key (res_sec_scan) references SimpleUsers(user_id) on delete set null on update cascade,
    constraint res_club FOREIGN KEY (res_club_id) REFERENCES TennisClub(club_id) ON DELETE CASCADE on update cascade,
    constraint res_court FOREIGN KEY (res_court_id) REFERENCES Courts(court_id) ON DELETE CASCADE on update cascade
);
ALTER TABLE CourtReservations AUTO_INCREMENT=1000000;

drop table if exists Users_Reservations;
create table if not exists Users_Reservations(
    user_id int,
    res_id bigint,
    absence BOOL DEFAULT false,
    PRIMARY KEY (user_id, res_id),
    FOREIGN KEY (user_id) REFERENCES SimpleUsers(user_id) on delete cascade on update cascade,
    FOREIGN KEY (res_id) REFERENCES CourtReservations(res_id) on delete cascade on update cascade
);

drop table if exists Employees_Clubs;
create table if not exists Employees_Clubs(
    employee_id int,
    club_id int,
    employee_type ENUM('MANAGER','COACH','RECEPTIONIST', 'ACCOUNTANT', 'ADMIN', 'SECRETARY') not null,
    cv_file BLOB,
    years_of_experience INT,
    PRIMARY KEY (employee_id, club_id),
    FOREIGN KEY (employee_id) REFERENCES SimpleUsers(user_id) on delete cascade,
    FOREIGN KEY (club_id) REFERENCES TennisClub(club_id) on delete cascade
);

drop table if exists Request;
CREATE TABLE if not exists Request(
    req_id INT AUTO_INCREMENT PRIMARY KEY,
    status ENUM('PENDING', 'APPROVED', 'REJECTED'),
    type ENUM('SIMPLE','KID'),
    to_become ENUM('MEMBER','ATHLETE'),
    req_club_id INT,
    req_user_id INT,
    req_child_id INT,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (req_user_id) REFERENCES SimpleUsers(user_id) on delete cascade on update cascade,
    FOREIGN KEY (req_club_id) REFERENCES TennisClub(club_id) on delete cascade on update cascade
);


DROP PROCEDURE IF EXISTS getAvailableCourtsGuest;
DELIMITER $$
CREATE PROCEDURE getAvailableCourtsGuest(
    IN entered_club_id INT,
    IN entered_date DATE,
    IN entered_duration TIME,
    IN entered_user_id INT,
    IN entered_num_athletes INT ,
    IN with_equipmemt BOOLEAN
)

BEGIN
    DECLARE club_open_public TIME;
    DECLARE club_close_public TIME;
    DECLARE current_slot_start TIME;
    DECLARE current_slot_end TIME;
    DECLARE next_slot_starts TIME DEFAULT '00:30:00';
    DECLARE current_court_id INT;
    DECLARE current_court_title VARCHAR(255);
    DECLARE current_total_price DECIMAL(5,2);
    DECLARE current_court_price DECIMAL(4,2);
    DECLARE current_equipment_price DECIMAL(4,2);
    DECLARE current_court_type VARCHAR(255);
    DECLARE currennt_court_covered boolean;
    DECLARE done INT DEFAULT FALSE;
    DECLARE duration_in_hours DECIMAL(5, 2);

    DECLARE court_cursor_2 CURSOR FOR
    SELECT court_id, court_title,court_price, court_equipment_price, field_type, court_covered
    FROM Courts
    WHERE court_club_id = entered_club_id AND court_athlete_capacity >= entered_num_athletes AND court_status = 'AVAILABLE' AND court_equipment = with_equipmemt and court_public_equipment = true;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT club_start_for_public, club_end_for_public INTO club_open_public, club_close_public
    FROM TennisClub
    WHERE club_id = entered_club_id;


    DROP TABLE IF EXISTS temp_available_slots;

    CREATE TABLE temp_available_slots(
        slot_court_id INT,
        slot_court_title VARCHAR(255),
        slot_start_time TIME,
        slot_end_time TIME,
        slot_total_price DECIMAL(10,2),
        slot_court_price DECIMAL(4,2),
        slot_equipment_price DECIMAL(4,2),
        slot_court_type VARCHAR(255),
        slot_court_covered boolean
    );

    DROP TABLE IF EXISTS club_reservations;
    CREATE TABLE club_reservations (
        old_court_id INT,
        old_res_start TIME,
        old_res_end TIME
    );

    DROP TABLE IF EXISTS members_res;
    CREATE TABLE members_res(
        member_res_start TIME,
        member_res_end TIME
    );

    INSERT INTO members_res(member_res_start, member_res_end)
    SELECT TIME(cr.res_start_date), TIME(cr.res_end_date)
    FROM Users_Reservations ur
    JOIN CourtReservations cr ON ur.res_id = cr.res_id
    WHERE entered_user_id AND DATE(cr.res_start_date) = entered_date AND cr.res_status = 'PENDING'
    GROUP BY cr.res_id, cr.res_start_date, cr.res_end_date;

    INSERT INTO club_reservations (old_court_id, old_res_start, old_res_end)
    SELECT res_court_id, TIME(res_start_date), TIME(res_end_date)
    FROM CourtReservations
    WHERE res_club_id = entered_club_id
      AND DATE(res_start_date) = entered_date
      AND res_status = 'PENDING';

    OPEN court_cursor_2;

    SET duration_in_hours = HOUR(entered_duration) + MINUTE(entered_duration) / 60.0;
    court_loop: LOOP
        FETCH court_cursor_2 INTO current_court_id, current_court_title, current_court_price,current_equipment_price,current_court_type, currennt_court_covered;
        IF done THEN
            LEAVE court_loop;
        END IF;
        SET current_slot_start = club_open_public;
        SET current_slot_end = ADDTIME(current_slot_start, entered_duration);
        while_test: WHILE current_slot_start <= club_close_public DO

            IF current_slot_end < club_close_public THEN
                IF NOT EXISTS (
                    SELECT 1 FROM club_reservations
                    WHERE old_court_id = current_court_id
                      AND (current_slot_start < old_res_end AND current_slot_end > old_res_start)
                ) THEN
                    IF NOT EXISTS (
                        SELECT 1
                        FROM members_res
                        WHERE current_slot_start < member_res_end AND current_slot_end > member_res_start
                    ) THEN
                        if with_equipmemt is not false then
                            set current_total_price = current_court_price  * entered_num_athletes * duration_in_hours + current_equipment_price;
                        else
                            set current_total_price = current_court_price * entered_num_athletes * duration_in_hours;
                        end if;
                            INSERT INTO temp_available_slots (slot_court_id, slot_court_title, slot_start_time, slot_end_time,slot_total_price,slot_court_price,slot_equipment_price,slot_court_type,slot_court_covered)
                            VALUES (current_court_id, current_court_title, current_slot_start, current_slot_end,current_total_price,current_court_price,current_equipment_price,current_court_type,currennt_court_covered);
                    END IF;
                END IF;

                SET current_slot_start = ADDTIME(current_slot_start, next_slot_starts);
                SET current_slot_end = ADDTIME(current_slot_start, entered_duration);
            ELSE
                 IF NOT EXISTS (
                        SELECT 1
                        FROM members_res
                        WHERE current_slot_start < member_res_end AND current_slot_end > member_res_start
                    ) THEN
                        if with_equipmemt is not false then
                            set current_total_price = current_court_price  * entered_num_athletes * duration_in_hours + current_equipment_price;
                        else
                            set current_total_price = current_court_price * entered_num_athletes * duration_in_hours;
                        end if;
                            INSERT INTO temp_available_slots (slot_court_id, slot_court_title, slot_start_time, slot_end_time,slot_total_price,slot_court_price,slot_equipment_price,slot_court_type,slot_court_covered)
                            VALUES (current_court_id, current_court_title, current_slot_start, current_slot_end,current_total_price,current_court_price,current_equipment_price,current_court_type,currennt_court_covered);
                    END IF;
                leave while_test;
            END IF;
        END WHILE while_test;
    END LOOP court_loop;

    CLOSE court_cursor_2;

    SELECT * FROM temp_available_slots;
    DROP TABLE IF EXISTS members_res;
    DROP TABLE club_reservations;
    DROP TABLE temp_available_slots;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS getAvailableCourts;
DELIMITER $$
CREATE PROCEDURE getAvailableCourts(
    IN entered_club_id INT,
    IN entered_date DATE,
    IN entered_duration TIME,
    IN coach_id TEXT,
    IN num_of_athletes INT,
    IN member_ids TEXT
)
BEGIN
    DECLARE club_open TIME;
    DECLARE club_close TIME;
    DECLARE current_slot_start TIME;
    DECLARE current_slot_end TIME;
    DECLARE temp_start TIME;
    DECLARE temp_end TIME;
    DECLARE next_slot_starts TIME DEFAULT '00:30:00';
    DECLARE current_court_id INT;
    DECLARE current_court_title VARCHAR(255);
    DECLARE done INT DEFAULT FALSE;
    DECLARE temp_ids TEXT;

    DECLARE court_cursor_1 CURSOR FOR
    SELECT court_id, court_title
    FROM Courts
    WHERE court_club_id = entered_club_id AND court_athlete_capacity >= num_of_athletes AND court_status = 'AVAILABLE';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT club_start_time, club_end_time INTO club_open, club_close
    FROM TennisClub
    WHERE club_id = entered_club_id;

    if coach_id is null then
        set coach_id = '';
    end if;
    if member_ids is null then
        set member_ids = '';
    end if;
    SET temp_ids = CONCAT(coach_id, ',', member_ids);
    set member_ids = temp_ids;

    DROP TABLE IF EXISTS temp_available_slots;

    CREATE TABLE temp_available_slots(
        slot_court_id INT,
        slot_court_title VARCHAR(255),
        slot_start_time TIME,
        slot_end_time TIME
    );

    DROP TABLE IF EXISTS club_reservations;
    CREATE TABLE club_reservations (
        old_court_id INT,
        old_res_start TIME,
        old_res_end TIME
    );

    DROP TABLE IF EXISTS members_res;
    CREATE TABLE members_res(
        member_res_start TIME,
        member_res_end TIME
    );

    IF member_ids IS NOT NULL THEN
        INSERT INTO members_res(member_res_start, member_res_end)
        SELECT TIME(cr.res_start_date), TIME(cr.res_end_date)
        FROM Users_Reservations ur
        JOIN CourtReservations cr ON ur.res_id = cr.res_id
        WHERE FIND_IN_SET(ur.user_id, member_ids) AND DATE(cr.res_start_date) = entered_date AND cr.res_status = 'PENDING'
        GROUP BY cr.res_id, cr.res_start_date, cr.res_end_date;
    END IF;

    INSERT INTO club_reservations (old_court_id, old_res_start, old_res_end)
    SELECT res_court_id, TIME(res_start_date), TIME(res_end_date)
    FROM CourtReservations
    WHERE res_club_id = entered_club_id
      AND DATE(res_start_date) = entered_date
      AND res_status = 'PENDING';

    OPEN court_cursor_1;

    court_loop: LOOP
        FETCH court_cursor_1 INTO current_court_id, current_court_title;
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
                    IF NOT EXISTS (
                        SELECT 1
                        FROM members_res
                        WHERE current_slot_start < member_res_end AND current_slot_end > member_res_start
                    ) THEN
                            INSERT INTO temp_available_slots (slot_court_id, slot_court_title, slot_start_time, slot_end_time)
                            VALUES (current_court_id, current_court_title, current_slot_start, current_slot_end);
                    END IF;
                END IF;

                SET current_slot_start = ADDTIME(current_slot_start, next_slot_starts);
                SET current_slot_end = ADDTIME(current_slot_start, entered_duration);
            ELSE
                IF NOT EXISTS (
                        SELECT 1
                        FROM members_res
                        WHERE current_slot_start < member_res_end AND current_slot_end > member_res_start
                    ) THEN
                            INSERT INTO temp_available_slots (slot_court_id, slot_court_title, slot_start_time, slot_end_time)
                            VALUES (current_court_id, current_court_title, current_slot_start, current_slot_end);
                    END IF;
                leave while_test;
            END IF;
        END WHILE while_test;
    END LOOP court_loop;

    CLOSE court_cursor_1;

    SELECT * FROM temp_available_slots;

    DROP TABLE IF EXISTS members_res;
    DROP TABLE club_reservations;
    DROP TABLE temp_available_slots;

END $$
DELIMITER ;


call getAvailableCourts(2, '2024-06-27', '01:00:00', '1', 1, null);
# I/flutter ( 8896): clubId 2, date 2024-06-03 16:52:29.559327, formattedDuration  1:30, coachId 1, numAthletes 1, memberIds
select * from CourtReservations;

INSERT INTO CourtReservations
(res_type, res_status, res_start_date, res_end_date, res_no_people, res_court_id, res_equipment, res_club_id, res_sec_scan, res_qr_code)
VALUES
('RESERVATION', 'PENDING', '2024-06-27 18:00:00', '2024-06-03 19:00:00', 4, 1, TRUE, 2, 1, NULL);


set @last_res_id = LAST_INSERT_ID();
delete from CourtReservations where res_id = @last_res_id;

DROP PROCEDURE IF EXISTS simple_apply_to_club;
DELIMITER $$
CREATE PROCEDURE simple_apply_to_club(
    IN p_identification BLOB,
    IN p_doctors_note BLOB,
    IN p_to_become VARCHAR(100),
    IN p_tennis_club_id INT,
    IN p_user_id INT
)
BEGIN
    INSERT INTO Request (
        status,
        type,
        to_become,
        req_club_id,
        req_user_id
    ) VALUES (
        'PENDING',
        'SIMPLE',  -- Assuming type SIMPLE for existing users making the request
        p_to_become,
        p_tennis_club_id,
        p_user_id
    );

    IF p_to_become = 'MEMBER' THEN

        UPDATE SimpleUsers
        SET user_identification_file = p_identification
        WHERE user_id = p_user_id;

    ELSE
        UPDATE SimpleUsers
        SET user_identification_file = p_identification, user_doctors_file = p_doctors_note
        WHERE user_id = p_user_id;

    END IF;

END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS kid_apply_to_club;
DELIMITER $$
CREATE PROCEDURE kid_apply_to_club(
    IN p_identification BLOB,
    IN p_doctors_note BLOB,
    IN p_solemn_decl BLOB,
    IN p_to_become VARCHAR(100),
    IN p_tennis_club_id INT,
    IN p_guardian_id INT,
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_birth_date DATE,
    IN p_email VARCHAR(50),
    IN p_phone VARCHAR(50),
    IN p_address VARCHAR(50)
)

BEGIN

    DECLARE p_kid_user_id INT;
    -- Create a new kid user
    INSERT INTO SimpleUsers (
        user_first_name,
        user_last_name,
        user_birth_date,
        user_email,
        user_phone,
        user_address,
        referred_by,
        user_has_children
    ) VALUES (
        p_first_name,
        p_last_name,
        p_birth_date,
        p_email,
        p_phone,
        p_address,
        p_guardian_id,
        FALSE
    );

    UPDATE SimpleUsers
    SET user_has_children = true
    WHERE user_id = p_guardian_id;

    SET p_kid_user_id = LAST_INSERT_ID();

    # Apply to club (kid)
    INSERT INTO Request (
        status,
        type,
        to_become,
        req_club_id,
        req_user_id,
        req_child_id
    ) VALUES (
        'PENDING',
        'KID',  -- Assuming type SIMPLE for existing users making the request
        p_to_become,
        p_tennis_club_id,
        p_guardian_id,
        p_kid_user_id
    );

    IF p_to_become = 'MEMBER' THEN

        UPDATE SimpleUsers
        SET user_identification_file = p_identification, user_doctors_file = p_doctors_note
        WHERE user_id = p_kid_user_id;

    ELSE

        UPDATE SimpleUsers
        SET user_identification_file = p_identification, user_doctors_file = p_doctors_note, user_solemn_declaration_file= p_solemn_decl
        WHERE user_id = p_kid_user_id;

    END IF;

END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS get_user_info;
DELIMITER $$
CREATE PROCEDURE get_user_info(
    IN p_user_id INT
)
BEGIN
    SELECT
        CONCAT(user_first_name, ' ', user_last_name) AS full_name,
        user_phone,
        user_address,
        user_email,
        user_birth_date
    FROM
        SimpleUsers
    WHERE
        user_id = p_user_id;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS athlete_session_absence;
DELIMITER $$
CREATE PROCEDURE athlete_session_absence(
    IN p_reservation_id INT,
    IN p_user_id  INT
)
BEGIN
    UPDATE Users_Reservations
    SET absence=TRUE
    WHERE user_id=p_user_id AND res_id = p_reservation_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS cancel_reservation;
DELIMITER $$
CREATE PROCEDURE cancel_reservation(
    IN p_res_id BIGINT
)
BEGIN
    UPDATE CourtReservations
    SET res_status = 'CANCELLED'
    WHERE res_id = p_res_id;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS fetch_athletes_from_club;
DELIMITER $$
CREATE PROCEDURE fetch_athletes_from_club(
    IN p_club_id INT
)
BEGIN
    SELECT
        su.user_id,
        su.user_first_name,
        su.user_last_name
    FROM
        SimpleUsers su
    JOIN
        Clubs_Users cu ON su.user_id = cu.user_id
    WHERE
        cu.club_id = p_club_id
        AND cu.user_type IN ('ATHLETE');
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS verify_reservation;
DELIMITER $$
CREATE PROCEDURE verify_reservation(
    IN p_secretary_id INT,
    IN p_reservation_id INT
)
BEGIN
    UPDATE CourtReservations
    SET res_status = 'COMPLETED',
    res_sec_scan = p_secretary_id
    WHERE res_id = p_reservation_id;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS add_guest_review;
DELIMITER $$
CREATE PROCEDURE add_guest_review(
    IN p_user_id INT,
    IN p_tennis_club_id INT,
    IN p_review_stars INT,
    IN p_review_text TEXT
)
BEGIN
    -- Declare variables to hold the results
    DECLARE user_exists BOOLEAN DEFAULT FALSE;
    DECLARE review_status BOOLEAN DEFAULT FALSE;

    -- Check if the user exists and fetch the review_check status
    SELECT review_check INTO review_status
    FROM Clubs_Users
    WHERE user_id = p_user_id AND club_id = p_tennis_club_id
    LIMIT 1;

    -- Set user_exists to TRUE if a matching row is found
    IF (SELECT COUNT(*) FROM Clubs_Users WHERE user_id = p_user_id AND club_id = p_tennis_club_id) > 0 THEN
        SET user_exists = TRUE;
    END IF;

    -- If the user exists and review_check is false, update the review data
    IF user_exists AND review_status = FALSE THEN
        UPDATE Clubs_Users
        SET review_stars = p_review_stars,
            review_description = p_review_text,
            review_date = NOW(),
            review_check = TRUE -- Mark the review_check as true after updating
        WHERE user_id = p_user_id AND club_id = p_tennis_club_id;
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS add_like;
DELIMITER $$
CREATE PROCEDURE add_like(
    IN p_user_id INT,
    IN p_tennis_club_id INT
)
BEGIN
    UPDATE Clubs_Users
    SET review_likes = review_likes + 1
    WHERE user_id = p_user_id AND club_id = p_tennis_club_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS load_review_data;
DELIMITER $$
CREATE PROCEDURE load_review_data(
    IN p_tennis_club_id INT
)
BEGIN
    SELECT
        su.user_first_name,
        su.user_id,
        cu.review_description,
        cu.review_likes,
        cu.review_check,
        cu.review_date,
        cu.review_stars
    FROM
        Clubs_Users cu
    JOIN
        SimpleUsers su ON cu.user_id = su.user_id
    WHERE
        cu.club_id = p_tennis_club_id and cu.review_check = true;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS getClubs;
DELIMITER $$
CREATE PROCEDURE getClubs(
    IN entered_covered BOOLEAN,
    IN entered_field_type VARCHAR(255),
    IN has_equipment BOOLEAN
)
BEGIN
    DECLARE sql_query TEXT;

    SET sql_query = 'SELECT
                        TennisClub.club_id,
                        TennisClub.club_name,
                        TennisClub.club_address,
                        TennisClub.club_latitude,
                        TennisClub.club_longitude,
                        TennisClub.club_start_for_public,
                        TennisClub.club_end_for_public
                    FROM
                        TennisClub
                    LEFT JOIN
                        Courts ON TennisClub.club_id = Courts.court_club_id
                    WHERE Courts.court_status = ''AVAILABLE''';

    IF entered_covered IS NOT NULL THEN
        SET sql_query = CONCAT(sql_query, ' AND Courts.court_covered = ', IF(entered_covered, 'TRUE', 'FALSE'));
    END IF;

    IF entered_field_type IS NOT NULL THEN
        SET sql_query = CONCAT(sql_query, ' AND Courts.field_type = ''', entered_field_type, '''');
    END IF;

    IF has_equipment IS NOT NULL THEN
        SET sql_query = CONCAT(sql_query, ' AND Courts.court_equipment = ', IF(has_equipment, 'TRUE', 'FALSE'));
    END IF;

    SET sql_query = CONCAT(sql_query, ' GROUP BY TennisClub.club_id, TennisClub.club_name, TennisClub.club_address, TennisClub.club_latitude, TennisClub.club_longitude, TennisClub.club_start_for_public, TennisClub.club_end_for_public');

    SET @sql_query = sql_query;
    PREPARE stmt FROM @sql_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$
DELIMITER ;


drop procedure if exists GetMaxPeopleCourtByClub;
DELIMITER $$
create procedure GetMaxPeopleCourtByClub(IN p_club_id int)
BEGIN
    -- Declare a local variable to store the max people court value
    DECLARE v_max_people_court INT;

    -- Select the club_max_people_court into the local variable
    SELECT club_max_people_court
    INTO v_max_people_court
    FROM TennisClub
    WHERE club_id = p_club_id;

    -- Return the result
    SELECT v_max_people_court AS max_people_court;
END $$
DELIMITER ;



DROP PROCEDURE IF EXISTS remove_like;
DELIMITER $$

CREATE PROCEDURE remove_like(
    IN p_user_id INT,
    IN p_tennis_club_id INT
)
BEGIN
    UPDATE Clubs_Users
    SET review_likes = review_likes - 1
    WHERE user_id = p_user_id AND club_id = p_tennis_club_id;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS CreatePrivateCoachSession;
DELIMITER $$
CREATE PROCEDURE CreatePrivateCoachSession (
    IN p_club_id INT,
    IN p_court_id INT,
    IN p_res_start_date DATETIME,
    IN p_res_end_date DATETIME,
    IN p_res_no_people INT,
    IN p_coach_id TEXT,
    IN p_member_id TEXT
)
BEGIN
    DECLARE users_list TEXT;
    INSERT INTO CourtReservations (res_type, res_status, res_start_date, res_end_date, res_no_people, res_court_id, res_equipment, res_club_id)
    VALUES ('RESERVATION', 'PENDING', p_res_start_date, p_res_end_date, p_res_no_people,p_court_id, TRUE, p_club_id);

    if P_member_id is not null then
        set users_list =  CONCAT(p_coach_id, ',', p_member_id);
    else
        set users_list = p_coach_id;
    end if;

    SET @last_res_id = LAST_INSERT_ID();

    insert into Users_Reservations(user_id, res_id, absence)
    select user_id, @last_res_id, FALSE from SimpleUsers where find_in_set(user_id, users_list);

    select @last_res_id as res_id;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS BookCourt;
DELIMITER $$
CREATE PROCEDURE BookCourt (
    IN p_club_id INT,
    IN p_court_id INT,
    IN p_res_start_date DATETIME,
    IN p_res_end_date DATETIME,
    IN p_res_no_people INT,
    IN p_member_id INT,
    IN p_with_equipment BOOLEAN,
    IN p_qr_image BLOB
)
BEGIN
    DECLARE users_list TEXT;
    INSERT INTO CourtReservations (res_type, res_status, res_start_date, res_end_date, res_no_people, res_court_id, res_equipment, res_club_id, res_qr_code)
    VALUES ('RESERVATION', 'PENDING', p_res_start_date, p_res_end_date, p_res_no_people,p_court_id, p_with_equipment, p_club_id,p_qr_image);

    SET @last_res_id = LAST_INSERT_ID();

    insert into Users_Reservations(user_id, res_id, absence)
    values (p_member_id, @last_res_id, FALSE);

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS userUpcomingReservations;
DELIMITER $$
CREATE PROCEDURE userUpcomingReservations (
    IN p_user_id INT
)
BEGIN
    SELECT
        cr.res_id,
        cr.res_type,
        cr.res_court_id,
        c.court_title AS court_name,
        cr.res_start_date AS start_time,
        cr.res_end_date AS end_time,
        cr.res_qr_code,
        tc.club_name AS club_name
    FROM
        CourtReservations cr
    INNER JOIN
        Users_Reservations ur ON cr.res_id = ur.res_id
    INNER JOIN
        Courts c ON cr.res_court_id = c.court_id
    INNER JOIN
        TennisClub tc ON cr.res_club_id = tc.club_id
    WHERE
        res_start_date >= DATE_SUB(NOW(), INTERVAL 20 MINUTE)
        AND ur.user_id = p_user_id
        AND cr.res_type = 'RESERVATION'
        AND cr.res_status = 'PENDING'
    ORDER BY
        cr.res_start_date ASC;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS userUpcomingCalendar;
DELIMITER $$
CREATE PROCEDURE userUpcomingCalendar (
    IN p_user_id INT
)
BEGIN
    SELECT
        cr.res_id,
        cr.res_type,
        cr.res_court_id,
        c.court_title AS court_name,
        cr.res_start_date AS start_time,
        cr.res_end_date AS end_time,
        tc.club_name AS club_name,
        ur.absence as absence
    FROM
        CourtReservations cr
    INNER JOIN
        Users_Reservations ur ON cr.res_id = ur.res_id
    INNER JOIN
        Courts c ON cr.res_court_id = c.court_id
    INNER JOIN
        TennisClub tc ON cr.res_club_id = tc.club_id
    WHERE
        DATE(res_start_date) >= DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY)
        AND ur.user_id = p_user_id
    ORDER BY
        cr.res_start_date ASC;
END$$
DELIMITER ;


drop procedure if exists CheckUserClubMembership;
DELIMITER $$
create procedure CheckUserClubMembership(
    IN p_user_id INT,
    IN p_club_id INT)
begin
    DECLARE p_is_member BOOLEAN DEFAULT NULL;

    if exists(
        select 1 from clubs_users where user_id = p_user_id and p_club_id = club_id and  user_type = 'GUEST'
    ) then
        set p_is_member = true;
    else
        set p_is_member = false;
    end if;
    select p_is_member;

end$$
DELIMITER ;

Drop trigger if exists check_availability_before_insert;
DELIMITER $$
CREATE TRIGGER check_availability_before_insert
BEFORE INSERT ON CourtReservations
FOR EACH ROW
BEGIN
    DECLARE overlap_count INT;

    SELECT COUNT(*)
    INTO overlap_count
    FROM CourtReservations
    WHERE res_court_id = NEW.res_court_id
    AND (
        (NEW.res_start_date BETWEEN res_start_date AND res_end_date)
        OR (NEW.res_end_date BETWEEN res_start_date AND res_end_date)
        OR (res_start_date BETWEEN NEW.res_start_date AND NEW.res_end_date)
        OR (res_end_date BETWEEN NEW.res_start_date AND NEW.res_end_date)
    )
    AND res_status != 'CANCELLED';

    IF overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot insert overlapping reservation.';
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS GetCoachPendingReservations;
DELIMITER $$

CREATE PROCEDURE GetCoachPendingReservations (
    IN p_coach_id INT
)
BEGIN
    SELECT
        cr.res_id,
        cr.res_type,
        cr.res_court_id,
        c.court_title AS court_name,
        cr.res_start_date AS start_time,
        cr.res_end_date AS end_time,
        cr.res_qr_code,
        tc.club_name AS club_name
    FROM
        CourtReservations cr
    INNER JOIN
        Users_Reservations ur ON cr.res_id = ur.res_id
    INNER JOIN
        Courts c ON cr.res_court_id = c.court_id
    INNER JOIN
        TennisClub tc ON cr.res_club_id = tc.club_id
    WHERE
        ur.user_id = p_coach_id
        AND cr.res_type = 'RESERVATION'
        AND cr.res_status = 'PENDING'
    ORDER BY
        cr.res_start_date ASC;
END$$

DELIMITER ;


DROP PROCEDURE IF EXISTS GetCoachPendingReservationsAndSessions;
DELIMITER $$
CREATE PROCEDURE GetCoachPendingReservationsAndSessions (
    IN p_coach_id INT
)
BEGIN
    SELECT
        cr.res_id,
        cr.res_type,
        cr.res_court_id,
        c.court_title AS court_name,
        cr.res_start_date AS start_time,
        cr.res_end_date AS end_time,
        tc.club_name AS club_name
    FROM
        CourtReservations cr
    INNER JOIN
        Users_Reservations ur ON cr.res_id = ur.res_id
    INNER JOIN
        Courts c ON cr.res_court_id = c.court_id
    INNER JOIN
        TennisClub tc ON cr.res_club_id = tc.club_id
    WHERE
        ur.user_id = p_coach_id
    ORDER BY
        cr.res_start_date ASC;
END$$
DELIMITER ;

drop procedure if exists CheckUserClubMembership;
DELIMITER $$
create procedure CheckUserClubMembership(
    IN p_user_id INT,
    IN p_club_id INT)
begin
    DECLARE p_is_member BOOLEAN DEFAULT NULL;

    if exists(
        select 1 from clubs_users where user_id = p_user_id and p_club_id = club_id and  user_type = 'GUEST'
    ) then
        set p_is_member = true;
    else
        set p_is_member = false;
    end if;
    select p_is_member;

end$$
DELIMITER ;




-- Insert sample data into SimpleUsers
INSERT INTO SimpleUsers (user_first_name, user_last_name, user_birth_date, user_email, user_phone, user_address, user_identification_file, user_doctors_file, user_solemn_declaration_file, user_has_children, referred_by)
VALUES
('John', 'Doe', '1980-01-01', 'john.doe@example.com', '123-456-7890', '123 Main St', NULL, NULL, NULL, FALSE, NULL),
('Jane', 'Smith', '1985-05-15', 'jane.smith@example.com', '321-654-0987', '456 Oak St', NULL, NULL, NULL, TRUE, NULL),
('Alice', 'Johnson', '1990-02-20', 'alice.johnson@example.com', '555-123-4567', '789 Pine St', NULL, NULL, NULL, FALSE, 1),
('Bob', 'Brown', '1975-11-30', 'bob.brown@example.com', '444-555-6666', '321 Elm St', NULL, NULL, NULL, TRUE, 2),
('Charlie', 'Davis', '1988-07-12', 'charlie.davis@example.com', '666-777-8888', '654 Cedar St', NULL, NULL, NULL, FALSE, 3),
('David', 'Clark', '1982-03-14', 'david.clark@example.com', '987-654-3210', '147 Elm St', NULL, NULL, NULL, FALSE, NULL),
('Emily', 'Evans', '1995-08-25', 'emily.evans@example.com', '876-543-2109', '258 Maple St', NULL, NULL, NULL, FALSE, 1),
('Frank', 'Garcia', '1978-12-05', 'frank.garcia@example.com', '765-432-1098', '369 Birch St', NULL, NULL, NULL, TRUE, NULL),
('Grace', 'Harris', '1987-09-18', 'grace.harris@example.com', '654-321-0987', '741 Cedar St', NULL, NULL, NULL, TRUE, 2),
('Henry', 'Wilson', '1992-06-22', 'henry.wilson@example.com', '543-210-9876', '852 Spruce St', NULL, NULL, NULL, FALSE, 3),
('Irene', 'Martinez', '1985-04-17', 'irene.martinez@example.com', '432-109-8765', '963 Apple St', NULL, NULL, NULL, TRUE, NULL),
('Jake', 'Anderson', '1979-11-29', 'jake.anderson@example.com', '321-098-7654', '852 Orange St', NULL, NULL, NULL, TRUE, NULL),
('Laura', 'White', '1991-03-23', 'laura.white@example.com', '210-987-6543', '741 Peach St', NULL, NULL, NULL, FALSE, 1),
('Mark', 'Moore', '1980-07-21', 'mark.moore@example.com', '109-876-5432', '630 Pear St', NULL, NULL, NULL, FALSE, 2),
('Nina', 'Taylor', '1988-12-15', 'nina.taylor@example.com', '098-765-4321', '521 Banana St', NULL, NULL, NULL, FALSE, 3);

-- Insert sample data into TennisClub
INSERT INTO TennisClub (club_name, club_description, club_address, club_email, club_website, club_latitude, club_longitude, club_start_time, club_end_time, club_start_for_public, club_end_for_public, club_max_people_court)
VALUES
('Greenwood Tennis Club', 'A premier tennis club with top-notch facilities.', '123 Club Rd', 'contact@greenwoodclub.com', 'www.greenwoodclub.com', 40.712776, -74.005974, '10:00:00', '22:00:00', '10:00:00', '21:00:00', 20),
('Lakeside Tennis Club', 'Beautiful lakeside courts with professional coaching.', '456 Lake Rd', 'info@lakesideclub.com', 'www.lakesideclub.com', 34.052235, -118.243683, '11:30:00', '21:30:00', '10:00:00', '20:30:00', 15),
('Patras Tennis Club', 'The premier tennis club in Patras.', '1 Agiou Nikolaou St, Patras', 'info@patrastennis.com', 'www.patrastennis.com', 38.246639, 21.734573, '10:00:00', '23:00:00', '10:00:00', '22:00:00', 25),
('Achaia Tennis Club', 'Top-notch facilities and coaching in Patras.', '2 Korinthou St, Patras', 'contact@achaiatennis.com', 'www.achaiatennis.com', 38.245552, 21.737682, '10:00:00', '22:00:00', '10:00:00', '21:00:00', 18),
('Rio Tennis Club', 'Family-friendly tennis club in Rio, Patras.', '3 Akti Dymaion St, Patras', 'support@riotennis.com', 'www.riotennis.com', 38.310400, 21.783200, '10:30:00', '21:30:00', '10:00:00', '20:30:00', 20);

-- Insert sample data into ClubsPhone
INSERT INTO ClubsPhone (club_phone, club_id)
VALUES
('123-111-2222', 1),
('123-333-4444', 1),
('456-555-6666', 2),
('456-777-8888', 2),
('2610-123-456', 3),
('2610-234-567', 3),
('2610-345-678', 4),
('2610-456-789', 4),
('2610-567-890', 5),
('2610-678-901', 5);

-- Insert sample data into Clubs_Users
INSERT INTO Clubs_Users (club_id, user_id, user_type, review_date, review_stars, review_description, review_likes, review_check)
VALUES
(1, 1, 'MEMBER', '2023-01-01', 5, 'Great club with excellent facilities!', 10, TRUE),
(1, 2, 'ATHLETE', '2023-02-15', 4, 'Good coaching and friendly staff.', 5, TRUE),
(1, 3, 'MEMBER', '2023-03-10', 4, 'Nice location but a bit crowded.', 3, TRUE),
(1, 4, 'MEMBER', '2023-04-20', 5, 'Love playing here every weekend.', 8, TRUE),
(1, 5, 'ATHLETE', '2023-05-05', 4, 'Well-maintained courts.', 2, TRUE),
(1, 6, 'MEMBER', '2023-06-01', 5, 'Amazing club with great amenities!', 12, TRUE),
(1, 7, 'ATHLETE', '2023-07-10', 4, 'Enjoy the facilities here.', 6, TRUE),
(1, 8, 'MEMBER', '2023-08-15', 5, 'Best club in town.', 9, TRUE),
(1, 9, 'ATHLETE', '2023-09-25', 4, 'Fantastic coaches!', 5, TRUE),
(1, 10, 'MEMBER', '2023-10-30', 5, 'Great place to play tennis.', 7, TRUE),
(2, 11, 'MEMBER', '2023-01-01', 4, 'Nice club with good facilities.', 5, TRUE),
(2, 12, 'ATHLETE', '2023-02-15', 3, 'Good but can be crowded.', 3, TRUE),
(2, 13, 'MEMBER', '2023-03-10', 5, 'Love the environment here.', 8, TRUE),
(2, 14, 'MEMBER', '2023-04-20', 4, 'Friendly staff and members.', 6, TRUE),
(2, 15, 'ATHLETE', '2023-05-05', 4, 'Great place to train.', 4, TRUE),
(3, 1, 'MEMBER', '2023-01-15', 5, 'Excellent club in Patras!', 12, TRUE),
(3, 2, 'ATHLETE', '2023-02-25', 4, 'Great coaching staff.', 7, TRUE),
(3, 3, 'GUEST', '2023-03-30', 3, 'Good facilities but crowded.', 4, TRUE),
(3, 4, 'MEMBER', '2023-04-10', 5, 'Highly recommend this club.', 9, TRUE),
(3, 5, 'ATHLETE', '2023-05-20', 4, 'Enjoy playing here regularly.', 6, TRUE),
(3, 6, 'MEMBER', '2023-06-01', 5, 'Best club in Patras.', 8, TRUE),
(3, 7, 'ATHLETE', '2023-07-10', 4, 'Good facilities.', 5, TRUE),
(3, 8, 'MEMBER', '2023-08-15', 5, 'Friendly and professional.', 7, TRUE),
(3, 9, 'ATHLETE', '2023-09-25', 4, 'Nice place to train.', 6, TRUE),
(3, 10, 'MEMBER', '2023-10-30', 5, 'Fantastic club!', 10, TRUE),
(4, 11, 'MEMBER', '2023-01-01', 5, 'Top-notch facilities.', 9, TRUE),
(4, 12, 'ATHLETE', '2023-02-15', 4, 'Professional staff.', 5, TRUE),
(4, 13, 'MEMBER', '2023-03-10', 5, 'Great community.', 7, TRUE),
(4, 14, 'MEMBER', '2023-04-20', 5, 'Love playing here.', 8, TRUE),
(4, 15, 'ATHLETE', '2023-05-05', 4, 'Excellent coaching.', 4, TRUE),
(4, 1, 'MEMBER', '2023-06-01', 5, 'Great club atmosphere.', 6, TRUE),
(4, 2, 'ATHLETE', '2023-07-10', 4, 'Good training facilities.', 5, TRUE),
(4, 3, 'GUEST', '2023-08-15', 3, 'Nice but crowded.', 4, TRUE),
(4, 4, 'MEMBER', '2023-09-25', 5, 'Highly recommend.', 7, TRUE),
(4, 5, 'ATHLETE', '2023-10-30', 4, 'Great place to play.', 5, TRUE),
(5, 6, 'MEMBER', '2023-01-01', 5, 'Best club for families.', 10, TRUE),
(5, 7, 'ATHLETE', '2023-02-15', 4, 'Enjoy the facilities.', 6, TRUE),
(5, 8, 'MEMBER', '2023-03-10', 5, 'Friendly staff.', 7, TRUE),
(5, 9, 'ATHLETE', '2023-04-20', 4, 'Good training environment.', 5, TRUE),
(5, 10, 'MEMBER', '2023-05-05', 5, 'Excellent club!', 8, TRUE);



-- Insert sample data into Employees_Clubs
INSERT INTO Employees_Clubs (employee_id, club_id, employee_type, cv_file, years_of_experience)
VALUES
(1, 1, 'MANAGER', NULL, 10),
(2, 2, 'COACH', NULL, 5),
(3, 1, 'RECEPTIONIST', NULL, 3),
(4, 2, 'ACCOUNTANT', NULL, 7),
(5, 3, 'MANAGER', NULL, 12),
(6, 4, 'COACH', NULL, 6),
(7, 5, 'RECEPTIONIST', NULL, 4),
(8, 3, 'ACCOUNTANT', NULL, 8),
(9, 4, 'SECRETARY', NULL, 5),
(10, 5, 'ADMIN', NULL, 9);


INSERT INTO Request (status, type, to_become, req_club_id, req_user_id, req_child_id)
VALUES
('PENDING', 'SIMPLE', 'MEMBER', 1, 1, NULL),
('APPROVED', 'KID', 'ATHLETE', 2, 2, 3),
('REJECTED', 'SIMPLE', 'MEMBER', 1, 3, NULL),
('PENDING', 'KID', 'ATHLETE', 2, 4, 5),
('PENDING', 'SIMPLE', 'MEMBER', 3, 1, NULL),
('APPROVED', 'KID', 'ATHLETE', 4, 2, 4),
('REJECTED', 'SIMPLE', 'MEMBER', 5, 3, NULL),
('PENDING', 'KID', 'ATHLETE', 3, 4, 5),
('PENDING', 'SIMPLE', 'MEMBER', 4, 6, NULL),
('APPROVED', 'KID', 'ATHLETE', 5, 7, 8),
('REJECTED', 'SIMPLE', 'MEMBER', 3, 9, NULL),
('PENDING', 'KID', 'ATHLETE', 2, 10, 11),
('PENDING', 'SIMPLE', 'MEMBER', 1, 12, NULL),
('APPROVED', 'KID', 'ATHLETE', 2, 13, 14),
('REJECTED', 'SIMPLE', 'MEMBER', 3, 15, NULL);


INSERT INTO Courts (court_title, field_type, court_status, court_covered, court_athlete_capacity, court_only_for_members, court_equipment, court_equipment_price, court_public_equipment, court_price, court_club_id)
VALUES
-- Courts for club_id 1
('Court 1', 'CLAY', 'AVAILABLE', TRUE, 4, FALSE, TRUE, 5.00, TRUE, 25.00, 1),
('Court 2', 'GRASS', 'MAINTENANCE', FALSE, 2, TRUE, FALSE, 0.00, TRUE, 15.00, 1),
('Court 3', 'HARD', 'AVAILABLE', FALSE, 6, FALSE, TRUE, 7.50, TRUE, 30.00, 1),
('Court 4', 'CARPET', 'AVAILABLE', TRUE, 4, TRUE, TRUE, 6.00, FALSE, 22.50, 1),
('Court 5', 'CLAY', 'AVAILABLE', TRUE, 4, FALSE, TRUE, 6.00, TRUE, 27.50, 1),
('Court 6', 'GRASS', 'MAINTENANCE', FALSE, 3, TRUE, FALSE, 0.00, TRUE, 17.50, 1),
('Court 7', 'HARD', 'AVAILABLE', FALSE, 6, FALSE, TRUE, 9.00, TRUE, 32.50, 1),
('Court 8', 'CARPET', 'AVAILABLE', TRUE, 5, TRUE, TRUE, 7.00, FALSE, 25.00, 1),
('Court 9', 'CLAY', 'AVAILABLE', TRUE, 4, FALSE, TRUE, 7.50, TRUE, 30.00, 1),
('Court 10', 'GRASS', 'AVAILABLE', FALSE, 2, TRUE, FALSE, 0.00, TRUE, 20.00, 1),

-- Courts for club_id 2
('Court 11', 'CLAY', 'AVAILABLE', TRUE, 4, FALSE, TRUE, 5.00, TRUE, 25.00, 2),
('Court 12', 'GRASS', 'MAINTENANCE', FALSE, 2, TRUE, FALSE, 0.00, TRUE, 15.00, 2),
('Court 13', 'HARD', 'AVAILABLE', FALSE, 6, FALSE, TRUE, 7.50, TRUE, 30.00, 2),
('Court 14', 'CARPET', 'AVAILABLE', TRUE, 4, TRUE, TRUE, 6.00, FALSE, 22.50, 2),
('Court 15', 'CLAY', 'AVAILABLE', TRUE, 4, FALSE, TRUE, 6.00, TRUE, 27.50, 2),
('Court 16', 'GRASS', 'MAINTENANCE', FALSE, 3, TRUE, FALSE, 0.00, TRUE, 17.50, 2),
('Court 17', 'HARD', 'AVAILABLE', FALSE, 6, FALSE, TRUE, 9.00, TRUE, 32.50, 2),
('Court 18', 'CARPET', 'AVAILABLE', TRUE, 5, TRUE, TRUE, 7.00, FALSE, 25.00, 2),
('Court 19', 'CLAY', 'AVAILABLE', TRUE, 4, FALSE, TRUE, 7.50, TRUE, 30.00, 2),
('Court 20', 'GRASS', 'AVAILABLE', FALSE, 2, TRUE, FALSE, 0.00, TRUE, 20.00, 2),

-- Courts for club_id 3
('Court 21', 'CLAY', 'AVAILABLE', TRUE, 4, FALSE, TRUE, 5.00, TRUE, 25.00, 3),
('Court 22', 'GRASS', 'MAINTENANCE', FALSE, 2, TRUE, FALSE, 0.00, TRUE, 15.00, 3),
('Court 23', 'HARD', 'AVAILABLE', FALSE, 6, FALSE, TRUE, 7.50, TRUE, 30.00, 3),
('Court 24', 'CARPET', 'AVAILABLE', TRUE, 4, TRUE, TRUE, 6.00, FALSE, 22.50, 3),
('Court 25', 'CLAY', 'AVAILABLE', TRUE, 4, FALSE, TRUE, 6.00, TRUE, 27.50, 3),
('Court 26', 'GRASS', 'MAINTENANCE', FALSE, 3, TRUE, FALSE, 0.00, TRUE, 17.50, 3),
('Court 27', 'HARD', 'AVAILABLE', FALSE, 6, FALSE, TRUE, 9.00, TRUE, 32.50, 3),
('Court 28', 'CARPET', 'AVAILABLE', TRUE, 5, TRUE, TRUE, 7.00, FALSE, 25.00, 3),
('Court 29', 'CLAY', 'AVAILABLE', TRUE, 4, FALSE, TRUE, 7.50, TRUE, 30.00, 3),
('Court 30', 'GRASS', 'AVAILABLE', FALSE, 2, TRUE, FALSE, 0.00, TRUE, 20.00, 3);



INSERT INTO CourtReservations (res_type, res_status, res_start_date, res_end_date, res_no_people, res_court_id, res_equipment, res_club_id, res_sec_scan, res_qr_code)
VALUES
-- Additional reservations for club_id 1
('RESERVATION', 'PENDING', '2024-06-03 10:00:00', '2024-06-03 11:00:00', 4, 1, TRUE, 1, 1, NULL),
('SESSION', 'PENDING', '2024-06-03 11:30:00', '2024-06-03 12:30:00', 4, 2, TRUE, 1, 2, NULL),
('RESERVATION', 'PENDING', '2024-06-03 13:00:00', '2024-06-03 14:00:00', 4, 3, TRUE, 1, 3, NULL),
('SESSION', 'PENDING', '2024-06-03 14:30:00', '2024-06-03 15:30:00', 4, 4, TRUE, 1, 4, NULL),

-- Additional reservations for club_id 2
('RESERVATION', 'PENDING', '2024-06-04 10:00:00', '2024-06-04 11:00:00', 4, 5, TRUE, 2, 5, NULL),
('SESSION', 'PENDING', '2024-06-04 11:30:00', '2024-06-04 12:30:00', 4, 6, TRUE, 2, 6, NULL),
('RESERVATION', 'PENDING', '2024-06-04 13:00:00', '2024-06-04 14:00:00', 4, 7, TRUE, 2, 7, NULL),
('SESSION', 'PENDING', '2024-06-04 14:30:00', '2024-06-04 15:30:00', 4, 8, TRUE, 2, 8, NULL),

-- Additional reservations for club_id 3
('RESERVATION', 'PENDING', '2024-06-05 10:00:00', '2024-06-05 11:00:00', 4, 9, TRUE, 3, 8, NULL),
('SESSION', 'PENDING', '2024-06-05 11:30:00', '2024-06-05 12:30:00', 4, 10, TRUE, 3, 9, NULL),
('RESERVATION', 'PENDING', '2024-06-05 13:00:00', '2024-06-05 14:00:00', 4, 1, TRUE, 3, 1, NULL),
('SESSION', 'PENDING', '2024-06-05 14:30:00', '2024-06-05 15:30:00', 4, 2, TRUE, 3, 2, NULL),

-- Additional reservations for club_id 4
('RESERVATION', 'PENDING', '2024-06-06 10:00:00', '2024-06-06 11:00:00', 4, 3, TRUE, 4, 3, NULL),
('SESSION', 'PENDING', '2024-06-06 11:30:00', '2024-06-06 12:30:00', 4, 4, TRUE, 4, 4, NULL),
('RESERVATION', 'PENDING', '2024-06-06 13:00:00', '2024-06-06 14:00:00', 4, 5, TRUE, 4, 5, NULL),
('SESSION', 'PENDING', '2024-06-06 14:30:00', '2024-06-06 15:30:00', 4, 6, TRUE, 4, 6, NULL),

-- Additional reservations for club_id 5
('RESERVATION', 'PENDING', '2024-06-07 10:00:00', '2024-06-07 11:00:00', 4, 7, TRUE, 5, 7, NULL),
('SESSION', 'PENDING', '2024-06-07 11:30:00', '2024-06-07 12:30:00', 4, 8, TRUE, 5, 8, NULL),
('RESERVATION', 'PENDING', '2024-06-07 13:00:00', '2024-06-07 14:00:00', 4, 9, TRUE, 5, 9, NULL),
('SESSION', 'PENDING', '2024-06-07 14:30:00', '2024-06-07 15:30:00', 4, 10, TRUE, 5, 10, NULL);


INSERT INTO Users_Reservations (user_id, res_id, absence)
VALUES
-- Assigning users to club_id 1 reservations
(1, 1000000, FALSE),
(2, 1000001, FALSE),
(3, 1000002, FALSE),
(4, 1000003, FALSE),

-- Assigning users to club_id 2 reservations
(5, 1000004, FALSE),
(6, 1000005, FALSE),
(7, 1000006, FALSE),
(8, 1000007, FALSE),

-- Assigning users to club_id 3 reservations
(9, 1000008, FALSE),
(10, 1000009, FALSE),
(1, 1000010, FALSE),
(2, 1000011, FALSE),

-- Assigning users to club_id 4 reservations
(3, 1000012, FALSE),
(4, 1000013, FALSE),
(5, 1000014, FALSE),
(6, 1000015, FALSE),

-- Assigning users to club_id 5 reservations
(7, 1000016, FALSE),
(8, 1000017, FALSE),
(9, 1000018, FALSE),
(10, 1000019, FALSE);
