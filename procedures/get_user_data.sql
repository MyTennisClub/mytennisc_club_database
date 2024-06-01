DROP PROCEDURE IF EXISTS get_user_data_by_id;

DELIMITER $$

CREATE PROCEDURE get_user_data_by_id(IN p_user_id INT)
BEGIN
    SELECT
        user_first_name,
        user_last_name,
        user_birth_date,
        user_email,
        user_phone,
        user_address,
        user_type
    FROM
        SimpleUsers
    WHERE
        user_id = p_user_id;
END$$

DELIMITER ;