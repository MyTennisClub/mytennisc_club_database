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

# call cancel_reservation(1000000);