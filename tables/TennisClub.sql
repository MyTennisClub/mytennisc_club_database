drop table if exists TennisClub;

CREATE TABLE if not exists TennisClub (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    description TEXT,
    address VARCHAR(255),
    email VARCHAR(255),
    website VARCHAR(255),
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    start_for_public DATETIME NOT NULL,
    end_for_public DATETIME NOT NULL
);
