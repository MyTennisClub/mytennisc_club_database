DROP PROCEDURE IF EXISTS load_review_data;

DELIMITER $$

CREATE PROCEDURE load_review_data(
    IN p_tennis_club_id INT
)
BEGIN
    SELECT
        su.user_first_name,
        cu.review_description,
        cu.review_likes,
        cu.review_check
    FROM
        Clubs_Users cu
    JOIN
        SimpleUsers su ON cu.user_id = su.user_id
    WHERE
        cu.club_id = p_tennis_club_id and cu.review_check = true;
END$$

DELIMITER ;

CALL load_review_data(1);