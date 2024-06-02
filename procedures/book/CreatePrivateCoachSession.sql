DROP PROCEDURE IF EXISTS CreatePrivateCoachSession;

-- Procedure to create a private session for a coach
DELIMITER //
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
END;
//
DELIMITER ;

CALL CreatePrivateCoachSession(1, 1, 1, '2024-06-15 10:00:00', '2024-06-15 12:00:00', 4);