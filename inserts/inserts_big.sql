-- Insert sample data into SimpleUsers
INSERT INTO SimpleUsers (user_first_name, user_last_name, user_birth_date, user_email, user_phone, user_address, user_identification_file, user_doctors_file, user_solemn_declaration_file, user_has_children, referred_by)
VALUES
('John', 'Doe', '1980-01-01', 'john.doe@example.com', '123-456-7890', '123 Main St', NULL, NULL, NULL, FALSE, NULL),
('Jane', 'Smith', '1985-05-15', 'jane.smith@example.com', '321-654-0987', '456 Oak St', NULL, NULL, NULL, TRUE, NULL),
('Alice', 'Johnson', '1990-02-20', 'alice.johnson@example.com', '555-123-4567', '789 Pine St', NULL, NULL, NULL, FALSE, 1),
('Bob', 'Brown', '1975-11-30', 'bob.brown@example.com', '444-555-6666', '321 Elm St', NULL, NULL, NULL, TRUE, 2),
('Charlie', 'Davis', '1988-07-12', 'charlie.davis@example.com', '666-777-8888', '654 Cedar St', NULL, NULL, NULL, FALSE, 3),
('David', 'Clark', '1982-03-14', 'david.clark@example.com', '987-654-3210', '147 Elm St', NULL, NULL, NULL, FALSE, NULL),
('Emily', 'Evans', '1995-08-25', 'emily.evans@example.com', '876-543-2109', '258 Maple St', NULL, NULL, NULL, FALSE, 1),
('Frank', 'Garcia', '1978-12-05', 'frank.garcia@example.com', '765-432-1098', '369 Birch St', NULL, NULL, NULL, TRUE, NULL),
('Grace', 'Harris', '1987-09-18', 'grace.harris@example.com', '654-321-0987', '741 Cedar St', NULL, NULL, NULL, TRUE, 2),
('Henry', 'Wilson', '1992-06-22', 'henry.wilson@example.com', '543-210-9876', '852 Spruce St', NULL, NULL, NULL, FALSE, 3),
('Irene', 'Martinez', '1985-04-17', 'irene.martinez@example.com', '432-109-8765', '963 Apple St', NULL, NULL, NULL, TRUE, NULL),
('Jake', 'Anderson', '1979-11-29', 'jake.anderson@example.com', '321-098-7654', '852 Orange St', NULL, NULL, NULL, TRUE, NULL),
('Laura', 'White', '1991-03-23', 'laura.white@example.com', '210-987-6543', '741 Peach St', NULL, NULL, NULL, FALSE, 1),
('Mark', 'Moore', '1980-07-21', 'mark.moore@example.com', '109-876-5432', '630 Pear St', NULL, NULL, NULL, FALSE, 2),
('Nina', 'Taylor', '1988-12-15', 'nina.taylor@example.com', '098-765-4321', '521 Banana St', NULL, NULL, NULL, FALSE, 3);

-- Insert sample data into TennisClub
INSERT INTO TennisClub (club_name, club_description, club_address, club_email, club_website, club_latitude, club_longitude, club_start_time, club_end_time, club_start_for_public, club_end_for_public, club_max_people_court)
VALUES
('Greenwood Tennis Club', 'A premier tennis club with top-notch facilities.', '123 Club Rd', 'contact@greenwoodclub.com', 'www.greenwoodclub.com', 40.712776, -74.005974, '06:00:00', '22:00:00', '09:00:00', '21:00:00', 20),
('Lakeside Tennis Club', 'Beautiful lakeside courts with professional coaching.', '456 Lake Rd', 'info@lakesideclub.com', 'www.lakesideclub.com', 34.052235, -118.243683, '06:30:00', '21:30:00', '08:30:00', '20:30:00', 15),
('Patras Tennis Club', 'The premier tennis club in Patras.', '1 Agiou Nikolaou St, Patras', 'info@patrastennis.com', 'www.patrastennis.com', 38.246639, 21.734573, '07:00:00', '23:00:00', '08:00:00', '22:00:00', 25),
('Achaia Tennis Club', 'Top-notch facilities and coaching in Patras.', '2 Korinthou St, Patras', 'contact@achaiatennis.com', 'www.achaiatennis.com', 38.245552, 21.737682, '06:00:00', '22:00:00', '09:00:00', '21:00:00', 18),
('Rio Tennis Club', 'Family-friendly tennis club in Rio, Patras.', '3 Akti Dymaion St, Patras', 'support@riotennis.com', 'www.riotennis.com', 38.310400, 21.783200, '06:30:00', '21:30:00', '08:30:00', '20:30:00', 20);

-- Insert sample data into ClubsPhone
INSERT INTO ClubsPhone (club_phone, club_id)
VALUES
('123-111-2222', 1),
('123-333-4444', 1),
('456-555-6666', 2),
('456-777-8888', 2),
('2610-123-456', 3),
('2610-234-567', 3),
('2610-345-678', 4),
('2610-456-789', 4),
('2610-567-890', 5),
('2610-678-901', 5);

-- Insert sample data into Clubs_Users
INSERT INTO Clubs_Users (club_id, user_id, user_type, review_date, review_stars, review_description, review_likes, review_check)
VALUES
(1, 1, 'MEMBER', '2023-01-01', 5, 'Great club with excellent facilities!', 10, TRUE),
(1, 2, 'ATHLETE', '2023-02-15', 4, 'Good coaching and friendly staff.', 5, TRUE),
(1, 3, 'MEMBER', '2023-03-10', 4, 'Nice location but a bit crowded.', 3, TRUE),
(1, 4, 'MEMBER', '2023-04-20', 5, 'Love playing here every weekend.', 8, TRUE),
(1, 5, 'ATHLETE', '2023-05-05', 4, 'Well-maintained courts.', 2, TRUE),
(1, 6, 'MEMBER', '2023-06-01', 5, 'Amazing club with great amenities!', 12, TRUE),
(1, 7, 'ATHLETE', '2023-07-10', 4, 'Enjoy the facilities here.', 6, TRUE),
(1, 8, 'MEMBER', '2023-08-15', 5, 'Best club in town.', 9, TRUE),
(1, 9, 'ATHLETE', '2023-09-25', 4, 'Fantastic coaches!', 5, TRUE),
(1, 10, 'MEMBER', '2023-10-30', 5, 'Great place to play tennis.', 7, TRUE),
(2, 11, 'MEMBER', '2023-01-01', 4, 'Nice club with good facilities.', 5, TRUE),
(2, 12, 'ATHLETE', '2023-02-15', 3, 'Good but can be crowded.', 3, TRUE),
(2, 13, 'MEMBER', '2023-03-10', 5, 'Love the environment here.', 8, TRUE),
(2, 14, 'MEMBER', '2023-04-20', 4, 'Friendly staff and members.', 6, TRUE),
(2, 15, 'ATHLETE', '2023-05-05', 4, 'Great place to train.', 4, TRUE),
(3, 1, 'MEMBER', '2023-01-15', 5, 'Excellent club in Patras!', 12, TRUE),
(3, 2, 'ATHLETE', '2023-02-25', 4, 'Great coaching staff.', 7, TRUE),
(3, 3, 'GUEST', '2023-03-30', 3, 'Good facilities but crowded.', 4, TRUE),
(3, 4, 'MEMBER', '2023-04-10', 5, 'Highly recommend this club.', 9, TRUE),
(3, 5, 'ATHLETE', '2023-05-20', 4, 'Enjoy playing here regularly.', 6, TRUE),
(3, 6, 'MEMBER', '2023-06-01', 5, 'Best club in Patras.', 8, TRUE),
(3, 7, 'ATHLETE', '2023-07-10', 4, 'Good facilities.', 5, TRUE),
(3, 8, 'MEMBER', '2023-08-15', 5, 'Friendly and professional.', 7, TRUE),
(3, 9, 'ATHLETE', '2023-09-25', 4, 'Nice place to train.', 6, TRUE),
(3, 10, 'MEMBER', '2023-10-30', 5, 'Fantastic club!', 10, TRUE),
(4, 11, 'MEMBER', '2023-01-01', 5, 'Top-notch facilities.', 9, TRUE),
(4, 12, 'ATHLETE', '2023-02-15', 4, 'Professional staff.', 5, TRUE),
(4, 13, 'MEMBER', '2023-03-10', 5, 'Great community.', 7, TRUE),
(4, 14, 'MEMBER', '2023-04-20', 5, 'Love playing here.', 8, TRUE),
(4, 15, 'ATHLETE', '2023-05-05', 4, 'Excellent coaching.', 4, TRUE),
(4, 1, 'MEMBER', '2023-06-01', 5, 'Great club atmosphere.', 6, TRUE),
(4, 2, 'ATHLETE', '2023-07-10', 4, 'Good training facilities.', 5, TRUE),
(4, 3, 'GUEST', '2023-08-15', 3, 'Nice but crowded.', 4, TRUE),
(4, 4, 'MEMBER', '2023-09-25', 5, 'Highly recommend.', 7, TRUE),
(4, 5, 'ATHLETE', '2023-10-30', 4, 'Great place to play.', 5, TRUE),
(5, 6, 'MEMBER', '2023-01-01', 5, 'Best club for families.', 10, TRUE),
(5, 7, 'ATHLETE', '2023-02-15', 4, 'Enjoy the facilities.', 6, TRUE),
(5, 8, 'MEMBER', '2023-03-10', 5, 'Friendly staff.', 7, TRUE),
(5, 9, 'ATHLETE', '2023-04-20', 4, 'Good training environment.', 5, TRUE),
(5, 10, 'MEMBER', '2023-05-05', 5, 'Excellent club!', 8, TRUE);

-- Insert sample data into Courts
INSERT INTO Courts (court_title, field_type, court_status, court_covered, court_athlete_capacity, court_only_for_members, court_equipment, court_equipment_price, court_public_equipment, court_price, court_club_id)
VALUES
('Court 1', 'CLAY', 'AVAILABLE', TRUE, 4, FALSE, TRUE, 10.00, TRUE, 50.00, 1),
('Court 2', 'GRASS', 'MAINTENANCE', FALSE, 2, TRUE, FALSE, 0.00, TRUE, 30.00, 1),
('Court 3', 'HARD', 'AVAILABLE', FALSE, 6, FALSE, TRUE, 15.00, TRUE, 60.00, 2),
('Court 4', 'CARPET', 'AVAILABLE', TRUE, 4, TRUE, TRUE, 12.00, FALSE, 45.00, 2),
('Court 5', 'CLAY', 'AVAILABLE', TRUE, 4, FALSE, TRUE, 12.00, TRUE, 55.00, 3),
('Court 6', 'GRASS', 'MAINTENANCE', FALSE, 3, TRUE, FALSE, 0.00, TRUE, 35.00, 3),
('Court 7', 'HARD', 'AVAILABLE', FALSE, 6, FALSE, TRUE, 18.00, TRUE, 65.00, 4),
('Court 8', 'CARPET', 'AVAILABLE', TRUE, 5, TRUE, TRUE, 14.00, FALSE, 50.00, 4),
('Court 9', 'CLAY', 'AVAILABLE', TRUE, 4, FALSE, TRUE, 15.00, TRUE, 60.00, 5),
('Court 10', 'GRASS', 'AVAILABLE', FALSE, 2, TRUE, FALSE, 0.00, TRUE, 40.00, 5);

-- Insert sample data into CourtReservations
INSERT INTO CourtReservations (res_type, res_status, res_start_date, res_end_date, res_no_people, res_court_id, res_equipment, res_club_id, res_sec_scan, res_qr_code)
VALUES
('RESERVATION', 'PENDING', '2023-06-01 09:00:00', '2023-06-01 10:00:00', 2, 1, TRUE, 1, NULL, NULL),
('SESSION', 'COMPLETED', '2023-06-01 11:00:00', '2023-06-01 12:30:00', 4, 3, FALSE, 2, NULL, NULL),
('RESERVATION', 'CANCELLED', '2023-06-02 14:00:00', '2023-06-02 15:00:00', 6, 3, TRUE, 2, NULL, NULL),
('SESSION', 'PENDING', '2023-06-03 08:00:00', '2023-06-03 09:30:00', 4, 4, FALSE, 2, NULL, NULL),
('RESERVATION', 'PENDING', '2023-06-05 09:00:00', '2023-06-05 10:00:00', 3, 5, TRUE, 3, NULL, NULL),
('SESSION', 'COMPLETED', '2023-06-05 11:00:00', '2023-06-05 12:30:00', 4, 7, FALSE, 4, NULL, NULL),
('RESERVATION', 'CANCELLED', '2023-06-06 14:00:00', '2023-06-06 15:00:00', 5, 9, TRUE, 5, NULL, NULL),
('SESSION', 'PENDING', '2023-06-07 08:00:00', '2023-06-07 09:30:00', 4, 10, FALSE, 5, NULL, NULL),
('RESERVATION', 'PENDING', '2023-06-08 10:00:00', '2023-06-08 11:00:00', 2, 1, TRUE, 1, NULL, NULL),
('SESSION', 'COMPLETED', '2023-06-08 12:00:00', '2023-06-08 13:30:00', 4, 3, FALSE, 2, NULL, NULL),
('RESERVATION', 'CANCELLED', '2023-06-09 15:00:00', '2023-06-09 16:00:00', 6, 3, TRUE, 2, NULL, NULL),
('SESSION', 'PENDING', '2023-06-10 08:00:00', '2023-06-10 09:30:00', 4, 4, FALSE, 2, NULL, NULL),
('RESERVATION', 'PENDING', '2023-06-11 09:00:00', '2023-06-11 10:00:00', 3, 5, TRUE, 3, NULL, NULL),
('SESSION', 'COMPLETED', '2023-06-11 11:00:00', '2023-06-11 12:30:00', 4, 7, FALSE, 4, NULL, NULL),
('RESERVATION', 'CANCELLED', '2023-06-12 14:00:00', '2023-06-12 15:00:00', 5, 9, TRUE, 5, NULL, NULL),
('SESSION', 'PENDING', '2023-06-13 08:00:00', '2023-06-13 09:30:00', 4, 10, FALSE, 5, NULL, NULL);

-- Insert sample data into Users_Reservations
INSERT INTO Users_Reservations (user_id, res_id, absence)
VALUES
(1, 1000000, FALSE),
(2, 1000001, TRUE),
(3, 1000002, FALSE),
(4, 1000003, FALSE),
(5, 1000004, FALSE),
(6, 1000005, TRUE),
(7, 1000006, FALSE),
(8, 1000007, FALSE),
(9, 1000008, FALSE),
(10, 1000009, TRUE),
(11, 1000010, FALSE),
(12, 1000011, FALSE),
(13, 1000012, FALSE),
(14, 1000013, TRUE),
(15, 1000014, FALSE);

-- Insert sample data into Employees_Clubs
INSERT INTO Employees_Clubs (employee_id, club_id, employee_type, cv_file, years_of_experience)
VALUES
(1, 1, 'MANAGER', NULL, 10),
(2, 2, 'COACH', NULL, 5),
(3, 1, 'RECEPTIONIST', NULL, 3),
(4, 2, 'ACCOUNTANT', NULL, 7),
(5, 3, 'MANAGER', NULL, 12),
(6, 4, 'COACH', NULL, 6),
(7, 5, 'RECEPTIONIST', NULL, 4),
(8, 3, 'ACCOUNTANT', NULL, 8),
(9, 4, 'SECRETARY', NULL, 5),
(10, 5, 'ADMIN', NULL, 9);

-- Insert sample data into Request
INSERT INTO Request (status, type, to_become, req_club_id, req_user_id, req_child_id, request_date)
VALUES
('PENDING', 'SIMPLE', 'MEMBER', 1, 1, NULL, '2023-06-01 08:00:00'),
('APPROVED', 'KID', 'ATHLETE', 2, 2, 3, '2023-06-02 10:00:00'),
('REJECTED', 'SIMPLE', 'MEMBER', 1, 3, NULL, '2023-06-03 12:00:00'),
('PENDING', 'KID', 'ATHLETE', 2, 4, 5, '2023-06-04 14:00:00'),
('PENDING', 'SIMPLE', 'MEMBER', 3, 1, NULL, '2023-06-05 08:00:00'),
('APPROVED', 'KID', 'ATHLETE', 4, 2, 4, '2023-06-06 10:00:00'),
('REJECTED', 'SIMPLE', 'MEMBER', 5, 3, NULL, '2023-06-07 12:00:00'),
('PENDING', 'KID', 'ATHLETE', 3, 4, 5, '2023-06-08 14:00:00'),
('PENDING', 'SIMPLE', 'MEMBER', 4, 6, NULL, '2023-06-09 08:00:00'),
('APPROVED', 'KID', 'ATHLETE', 5, 7, 8, '2023-06-10 10:00:00'),
('REJECTED', 'SIMPLE', 'MEMBER', 3, 9, NULL, '2023-06-11 12:00:00'),
('PENDING', 'KID', 'ATHLETE', 2, 10, 11, '2023-06-12 14:00:00'),
('PENDING', 'SIMPLE', 'MEMBER', 1, 12, NULL, '2023-06-13 08:00:00'),
('APPROVED', 'KID', 'ATHLETE', 2, 13, 14, '2023-06-14 10:00:00'),
('REJECTED', 'SIMPLE', 'MEMBER', 3, 15, NULL, '2023-06-15 12:00:00');
