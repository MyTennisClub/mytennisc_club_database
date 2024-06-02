#Only for coach book private session

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

            IF current_slot_end <= club_close THEN
                IF NOT EXISTS (
                    SELECT 1
                    FROM club_reservations
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
                LEAVE while_test;
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
