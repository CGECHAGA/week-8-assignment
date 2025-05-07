CREATE DATABASE task_manager;
USE task_manager;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    passwords VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE tasks (
    task_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    status enum('Pending', 'In Progress', 'Completed') DEFAULT 'Pending',
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT task_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

INSERT INTO users (user_name, email, passwords) VALUES
('j_muchiri', 'jmuchiri@gmail.com', 'mugavi@123'),
('j_smith', 'jsmith@gmail.com', 'smuffs@34*'),
('a_mumbi', 'amumbi@gmail.com', 'candie@4*'),
('c_wandia', 'cwandia@gmail.com', 'fafa@3*'),
('m_muthia', 'mmuthia@gmail.com', 'richy@7*');

INSERT INTO tasks (user_id, title, description, status, due_date) VALUES
(1, 'Complete project', 'Finish the API implementation', 'In Progress', '2023-12-15'),
(1, 'Buy groceries', 'Milk, eggs, bread', 'Pending', '2023-11-20'),
(2, 'Schedule meeting', 'With the development team', 'Completed', '2022-11-10');
