drop table if exists Guest;

CREATE TABLE if not exists Guest (
    id INT AUTO_INCREMENT PRIMARY KEY,
    person_id INT,
    visit_date DATETIME,
    membership_status VARCHAR(50),
    FOREIGN KEY (person_id) REFERENCES Person(id) on delete cascade
);