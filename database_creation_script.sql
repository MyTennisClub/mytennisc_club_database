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
    IN p_coach_id INT,
    IN p_club_id INT,
    IN p_court_id INT,
    IN p_res_start_date DATETIME,
    IN p_res_end_date DATETIME,
    IN p_res_no_people INT
)
BEGIN
   -- Inserting a new session into CourtReservations
    INSERT INTO CourtReservations (
        res_type, res_status, res_start_date, res_end_date, res_no_people,
        res_court_id, res_equipment, res_club_id, res_sec_scan, res_qr_code
    ) VALUES (
        'RESERVATION', 'PENDING', p_res_start_date, p_res_end_date, p_res_no_people,
        p_court_id, FALSE, p_club_id, NULL, NULL
    );

    -- Fetching the last inserted session id
    SET @last_res_id = LAST_INSERT_ID();

    -- Inserting the coach into the Users_Reservations table
    INSERT INTO Users_Reservations (user_id, res_id, absence)
    VALUES (p_coach_id, @last_res_id, FALSE);
END $$
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
        cr.res_end_date AS end_time
    FROM
        CourtReservations cr
    INNER JOIN
        Users_Reservations ur ON cr.res_id = ur.res_id
    INNER JOIN
        Courts c ON cr.res_court_id = c.court_id
    WHERE
        ur.user_id = p_coach_id
        AND cr.res_status = 'PENDING'
    ORDER BY
        cr.res_start_date ASC;
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
        cr.res_end_date AS end_time
    FROM
        CourtReservations cr
    INNER JOIN
        Users_Reservations ur ON cr.res_id = ur.res_id
    INNER JOIN
        Courts c ON cr.res_court_id = c.court_id
    WHERE
        ur.user_id = p_coach_id
        AND cr.res_type = 'RESERVATION'
        AND cr.res_status = 'PENDING'
    ORDER BY
        cr.res_start_date ASC;
END$$
DELIMITER ;
