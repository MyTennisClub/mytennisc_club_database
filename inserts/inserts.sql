-- Insert data into SimpleUsers
INSERT INTO SimpleUsers (user_first_name, user_last_name, user_birth_date, user_email, user_phone, user_address, user_has_children)
VALUES
('John', 'Doe', '1980-01-01', 'john.doe@example.com', '1234567890', '123 Main St', TRUE),
('Jane', 'Smith', '1985-02-02', 'jane.smith@example.com', '0987654321', '456 Elm St', FALSE),
('Mike', 'Johnson', '1990-03-03', 'mike.johnson@example.com', '1112223333', '789 Oak St', TRUE),
('Emily', 'Davis', '1995-04-04', 'emily.davis@example.com', '4445556666', '101 Pine St', FALSE),
('Chris', 'Brown', '2000-05-05', 'chris.brown@example.com', '7778889999', '202 Maple St', TRUE),
('Alex', 'Miller', '1992-06-06', 'alex.miller@example.com', '2223334444', '303 Birch St', FALSE),
('Nina', 'Wilson', '1988-07-07', 'nina.wilson@example.com', '5556667777', '404 Cedar St', TRUE),
('Oscar', 'Taylor', '1994-08-08', 'oscar.taylor@example.com', '8889990000', '505 Spruce St', FALSE),
('Laura', 'Anderson', '1986-09-09', 'laura.anderson@example.com', '0001112222', '606 Fir St', TRUE),
('David', 'Thomas', '1991-10-10', 'david.thomas@example.com', '3334445555', '707 Redwood St', FALSE);


-- Insert data into TennisClub
INSERT INTO TennisClub (club_name, club_description, club_address, club_email, club_website, club_latitude, club_longitude, club_start_time, club_end_time, club_start_for_public, club_end_for_public, club_max_people_court)
VALUES
('Ace Tennis Club', 'Top class tennis club', '123 Tennis Way', 'info@acetennis.com', 'www.acetennis.com', 40.712776, -74.005974, '06:00:00', '22:00:00', '08:00:00', '20:00:00', 10),
('Smash Tennis Club', 'Family friendly club', '456 Racket Rd', 'contact@smashtennis.com', 'www.smashtennis.com', 34.052235, -118.243683, '07:00:00', '21:00:00', '09:00:00', '19:00:00', 8),
('Serve Tennis Club', 'Professional training facility', '789 Net St', 'hello@servetennis.com', 'www.servetennis.com', 51.507351, -0.127758, '05:00:00', '23:00:00', '07:00:00', '21:00:00', 12),
('Volley Tennis Club', 'Community focused club', '101 Court Ave', 'admin@volleytennis.com', 'www.volleytennis.com', 48.856613, 2.352222, '06:30:00', '22:30:00', '08:30:00', '20:30:00', 6);


-- Insert data into Clubs_Users
INSERT INTO Clubs_Users (club_id, user_id, user_type)
VALUES
(1, 1, 'MEMBER'),
(1, 2, 'ATHLETE'),
(2, 3, 'MEMBER'),
(2, 4, 'ATHLETE'),
(3, 5, 'MEMBER'),
(3, 1, 'ATHLETE'),
(4, 2, 'MEMBER'),
(4, 3, 'ATHLETE'),
(1, 6, 'ATHLETE'),
(1, 7, 'ATHLETE'),
(2, 8, 'ATHLETE'),
(2, 9, 'ATHLETE'),
(3, 10, 'ATHLETE'),
(3, 6, 'ATHLETE'),
(4, 7, 'ATHLETE'),
(4, 8, 'ATHLETE'),
(1, 9, 'ATHLETE'),
(2, 10, 'ATHLETE'),
(3, 7, 'ATHLETE'),
(4, 6, 'ATHLETE');

-- Insert data into Courts
INSERT INTO Courts (court_title, field_type, court_status, court_covered, court_athlete_capacity, court_only_for_members, court_equipment, court_equipment_price, court_public_equipment, court_price, court_club_id)
VALUES
('Court 1', 'CLAY', 'AVAILABLE', TRUE, 4, FALSE, TRUE, 10.00, TRUE, 50.00, 1),
('Court 2', 'GRASS', 'MAINTENANCE', FALSE, 6, TRUE, FALSE, 0.00, FALSE, 60.00, 1),
('Court 3', 'HARD', 'AVAILABLE', TRUE, 5, FALSE, TRUE, 15.00, TRUE, 55.00, 2),
('Court 4', 'CARPET', 'AVAILABLE', FALSE, 3, TRUE, TRUE, 20.00, TRUE, 40.00, 3);

-- Insert data into CourtReservations
INSERT INTO CourtReservations (res_type, res_status, res_start_date, res_end_date, res_no_people, res_court_id, res_equipment, res_club_id)
VALUES
('RESERVATION', 'PENDING', '2024-06-01 09:00:00', '2024-06-01 10:00:00', 4, 1, TRUE, 1),
('SESSION', 'COMPLETED', '2024-05-31 14:00:00', '2024-05-31 16:00:00', 6, 3, FALSE, 2),
('RESERVATION', 'CANCELLED', '2024-06-02 11:00:00', '2024-06-02 12:00:00', 2, 4, TRUE, 3),
('SESSION', 'PENDING', '2024-06-03 17:00:00', '2024-06-03 18:30:00', 5, 2, TRUE, 1);

-- Insert data into Users_Reservations
INSERT INTO Users_Reservations (user_id, res_id)
VALUES
(1, 1000000),
(2, 1000001),
(3, 1000002),
(4, 1000003),
(5, 1000000);
