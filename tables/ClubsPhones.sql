DROP TABLE if exists ClubsPhone;

create table if not exists ClubsPhone(
    phone varchar(255) primary key not null ,
    club_id int not null ,
    FOREIGN KEY (club_id) REFERENCES TennisClub(id) on delete cascade
);