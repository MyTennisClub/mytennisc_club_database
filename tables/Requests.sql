drop table if exists Request;

-- Create the Request table
CREATE TABLE Request (
    req_id INT AUTO_INCREMENT PRIMARY KEY,
    status ENUM('PENDING', 'APPROVED', 'REJECTED'),
    type ENUM('SIMPLE','KID'),
    to_become ENUM('MEMBER','ATHLETE'),
    club_id INT,
    guest_id INT,
    identification BLOB,
    doctors_note BLOB,
    solemn_dec BLOB,
    full_name  VARCHAR(255),
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    phone VARCHAR(50),
    address VARCHAR(255),
    birth_date DATE,
    email VARCHAR(100),
    request_date DATETIME,
    FOREIGN KEY (guest_id) REFERENCES Guest(id),
    FOREIGN KEY (club_id) REFERENCES TennisClub(id)
);