DROP PROCEDURE IF EXISTS AddUserToReservation;

DELIMITER $$

CREATE PROCEDURE AddUserToReservation(
    IN p_user_id INT,
    IN p_res_id BIGINT
)
BEGIN
     -- Inserting the user into the Users_Reservations table
    INSERT INTO Users_Reservations (user_id, res_id, absence)
    VALUES (p_user_id, p_res_id, FALSE);
END$$

DELIMITER ;