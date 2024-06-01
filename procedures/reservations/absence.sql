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