drop table if exists Request;
CREATE TABLE if not exists Request(
    req_id INT AUTO_INCREMENT PRIMARY KEY,
    status ENUM('PENDING', 'APPROVED', 'REJECTED'),
    type ENUM('SIMPLE','KID'),
    to_become ENUM('MEMBER','ATHLETE'),
    req_club_id INT,
    req_user_id INT,
    req_child_id INT,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (req_user_id) REFERENCES SimpleUsers(user_id) on delete cascade on update cascade,
    FOREIGN KEY (req_club_id) REFERENCES TennisClub(club_id) on delete cascade on update cascade
);
