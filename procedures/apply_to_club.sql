DROP PROCEDURE IF EXISTS simple_apply_to_club;

DELIMITER $$

CREATE PROCEDURE simple_apply_to_club(
    IN p_identification BLOB,
    IN p_doctors_note BLOB,
    IN p_to_become VARCHAR(100),
    IN p_tennis_club_id INT,
    IN p_guest_id INT
)

BEGIN

IF p_to_become = 'MEMBER' THEN

    INSERT INTO Request (
        status,
        type,
        to_become,
        club_id,
        user_id
    ) VALUES (
        'PENDING',
        'SIMPLE',  -- Assuming type SIMPLE for existing users making the request
        p_to_become,
        p_tennis_club_id,
        p_guest_id
    );

    UPDATE SimpleUsers
    SET

END IF;



END$$

DELIMITER ;



DROP PROCEDURE IF EXISTS you_athlete_apply;

DELIMITER $$

CREATE PROCEDURE you_athlete_apply(
    IN p_full_name VARCHAR(255),
    IN p_phone VARCHAR(50),
    IN p_address VARCHAR(255),
    IN p_email VARCHAR(100),
    IN p_birth_date DATETIME,
    IN p_identification BLOB,
    IN p_doctors_note BLOB,
    IN p_tennis_club_id INT,
    IN p_guest_id INT
)

BEGIN
    -- Insert the new request into the Request table
    INSERT INTO Request (
        status,
        type,
        to_become,
        club_id,
        guest_id,
        identification,
        doctors_note,
        solemn_dec,
        full_name,
        first_name,
        last_name,
        phone,
        address,
        birth_date,
        email,
        request_date
    ) VALUES (
        'PENDING',
        'SIMPLE',
        'ATHLETE',
        p_tennis_club_id,
        p_guest_id,
        p_identification,
        p_doctors_note,
        NULL,
        p_full_name,
        NULL, -- first_name, can be derived if needed
        NULL, -- last_name, can be derived if needed
        p_phone,
        p_address,
        date(p_birth_date),
        p_email,
        NOW()
    );
END$$

DELIMITER ;

-- ---------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS you_member_apply;

DELIMITER $$

CREATE PROCEDURE you_member_apply(
    IN p_full_name VARCHAR(255),
    IN p_phone VARCHAR(50),
    IN p_address VARCHAR(255),
    IN p_email VARCHAR(100),
    IN p_birth_date DATETIME,
     IN p_identification BLOB,
    IN p_tennis_club_id INT,
    IN p_guest_id INT
)
BEGIN
    -- Insert the new request into the Request table
    INSERT INTO Request (
        status,
        type,
        to_become,
        club_id,
        guest_id,
         identification,
        doctors_note,
        solemn_dec,
        full_name,
        first_name,
        last_name,
        phone,
        address,
        birth_date,
        email,
        request_date
    ) VALUES (
        'PENDING',
        'SIMPLE',
        'MEMBER',
        p_tennis_club_id,
        p_guest_id,
         p_identification,
        NULL,    -- doctors_note
        NULL,    -- solemn_dec
        p_full_name,
        NULL,    -- first_name
        NULL,    -- last_name
        p_phone,
        p_address,
        date(p_birth_date),
        p_email,
        NOW()
    );
END$$

DELIMITER ;

-- ---------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS kid_member_apply;

DELIMITER $$

CREATE PROCEDURE kid_member_apply(
    IN p_full_name VARCHAR(255),
    IN p_phone VARCHAR(50),
    IN p_address VARCHAR(255),
    IN p_email VARCHAR(100),
    IN p_birth_date DATETIME,
    IN p_identification BLOB,
    IN p_solemn_dec BLOB,
    IN p_tennis_club_id INT,
    IN p_guest_id INT
)
BEGIN
    -- Insert the new request into the Request table
    INSERT INTO Request (
        status,
        type,
        to_become,
        club_id,
        guest_id,
        identification,
        doctors_note,
        solemn_dec,
        full_name,
        first_name,
        last_name,
        phone,
        address,
        birth_date,
        email,
        request_date
    ) VALUES (
        'PENDING',
        'KID',
        'MEMBER',
        p_tennis_club_id,
        p_guest_id,
        p_identification,
        NULL,    -- doctors_note
        p_solemn_dec,
        p_full_name,
        NULL,    -- first_name
        NULL,    -- last_name
        p_phone,
        p_address,
        date(p_birth_date),
        p_email,
        NOW()
    );
END$$

DELIMITER ;

-- ---------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS kid_athlete_apply;

DELIMITER $$

CREATE PROCEDURE kid_athlete_apply(
    IN p_full_name VARCHAR(255),
    IN p_phone VARCHAR(50),
    IN p_address VARCHAR(255),
    IN p_email VARCHAR(100),
    IN p_birth_date DATETIME,
    IN p_identification BLOB,
    IN p_doctors_note BLOB,
    IN p_solemn_dec BLOB,
    IN p_tennis_club_id INT,
    IN p_guest_id INT
)
BEGIN
    -- Insert the new request into the Request table
    INSERT INTO Request (
        status,
        type,
        to_become,
        club_id,
        guest_id,
        identification,
        doctors_note,
        solemn_dec,
        full_name,
        first_name,
        last_name,
        phone,
        address,
        birth_date,
        email,
        request_date
    ) VALUES (
        'PENDING',
        'KID',
        'ATHLETE',
        p_tennis_club_id,
        p_guest_id,
        p_identification,
        p_doctors_note,
        p_solemn_dec,
        p_full_name,
        NULL,    -- first_name
        NULL,    -- last_name
        p_phone,
        p_address,
        date(p_birth_date),
        p_email,
        NOW()
    );
END$$

DELIMITER ;