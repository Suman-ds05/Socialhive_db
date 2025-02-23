SHOW DATABASES;
CREATE DATABASE socialhive_db;
USE socialhive_db;
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(255),
    email VARCHAR(255),
    created_at DATETIME
);
CREATE TABLE posts (
    post_id INT PRIMARY KEY,
    user_id INT,
    content TEXT,
    created_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE TABLE likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    post_id INT,
    liked_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id)
);
CREATE TABLE messages (
    message_id VARCHAR(50) PRIMARY KEY,
    sender_id INT,
    receiver_id INT,
    content TEXT,
    sent_at DATETIME,
    FOREIGN KEY (sender_id) REFERENCES users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES users(user_id)
);
LOAD DATA INFILE '/path/to/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'C:/your/file/path/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT * FROM users LIMIT 5;
SELECT * FROM posts LIMIT 5;
SHOW TABLES;
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM posts;
SELECT COUNT(*) FROM likes;
SELECT COUNT(*) FROM messages;
USE socialhive_db;
SHOW TABLES;
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM posts;
SELECT COUNT(*) FROM likes;
SELECT COUNT(*) FROM messages;
SELECT DISTINCT user_id 
FROM (
    SELECT user_id FROM posts
    UNION 
    SELECT user_id FROM likes
    UNION 
    SELECT sender_id FROM messages
) AS active_users;
SELECT post_id, user_id, content, created_at
FROM posts
WHERE post_id NOT IN (SELECT post_id FROM likes);
SELECT l.user_id, l.post_id, l.liked_at
FROM likes l
WHERE l.liked_at = (
    SELECT MIN(l2.liked_at)
    FROM likes l2
    WHERE l2.user_id = l.user_id
);
SELECT p.post_id, u.username, COUNT(l.like_id) AS total_likes
FROM posts p
JOIN users u ON p.user_id = u.user_id
JOIN likes l ON p.post_id = l.post_id
GROUP BY p.post_id, u.username
ORDER BY total_likes DESC
LIMIT 5;
SELECT u.user_id, u.username, COUNT(l.like_id) AS total_likes
FROM users u
JOIN posts p ON u.user_id = p.user_id
JOIN likes l ON p.post_id = l.post_id
WHERE u.user_id NOT IN (
    SELECT sender_id FROM messages 
    UNION 
    SELECT receiver_id FROM messages
)
GROUP BY u.user_id, u.username
HAVING total_likes > 0
ORDER BY total_likes DESC;
SELECT sender_id, receiver_id, COUNT(*) AS message_count
FROM messages
GROUP BY sender_id, receiver_id
HAVING message_count > 3;
SELECT 
    YEAR(created_at) AS year,
    WEEK(created_at) AS week_number,
    COUNT(DISTINCT p.post_id) AS total_posts,
    COUNT(l.like_id) AS total_likes
FROM posts p
LEFT JOIN likes l ON p.post_id = l.post_id
GROUP BY year, week_number
HAVING total_posts > 50
ORDER BY year DESC, week_number DESC;
SELECT l.user_id, l.post_id, l.liked_at, p.created_at
FROM likes l
JOIN posts p ON l.post_id = p.post_id
WHERE TIMESTAMPDIFF(MINUTE, p.created_at, l.liked_at) <= 5;
SELECT 
    u.user_id, 
    u.username, 
    (COUNT(DISTINCT p.post_id) * 2 + 
     COUNT(DISTINCT l.like_id) * 1 + 
     COUNT(DISTINCT m.message_id) * 1) AS contribution_score
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
LEFT JOIN likes l ON u.user_id = l.user_id
LEFT JOIN messages m ON u.user_id = m.sender_id
GROUP BY u.user_id, u.username
ORDER BY contribution_score DESC;
SELECT u.user_id, u.username
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
LEFT JOIN likes l ON u.user_id = l.user_id
LEFT JOIN messages m1 ON u.user_id = m1.sender_id
LEFT JOIN messages m2 ON u.user_id = m2.receiver_id
WHERE p.user_id IS NULL 
AND l.user_id IS NULL 
AND m1.sender_id IS NULL 
AND m2.receiver_id IS NULL;
SELECT 
    YEAR(p.created_at) AS year,
    WEEK(p.created_at) AS week_number,
    COUNT(p.post_id) AS total_posts,
    COUNT(l.like_id) AS total_likes
FROM posts p
LEFT JOIN likes l ON p.post_id = l.post_id
GROUP BY year, week_number
HAVING total_posts > 50
ORDER BY year DESC, week_number DESC;


