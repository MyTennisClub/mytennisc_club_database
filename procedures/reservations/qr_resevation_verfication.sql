# DROP PROCEDURE IF EXISTS verify_reservation;
#
# DELIMITER $$
#
# CREATE PROCEDURE verify_reservation(
#     IN p_secretary_id INT,
#     IN p_reservation_id INT
# )
# BEGIN
#     UPDATE CourtReservations
#     SET res_status = 'COMPLETED',
#     res_sec_scan = p_secretary_id
#     WHERE res_id = p_reservation_id;
#
#
# END$$
#
# DELIMITER ;


DROP PROCEDURE IF EXISTS verify_reservation;

DELIMITER $$

CREATE PROCEDURE verify_reservation(
    IN p_secretary_id INT,
    IN p_reservation_id INT,
    IN p_user_id INT
)
BEGIN
    DECLARE v_club_id INT;
    DECLARE v_user_exists INT;

    -- Get the club ID from the reservation
    SELECT res_club_id INTO v_club_id
    FROM CourtReservations
    WHERE res_id = p_reservation_id;

    -- Check if the user is already connected with the club
    SELECT COUNT(*) INTO v_user_exists
    FROM Clubs_Users
    WHERE club_id = v_club_id AND user_id = p_user_id;

    -- If the user doesn't exist in connection with the club, add a row
    IF v_user_exists = 0 THEN
        INSERT INTO Clubs_Users (club_id, user_id, user_type)
        VALUES (v_club_id, p_user_id, 'GUEST'); -- Assuming 'GUEST' as the default user type
    END IF;

    -- Update the reservation status and secretary scan
    UPDATE CourtReservations
    SET res_status = 'COMPLETED',
        res_sec_scan = p_secretary_id
    WHERE res_id = p_reservation_id;

END$$

DELIMITER ;

call verify_reservation(1,1000000,1);