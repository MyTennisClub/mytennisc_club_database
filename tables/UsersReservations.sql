drop table if exists Users_Reservations;
create table if not exists Users_Reservations(
    user_id int,
    res_id bigint,
    absence BOOL DEFAULT false,
    PRIMARY KEY (user_id, res_id),
    FOREIGN KEY (user_id) REFERENCES SimpleUsers(user_id) on delete cascade on update cascade,
    FOREIGN KEY (res_id) REFERENCES CourtReservations(res_id) on delete cascade on update cascade
);
