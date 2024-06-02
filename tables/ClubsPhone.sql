drop table if exists ClubsPhone;
create table if not exists ClubsPhone(
    club_phone varchar(255) primary key not null ,
    club_id int not null ,
    FOREIGN KEY (club_id) REFERENCES TennisClub(club_id) on delete cascade
);
