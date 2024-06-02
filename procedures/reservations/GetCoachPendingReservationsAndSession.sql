DROP PROCEDURE IF EXISTS GetCoachPendingReservationsAndSessions;
DELIMITER $$
CREATE PROCEDURE GetCoachPendingReservationsAndSessions (
    IN p_coach_id INT
)
BEGIN
    SELECT
        cr.res_id,
        cr.res_type,
        cr.res_court_id,
        c.court_title AS court_name,
        cr.res_start_date AS start_time,
        cr.res_end_date AS end_time
    FROM
        CourtReservations cr
    INNER JOIN
        Users_Reservations ur ON cr.res_id = ur.res_id
    INNER JOIN
        Courts c ON cr.res_court_id = c.court_id
    WHERE
        ur.user_id = p_coach_id
        AND cr.res_status = 'PENDING'
    ORDER BY
        cr.res_start_date ASC;
END$$
DELIMITER ;

CALL GetCoachPendingReservationsAndSessions(1);