CREATE DATABASE elearning_system;

CREATE TABLE users ( 
user_id INT auto_increment PRIMARY KEY, 
user_name VARCHAR(50) UNIQUE NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
passwords VARCHAR(255) NOT NULL,
first_name VARCHAR(50) NOT NULL, 
last_name VARCHAR(50) NOT NULL, 
date_of_birth DATE, 
profile_picture VARCHAR(255),
bio TEXT, 
user_type ENUM('Student', 'Instructor', 'Admin') NOT NULL, 
last_login DATETIME, 
account_status ENUM('Active', 'Suspended', 'Banned') DEFAULT 'Active', 
CONSTRAINT checkemail CHECK (email LIKE 'johndoe@student.cuk.ke') );

create table Courses  ( 
course_id INT auto_increment PRIMARY KEY,
title VARCHAR(100) NOT NULL, description TEXT,
instructor_id INT NOT NULL, category VARCHAR(50), 
 difficulty_level ENUM('Beginner', 'Intermediate', 'Advanced') DEFAULT 'Beginner',
 price DECIMAL(10,2) DEFAULT 0.00
  );

CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    completion_status ENUM('Not Started', 'In Progress', 'Completed') DEFAULT 'Not Started',
    completion_date DATETIME,
    grade DECIMAL(5,2),
    CONSTRAINT enrollment_student FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT enrollment_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    CONSTRAINT student_course UNIQUE (student_id, course_id),
    CONSTRAINT check_grade CHECK (grade IS NULL OR (grade >= 0 AND grade <= 100)));

CREATE TABLE modules (
    module_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    sequence_order INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT module_course FOREIGN KEY (course_id) REFERENCES courses(course_id),
    CONSTRAINT course_module_order UNIQUE (course_id, sequence_order)
);

CREATE TABLE lessons (
    lesson_id INT AUTO_INCREMENT PRIMARY KEY,
    module_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    content_type ENUM('Video', 'Text', 'Quiz', 'Assignment') NOT NULL,
    content_url VARCHAR(255),
    text_content TEXT,
    duration_minutes INT,
    sequence_order INT NOT NULL,
    is_free_preview BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT lesson_module FOREIGN KEY (module_id) REFERENCES modules(module_id),
    CONSTRAINT module_lesson_order UNIQUE (module_id, sequence_order)
);

CREATE TABLE quizzes (
    quiz_id INT AUTO_INCREMENT PRIMARY KEY,
    lesson_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    passing_score INT DEFAULT 70,
    max_attempts INT DEFAULT 1,
    time_limit_minutes INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT quiz_lesson FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id)
);

CREATE TABLE assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    lesson_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    max_points INT DEFAULT 100,
    due_date DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT assignment_lesson FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id)
);
CREATE TABLE forums (
    forum_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT forum_course FOREIGN KEY (course_id) REFERENCES courses(course_id)
);


 INSERT INTO users (user_name, email, passwords, first_name, last_name, date_of_birth, user_type) VALUES
('J_MUCHIRI', 'Jmuchiri@elearning.com', 'muchira_2090', 'john', 'muchiri', '1980-01-01', 'Admin'),
('prof_john', 'jmwangemi@university.edu', 'hunny$2034', 'John', 'mwangemi', '1975-05-15', 'Instructor'),
('s_smith', 'jsmith@university.edu', 'smithes@167', 'Jane', 'Smith', '1982-08-22', 'Instructor'),
('m_johnson', 'mjohnson@student.edu', 'smuffs@340', 'Michael', 'Johnson', '2000-03-10', 'Student'),
('s_williams', 'swilliams@student.edu', 'john@90', 'Sarah', 'Williams', '1999-11-25', 'Student');

INSERT INTO courses (title, description, instructor_id, category, difficulty_level, price) VALUES
('Introduction to Programming', 'Learn the fundamentals of programming with Python', 2, 'Computer Science', 'Beginner', 4999),
('Data Science Fundamentals', 'Essential concepts for data analysis and visualization', 3, 'Data Science', 'Intermediate', 7999),
('Web Development Bootcamp', 'Full-stack web development with HTML, CSS, and JavaScript', 2, 'Web Development', 'Beginner', 5999),
('Advanced Machine Learning', 'Deep learning and neural networks', 3, 'Artificial Intelligence', 'Advanced', 9999);

INSERT INTO enrollments (student_id, course_id, enrollment_date, completion_status) VALUES
(4, 1, '2023-01-15 10:00:00', 'In Progress'),
 (5, 1, '2023-01-20 09:15:00', 'Completed'),
 (5, 3, '2023-03-05 11:45:00', 'In Progress');

 INSERT INTO modules (course_id, title, description, sequence_order) VALUES
(1, 'Getting Started', 'Introduction to programming concepts', 1),
(1, 'Python Basics', 'Variables, data types, and operators', 2),
(1, 'Control Flow', 'Conditionals and loops', 3),
(1, 'Functions', 'Creating and using functions', 4);

INSERT INTO lessons (module_id, title, content_type, sequence_order, duration_minutes) VALUES
(1, 'Variables and Data Types', 'Video', 1, 15),
(2, 'Operators', 'Video', 2, 12),
(3, 'Database', 'Video', 2, 12),
(5, 'pitch-desk', 'Video', 2, 12),


INSERT INTO quizzes (lesson_id, title, passing_score, max_attempts, time_limit_minutes) VALUES
(4, 'Variables and Data Types Quiz', 70, 3, 15),
(3, ' Data Types Quiz', 70, 3, 15),
(2, 'Python', 70, 3, 15),
(1, 'software development', 70, 3, 15);

INSERT INTO assignments (lesson_id, title, description, max_points, due_date) VALUES
(3, 'Variables Practice', 'Complete the exercises in the attached notebook', 100, '2023-04-15 23:59:00'),
(4, 'sofware development', 'Complete the exercises in the attached notebook', 100, '2023-05-15 23:59:00'),
(1, 'python', 'Complete the exercises in the attached notebook', 100, '2023-06-15 23:59:00'),
(2, 'database', 'Complete the exercises in the attached notebook', 100, '2023-07-15 23:59:00');

INSERT INTO forums (course_id, title, description) VALUES
(1, 'General Discussion', 'Ask questions and discuss course topics'),
(1, 'Q&A', 'Get help with specific problems');



















