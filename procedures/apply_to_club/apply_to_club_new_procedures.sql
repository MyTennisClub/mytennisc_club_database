# call simple_apply_to_club(NULL,NULL,'ATHLETE',1,3);

DROP PROCEDURE IF EXISTS simple_apply_to_club;

DELIMITER $$

CREATE PROCEDURE simple_apply_to_club(
    IN p_identification BLOB,
    IN p_doctors_note BLOB,
    IN p_to_become VARCHAR(100),
    IN p_tennis_club_id INT,
    IN p_user_id INT
)

BEGIN

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
    p_user_id
);

IF p_to_become = 'MEMBER' THEN

    UPDATE SimpleUsers
    SET user_identification_file = p_identification
    WHERE user_id = p_user_id;

ELSE
    UPDATE SimpleUsers
    SET user_identification_file = p_identification, user_doctors_file = p_doctors_note
    WHERE user_id = p_user_id;

END IF;

END$$

DELIMITER ;

-- ------------------------------------------------------

# DROP PROCEDURE IF EXISTS create_kid_user;
#
# DELIMITER $$
#
# CREATE PROCEDURE create_kid_user(
#     IN p_father_id INT,
#     IN p_kid_first_name VARCHAR(255),
#     IN p_kid_last_name VARCHAR(255),
#     IN p_kid_birth_date DATE,
#     IN p_kid_email VARCHAR(100),
#     IN p_kid_phone VARCHAR(50),
#     IN p_kid_address VARCHAR(255),
#     OUT p_kid_user_id INT
# )
# BEGIN
#     DECLARE p_kid_user_id INT;
#
#     INSERT INTO SimpleUsers (
#         user_first_name,
#         user_last_name,
#         user_birth_date,
#         user_email,
#         user_phone,
#         user_address,
#         user_type,
#         referred_by,
#         user_has_children
#     ) VALUES (
#         p_kid_first_name,
#         p_kid_last_name,
#         p_kid_birth_date,
#         p_kid_email,
#         p_kid_phone,
#         p_kid_address,
#         'GUEST',
#         p_father_id,
#         FALSE
#     );
#
#     UPDATE simpleusers
#     SET user_has_children = true
#     WHERE user_id = p_father_id;
#
#     SET p_kid_user_id = LAST_INSERT_ID();
#
#     -- Return the new kid's user ID
#     SELECT p_kid_user_id;
# END$$
#
# DELIMITER ;

-- ------------------------------------------------------
# call kid_apply_to_club(null,null,null,'ATHLETE',1,3,'BOB','MIHALOPOULOS','2010-04-15','baknis@gmail.com','1234','adsd');

DROP PROCEDURE IF EXISTS kid_apply_to_club;

DELIMITER $$

CREATE PROCEDURE kid_apply_to_club(
    IN p_identification BLOB,
    IN p_doctors_note BLOB,
    IN p_solemn_decl BLOB,
    IN p_to_become VARCHAR(100),
    IN p_tennis_club_id INT,
    IN p_guardian_id INT,
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_birth_date DATE,
    IN p_email VARCHAR(50),
    IN p_phone VARCHAR(50),
    IN p_address VARCHAR(50)
)

BEGIN

DECLARE p_kid_user_id INT;
# call create_kid_user(p_guardian_id,p_first_name,p_last_name,p_birth_date,p_email,p_phone, p_address,@kid_user_id);

-- Create a new kid user
INSERT INTO SimpleUsers (
    user_first_name,
    user_last_name,
    user_birth_date,
    user_email,
    user_phone,
    user_address,
    referred_by,
    user_has_children
) VALUES (
    p_first_name,
    p_last_name,
    p_birth_date,
    p_email,
    p_phone,
    p_address,
    p_guardian_id,
    FALSE
);

UPDATE simpleusers
SET user_has_children = true
WHERE user_id = p_guardian_id;

SET p_kid_user_id = LAST_INSERT_ID();

# Apply to club (kid)
INSERT INTO Request (
    status,
    type,
    to_become,
    club_id,
    user_id,
    child_id
) VALUES (
    'PENDING',
    'KID',  -- Assuming type SIMPLE for existing users making the request
    p_to_become,
    p_tennis_club_id,
    p_guardian_id,
    p_kid_user_id
);

IF p_to_become = 'MEMBER' THEN

    UPDATE SimpleUsers
    SET user_identification_file = p_identification, user_doctors_file = p_doctors_note
    WHERE user_id = p_kid_user_id;

ELSE

    UPDATE SimpleUsers
    SET user_identification_file = p_identification, user_doctors_file = p_doctors_note, user_solemn_declaration_file= p_solemn_decl
    WHERE user_id = p_kid_user_id;

END IF;

END$$

DELIMITER ;

-- ------------------------------------------------------

# call get_user_info(1);

DROP PROCEDURE IF EXISTS get_user_info;

DELIMITER $$

CREATE PROCEDURE get_user_info(
    IN p_user_id INT
)
BEGIN
    SELECT
        CONCAT(user_first_name, ' ', user_last_name) AS full_name,
        user_phone,
        user_address,
        user_email,
        user_birth_date
    FROM
        SimpleUsers
    WHERE
        user_id = p_user_id;
END$$

DELIMITER ;

-- -----------------------------------------------------------------------------------