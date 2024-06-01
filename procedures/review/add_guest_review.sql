DROP PROCEDURE IF EXISTS add_guest_review;

DELIMITER $$

CREATE PROCEDURE add_guest_review(
    IN p_user_id INT,
    IN p_tennis_club_id INT,
    IN p_review_stars INT,
    IN p_review_text TEXT
)
BEGIN
    -- Declare variables to hold the results
    DECLARE user_exists BOOLEAN DEFAULT FALSE;
    DECLARE review_status BOOLEAN DEFAULT FALSE;

    -- Check if the user exists and fetch the review_check status
    SELECT review_check INTO review_status
    FROM Clubs_Users
    WHERE user_id = p_user_id AND club_id = p_tennis_club_id
    LIMIT 1;

    -- Set user_exists to TRUE if a matching row is found
    IF (SELECT COUNT(*) FROM Clubs_Users WHERE user_id = p_user_id AND club_id = p_tennis_club_id) > 0 THEN
        SET user_exists = TRUE;
    END IF;

    -- If the user exists and review_check is false, update the review data
    IF user_exists AND review_status = FALSE THEN
        UPDATE Clubs_Users
        SET review_stars = p_review_stars,
            review_description = p_review_text,
            review_check = TRUE -- Mark the review_check as true after updating
        WHERE user_id = p_user_id AND club_id = p_tennis_club_id;
    END IF;
END$$

DELIMITER ;

# call add_guest_review(2,1,5,'blabla');