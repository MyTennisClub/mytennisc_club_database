drop table if exists Person;

CREATE TABLE if not exists Person (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(100),
    phone VARCHAR(50),
    address VARCHAR(255),
    start_date DATETIME
);


