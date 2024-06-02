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
