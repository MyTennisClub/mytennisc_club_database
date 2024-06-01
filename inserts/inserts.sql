-- Insert into SimpleUsers
INSERT INTO SimpleUsers (user_first_name, user_last_name, user_birth_date, user_email, user_phone, user_address, user_identification_file, user_doctors_file, user_solemn_declaration_file, user_has_children, referred_by)
VALUES ('John', 'Doe', '1985-06-15', 'john.doe@example.com', '555-1234', '123 Main St, Anytown, USA', NULL, NULL, NULL, true, NULL),
       ('Jane', 'Smith', '1990-09-25', 'jane.smith@example.com', '555-5678', '456 Elm St, Othertown, USA', NULL, NULL, NULL, false, 1);

-- Insert Data into TennisClub
INSERT INTO TennisClub (club_name, club_description, club_address, club_email, club_website, club_latitude, club_longitude, club_start_time, club_end_time, club_start_for_public, club_end_for_public, club_max_people_court)
VALUES
('Athens Tennis Club', 'A premier tennis club in Athens', '1 Kifisias Ave, Athens, Greece', 'info@athenstennisclub.gr', 'www.athenstennisclub.gr', 37.983810, 23.727539, '06:00:00', '22:00:00', '08:00:00', '20:00:00', 4),
('Thessaloniki Tennis Club', 'Open late for night tennis sessions', '2 Nikis Ave, Thessaloniki, Greece', 'contact@thessalonikitennisclub.gr', 'www.thessalonikitennisclub.gr', 40.640063, 22.944419, '06:00:00', '23:00:00', '09:00:00', '21:00:00', 5);

-- Insert into ClubsPhone
INSERT INTO ClubsPhone (club_phone, club_id)
VALUES ('555-9876', 1);

-- Insert into Clubs_Users
INSERT INTO Clubs_Users (club_id, user_id, user_type)
VALUES (1, 1, 'MEMBER'),
       (1, 2, 'GUEST');

-- Insert into Courts
INSERT INTO Courts (court_title, field_type, court_status, court_covered, court_athlete_capacity, court_only_for_members, court_equipment, court_equipment_price, court_public_equipment, court_price, court_club_id)
VALUES ('Court 1', 'CLAY', 'AVAILABLE', true, 4, false, true, 15.00, true, 50.00, 1),
       ('Court 2', 'GRASS', 'MAINTENANCE', false, 6, true, false, 0.00, false, 60.00, 1);

-- Insert into CourtReservations
INSERT INTO CourtReservations (res_type, res_status, res_start_date, res_end_date, res_no_people, res_court_id, res_equipment, res_club_id)
VALUES ('RESERVATION', 'PENDING', '2024-06-10 10:00:00', '2024-06-10 12:00:00', 2, 1, true, 1),
       ('SESSION', 'COMPLETED', '2024-06-11 14:00:00', '2024-06-11 16:00:00', 4, 2, false, 1);

-- Insert into Users_Reservations
INSERT INTO Users_Reservations (user_id, res_id)
VALUES (1, 1000000),
       (2, 1000001);

-- Insert into Request
INSERT INTO Request (status, type, to_become, req_club_id, req_user_id, req_child_id)
VALUES ('PENDING', 'SIMPLE', 'MEMBER', 1, 1, NULL),
       ('APPROVED', 'KID', 'ATHLETE', 1, 2, NULL);