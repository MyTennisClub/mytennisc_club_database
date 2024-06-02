DROP PROCEDURE IF EXISTS GetReservationDetails;
DELIMITER $$
CREATE PROCEDURE GetReservationDetails (
    IN p_res_id BIGINT
)
BEGIN
    SELECT
        cr.res_status,
        cr.res_start_date,
        cr.res_end_date,
        cr.res_court_id,
        c.court_title AS court_name,
        cr.res_no_people,
        cr.res_equipment
    FROM
        CourtReservations cr
    INNER JOIN
        Courts c ON cr.res_court_id = c.court_id
    WHERE
        cr.res_id = p_res_id;
END$$
DELIMITER ;

-- Example usage:
# CALL GetReservationDetails(1000000);