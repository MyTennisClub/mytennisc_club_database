-- Insert Data into SimpleUsers
INSERT INTO SimpleUsers (user_first_name, user_last_name, user_birth_date, user_email, user_phone, user_address, user_type, user_identification_file, user_doctors_file, user_solemn_declaration_file, user_has_children, referred_by)
VALUES
('John', 'Doe', '1990-01-01', 'john.doe@example.com', '123-456-7890', '123 Main St', 'MEMBER', NULL, NULL, NULL, FALSE, NULL),
('Jane', 'Smith', '1985-05-15', 'jane.smith@example.com', '234-567-8901', '456 Elm St', 'ATHLETE', NULL, NULL, NULL, TRUE, 1),
('Mike', 'Johnson', '1992-07-20', 'mike.johnson@example.com', '345-678-9012', '789 Oak St', 'GUEST', NULL, NULL, NULL, FALSE, 2);

-- Insert Data into TennisClub
INSERT INTO TennisClub (club_name, club_description, club_address, club_email, club_website, club_latitude, club_longitude, club_start_time, club_end_time, club_start_for_public, club_end_for_public, club_max_people_court)
VALUES
('Athens Tennis Club', 'A premier tennis club in Athens', '1 Kifisias Ave, Athens, Greece', 'info@athenstennisclub.gr', 'www.athenstennisclub.gr', 37.983810, 23.727539, '06:00:00', '22:00:00', '08:00:00', '20:00:00', 4),
('Thessaloniki Tennis Club', 'Open late for night tennis sessions', '2 Nikis Ave, Thessaloniki, Greece', 'contact@thessalonikitennisclub.gr', 'www.thessalonikitennisclub.gr', 40.640063, 22.944419, '06:00:00', '23:00:00', '09:00:00', '21:00:00', 5);

-- Insert Data into ClubsPhone
INSERT INTO ClubsPhone (club_phone, club_id)
VALUES
('+30-210-123-4567', 1),
('+30-231-123-4567', 2);

-- Insert Data into Clubs_Users
INSERT INTO Clubs_Users (club_id, user_id)
VALUES
(1, 1),
(1, 2),
(2, 3);

-- Insert Data into Courts
INSERT INTO Courts (court_title, field_type, court_status, court_covered, court_athlete_capacity, court_only_for_members, court_equipment, court_equipment_price, court_public_equipment, court_price, court_club_id)
VALUES
('Court 1', 'CLAY', 'AVAILABLE', TRUE, 4, FALSE, TRUE, 10.00, TRUE, 20.00, 1),
('Court 2', 'GRASS', 'MAINTENANCE', FALSE, 6, TRUE, FALSE, 0.00, FALSE, 15.00, 1),
('Court 3', 'HARD', 'AVAILABLE', TRUE, 4, FALSE, TRUE, 8.00, TRUE, 18.00, 2);

-- Insert Data into CourtReservations
INSERT INTO CourtReservations (res_type, res_status, res_start_date, res_end_date, res_no_people, res_court_id, res_equipment, res_club_id)
VALUES
('RESERVATION', 'PENDING', '2024-06-01 10:00:00', '2024-06-01 12:00:00', 4, 1, TRUE, 1),
('SESSION', 'COMPLETED', '2024-05-20 14:00:00', '2024-05-20 16:00:00', 6, 2, FALSE, 1),
('RESERVATION', 'CANCELLED', '2024-07-01 09:00:00', '2024-07-01 11:00:00', 3, 3, TRUE, 2);

-- Insert Data into Users_Reservations
INSERT INTO Users_Reservations (user_id, res_id)
VALUES
(1, 1000000),
(2, 1000001),
(3, 1000002);

-- Insert Data into Request
INSERT INTO Request (status, type, to_become, req_club_id, req_user_id, req_child_id)
VALUES
('PENDING', 'SIMPLE', 'MEMBER', 1, 1, NULL),
('APPROVED', 'SIMPLE', 'ATHLETE', 1, 2, NULL),
('REJECTED', 'KID', 'ATHLETE', 2, 3, NULL);