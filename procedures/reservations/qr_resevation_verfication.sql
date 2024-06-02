DROP PROCEDURE IF EXISTS verify_reservation;

DELIMITER $$

CREATE PROCEDURE verify_reservation(
    IN p_secretary_id INT,
    IN p_reservation_id INT
)
BEGIN
    UPDATE CourtReservations
    SET res_status = 'COMPLETED',
    res_secreatary_scaned = p_secretary_id
    WHERE res_id = p_reservation_id;
END$$

DELIMITER ;