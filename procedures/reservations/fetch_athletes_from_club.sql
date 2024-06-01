DROP PROCEDURE IF EXISTS fetch_athletes_from_club;

DELIMITER $$

CREATE PROCEDURE fetch_athletes_from_club(
    IN p_club_id INT
)
BEGIN
    SELECT
        su.user_id,
        su.user_first_name,
        su.user_last_name
    FROM
        SimpleUsers su
    JOIN
        Clubs_Users cu ON su.user_id = cu.user_id
    WHERE
        cu.club_id = p_club_id
        AND cu.user_type IN ('ATHLETE');
END$$

DELIMITER ;

call fetch_athletes_from_club(1);