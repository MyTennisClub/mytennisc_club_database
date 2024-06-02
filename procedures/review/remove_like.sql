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