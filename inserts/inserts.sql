-- Insert sample data into Person table
INSERT INTO Person (first_name, last_name, email, phone, address, start_date)
VALUES
('John', 'Doe', 'john.doe@example.com', '123-456-7890', '123 Main St', '2023-01-01 09:00:00'),
('Jane', 'Smith', 'jane.smith@example.com', '123-456-7891', '456 Elm St', '2023-01-02 10:00:00'),
('Emily', 'Johnson', 'emily.johnson@example.com', '123-456-7892', '789 Oak St', '2023-01-03 11:00:00');

-- Insert sample data into Guest table
INSERT INTO Guest (person_id, visit_date, membership_status)
VALUES
(1, '2023-02-01 09:00:00', 'MEMBER'),
(2, '2023-02-02 10:00:00', 'GUEST'),
(3, '2023-02-03 11:00:00', 'MEMBER');

-- Insert sample data into TennisClub table
INSERT INTO TennisClub (name, description, address, email, website, latitude, longitude, start_for_public, end_for_public)
VALUES
('City Tennis Club', 'A premier tennis club in the city', '789 Park Ave', 'contact@citytennisclub.com', 'www.citytennisclub.com', 40.712800, -74.006000, '2023-03-01 09:00:00', '2023-12-31 18:00:00'),
('Suburban Tennis Club', 'A friendly suburban tennis club', '123 Country Rd', 'info@suburbantennisclub.com', 'www.suburbantennisclub.com', 40.123400, -74.567800, '2023-03-01 09:00:00', '2023-12-31 18:00:00'),
('Beachside Tennis Club', 'Enjoy tennis by the beach', '789 Ocean Dr', 'info@beachsidetennisclub.com', 'www.beachsidetennisclub.com', 36.778300, -119.417900, '2023-03-01 09:00:00', '2023-12-31 18:00:00');

-- Insert sample data into courts table
INSERT INTO courts (title, field_type, status, covered, athlete_capacity, only_for_members, equipment, equipment_price, public_equipment, court_price, club_id)
VALUES
('Court 1', 'CLAY', 'AVAILABLE', TRUE, 4, TRUE, TRUE, 15.00, FALSE, 50.00, 1),
('Court 2', 'GRASS', 'MAINTENANCE', FALSE, 4, FALSE, FALSE, 0.00, TRUE, 45.00, 1),
('Court 3', 'HARD', 'AVAILABLE', FALSE, 6, TRUE, TRUE, 10.00, TRUE, 55.00, 2),
('Court 4', 'CARPET', 'AVAILABLE', TRUE, 5, FALSE, TRUE, 12.00, FALSE, 60.00, 3);

-- Insert sample data into ClubsPhone table
INSERT INTO ClubsPhone (phone, club_id)
VALUES
('123-456-7893', 1),
('123-456-7894', 2),
('123-456-7895', 3);

-- Insert sample data into court_reservations table
INSERT INTO court_reservations (type, status, start_date, end_date, no_people, court_id, equipment, guest_id, club_id)
VALUES
('RESERVATION', 'PENDING', '2023-04-01 09:00:00', '2023-04-01 10:00:00', 2, 1, TRUE, 1, 1),
('SESSION', 'COMPLETED', '2023-04-02 11:00:00', '2023-04-02 12:00:00', 4, 2, FALSE, 2, 1),
('RESERVATION', 'CANCELLED', '2023-04-03 13:00:00', '2023-04-03 14:00:00', 3, 3, TRUE, 3, 2),
('RESERVATION', 'PENDING', '2023-04-04 15:00:00', '2023-04-04 16:00:00', 2, 4, FALSE, 1, 3);

-- Insert sample data into Request table
INSERT INTO Request (status, type, to_become, club_id, guest_id, identification, doctors_note, solemn_dec, full_name, first_name, last_name, phone, address, birth_date, email)
VALUES
('PENDING', 'SIMPLE', 'MEMBER', 1, 1, NULL, NULL, NULL, 'John Doe', 'John', 'Doe', '123-456-7890', '123 Main St', '1980-01-01', 'john.doe@example.com'),
('APPROVED', 'KID', 'ATHLETE', 2, 2, NULL, NULL, NULL, 'Jane Smith', 'Jane', 'Smith', '123-456-7891', '456 Elm St', '2005-02-02', 'jane.smith@example.com'),
('REJECTED', 'SIMPLE', 'MEMBER', 3, 3, NULL, NULL, NULL, 'Emily Johnson', 'Emily', 'Johnson', '123-456-7892', '789 Oak St', '1995-03-03', 'emily.johnson@example.com');

