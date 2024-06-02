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
