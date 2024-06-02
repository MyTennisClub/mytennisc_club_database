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
