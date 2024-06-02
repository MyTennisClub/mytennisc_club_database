drop database if exists mytennis_local;
create database if not exists mytennis_local;
use mytennis_local;

drop table if exists SimpleUsers;
CREATE TABLE if not exists SimpleUsers (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    user_first_name VARCHAR(255) not null,
    user_last_name VARCHAR(255) not null,
    user_birth_date DATE not null,
    user_email VARCHAR(100) not null,
    user_phone VARCHAR(50) not null,
    user_address VARCHAR(255) not null,
    user_identification_file BLOB,
    user_doctors_file BLOB,
    user_solemn_declaration_file BLOB,
    user_has_children BOOLEAN not null default false,
    user_acc_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    referred_by INT,
    FOREIGN KEY (referred_by) REFERENCES SimpleUsers(user_id) on delete set null
);

drop table if exists TennisClub;
CREATE TABLE if not exists TennisClub (
    club_id INT AUTO_INCREMENT PRIMARY KEY,
    club_name VARCHAR(255),
    club_description TEXT,
    club_address VARCHAR(255),
    club_email VARCHAR(255),
    club_website VARCHAR(255),
    club_latitude DECIMAL(9,6) NOT NULL,
    club_longitude DECIMAL(9,6) NOT NULL,
    club_start_time time NOT NULL,
    club_end_time time NOT NULL,
    club_start_for_public time NOT NULL,
    club_end_for_public time NOT NULL,
    club_max_people_court  int not null DEFAULT 0
);

drop table if exists ClubsPhone;
create table if not exists ClubsPhone(
    club_phone varchar(255) primary key not null ,
    club_id int not null ,
    FOREIGN KEY (club_id) REFERENCES TennisClub(club_id) on delete cascade
);

drop table if exists Clubs_Users;
create table if not exists Clubs_Users(
    club_id int,
    user_id int,
    user_type ENUM('GUEST','ATHLETE','MEMBER') not null,
    review_date  DATE,
    review_stars INT,
    review_description TEXT,
    review_likes INT DEFAULT 0,
    review_check BOOL DEFAULT FALSE,
    PRIMARY KEY (club_id, user_id),
    FOREIGN KEY (club_id) REFERENCES TennisClub(club_id) on delete cascade,
    FOREIGN KEY (user_id) REFERENCES SimpleUsers(user_id) on delete cascade
);

drop table if exists Employees_Clubs;
create table if not exists Employees_Clubs(
    employee_id int,
    club_id int,
    employee_type ENUM('MANAGER','COACH','RECEPTIONIST', 'ACCOUNTANT', 'ADMIN', 'SECRETARY') not null,
    cv_file BLOB,
    years_of_experience INT,
    PRIMARY KEY (employee_id, club_id),
    FOREIGN KEY (employee_id) REFERENCES SimpleUsers(user_id) on delete cascade,
    FOREIGN KEY (club_id) REFERENCES TennisClub(club_id) on delete cascade
);

DROP TABLE IF EXISTS Courts;
CREATE TABLE IF NOT EXISTS Courts(
    court_id INT AUTO_INCREMENT PRIMARY KEY,
    court_title VARCHAR(255) NOT NULL,
    field_type ENUM('CLAY', 'GRASS', 'HARD', 'CARPET') NOT NULL,
    court_status ENUM('AVAILABLE', 'MAINTENANCE') NOT NULL,
    court_covered BOOLEAN NOT NULL,
    court_athlete_capacity INT NOT NULL,
    court_only_for_members BOOLEAN NOT NULL,
    court_equipment BOOLEAN NOT NULL,
    court_equipment_price DECIMAL(10, 2) NOT NULL,
    court_public_equipment BOOLEAN NOT NULL,
    court_price DECIMAL(10, 2) NOT NULL,
    court_club_id INT,
    constraint court_club FOREIGN KEY (court_club_id) REFERENCES TennisClub(club_id) on delete cascade on update cascade
);


DROP TABLE IF EXISTS CourtReservations;
CREATE TABLE IF NOT EXISTS CourtReservations(
    res_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    res_type ENUM('RESERVATION', 'SESSION') NOT NULL,
    res_status ENUM('PENDING', 'COMPLETED', 'CANCELLED') NOT NULL,
    res_start_date DATETIME NOT NULL,
    res_end_date DATETIME NOT NULL,
    res_no_people INT NOT NULL,
    res_court_id INT,
    res_equipment BOOLEAN,
    res_club_id INT,
    res_secreatary_scaned INT,
    res_created_at DATETIME DEFAULT NOW(),
    res_completed_at DATETIME,
    res_cancelled_at DATETIME,
    res_scanded_at DATETIME,
    res_qr_code BLOB,
    CONSTRAINT  res_secretary FOREIGN KEY (res_secreatary_scaned) REFERENCES Employees_Clubs(employee_id),
    constraint res_club FOREIGN KEY (res_club_id) REFERENCES TennisClub(club_id) ON DELETE CASCADE on update cascade,
    constraint res_court FOREIGN KEY (res_court_id) REFERENCES Courts(court_id) ON DELETE CASCADE on update cascade
);
ALTER TABLE CourtReservations AUTO_INCREMENT=1000000;


ALTER TABLE CourtReservations AUTO_INCREMENT=1000000;

drop table if exists Users_Reservations;
create table if not exists Users_Reservations(
    user_id int,
    res_id bigint,
    absence BOOL DEFAULT false,
    PRIMARY KEY (user_id, res_id),
    FOREIGN KEY (user_id) REFERENCES SimpleUsers(user_id) on delete cascade on update cascade,
    FOREIGN KEY (res_id) REFERENCES CourtReservations(res_id) on delete cascade on update cascade
);

drop table if exists Request;
CREATE TABLE if not exists Request(
    req_id INT AUTO_INCREMENT PRIMARY KEY,
    status ENUM('PENDING', 'APPROVED', 'REJECTED'),
    type ENUM('SIMPLE','KID'),
    to_become ENUM('MEMBER','ATHLETE'),
    club_id INT,
    user_id INT,
    child_id INT,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES SimpleUsers(user_id) on delete cascade on update cascade,
    FOREIGN KEY (club_id) REFERENCES TennisClub(club_id) on delete cascade on update cascade
);

