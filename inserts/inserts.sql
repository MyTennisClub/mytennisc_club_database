-- Insert into SimpleUsers
INSERT INTO SimpleUsers (user_first_name, user_last_name, user_birth_date, user_email, user_phone, user_address, user_has_children, referred_by)
VALUES
('John', 'Doe', '1990-05-15', 'john.doe@example.com', '123-456-7890', '123 Main St, Cityville', false, NULL),
('Jane', 'Smith', '1985-10-25', 'jane.smith@example.com', '321-654-0987', '456 Elm St, Townsville', true, 1);

-- Insert into TennisClub
INSERT INTO TennisClub (club_name, club_description, club_address, club_email, club_website, club_latitude, club_longitude, club_start_time, club_end_time, club_start_for_public, club_end_for_public, club_max_people_court)
VALUES
('City Tennis Club', 'A premier tennis club in the city', '789 Oak St, Cityville', 'contact@citytennisclub.com', 'www.citytennisclub.com', 40.712776, -74.005974, '06:00:00', '22:00:00', '08:00:00', '20:00:00', 4);

-- Insert into ClubsPhone
INSERT INTO ClubsPhone (club_phone, club_id)
VALUES
('123-123-1234', 1),
('321-321-4321', 1);

-- Insert into Clubs_Users
INSERT INTO Clubs_Users (club_id, user_id, user_type, review_stars, review_description, review_likes, review_check)
VALUES
(1, 1, 'MEMBER', 5, 'Great club with excellent facilities.', 10, true),
(1, 2, 'GUEST', 4, 'Nice place, but can get crowded.', 5, false);

-- Insert into Courts
INSERT INTO Courts (court_title, field_type, court_status, court_covered, court_athlete_capacity, court_only_for_members, court_equipment, court_equipment_price, court_public_equipment, court_price, court_club_id)
VALUES
('Court 1', 'CLAY', 'AVAILABLE', true, 4, false, true, 10.00, true, 20.00, 1),
('Court 2', 'GRASS', 'MAINTENANCE', false, 2, true, false, 0.00, false, 15.00, 1);

-- Insert into CourtReservations
INSERT INTO CourtReservations (res_type, res_status, res_start_date, res_end_date, res_no_people, res_court_id, res_equipment, res_club_id)
VALUES
('RESERVATION', 'PENDING', '2024-06-01 10:00:00', '2024-06-01 12:00:00', 2, 1, true, 1),
('SESSION', 'COMPLETED', '2024-05-30 14:00:00', '2024-05-30 16:00:00', 4, 2, false, 1);

-- Insert into Users_Reservations
INSERT INTO Users_Reservations (user_id, res_id)
VALUES
(1, 1000000),
(2, 1000001);

-- Insert into Request
INSERT INTO Request (status, type, to_become, club_id, user_id, child_id)
VALUES
('PENDING', 'SIMPLE', 'MEMBER', 1, 1, NULL),
('APPROVED', 'KID', 'ATHLETE', 1, 2, 1);
