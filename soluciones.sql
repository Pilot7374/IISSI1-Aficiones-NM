USE hobbies_nm_db;

DELIMITER //
CREATE OR REPLACE FUNCTION f_get_hobby_id(p_hobby_name VARCHAR(128)
RETURNS INT 
READS SQL DATA 
BEGIN
	DECLARE v_hobby_id INT;
	SELECT MIN (h.hobby_id) INTO v_hobby_id
	FROM hobbies h
	WHERE h.hobby_name*p_hobby_name;
	
	RETURN v_hobby_id;
END //
DELIMITER ;

--comprobacion 
SELECT f_gethobby_id("Cine") as cine , f_get_hobby_id("Ajedrez") AS ajedrez





--una aqui que no copie



DELIMITER //

CREATE OR REPLACE FUNCTION f_hobby_users(p_hobby_id INT)
RETURNS INT 
READS SQL DATA 
BEGIN 
	DECLARE v_users INT;
	
	SELECT COUNT(*) INTO v_users
	FROM users_hobbies uh
	WHERE uh.hobby_id


DELIMITER //
CREATE OR REPLACE PROCEDURE p_add_hobby_to_users(
	IN p_users_id INT,
	IN p_hobby_name VARCHAR(128)
)
BEGIN
	DECLARE v_hobby_id INT;
	
	SET v_hobby_id = f_get_hobby_id(p_hobby_name);
	
	if EXISTS(
		SELECT *
		FROM users_hobbies uh
		WHERE uh.user_id = p_users_id
			AND uh.hobby_id = v_hobby_id
			)THEN
				SIGNAL SQLSTATE "45000"
					SET MESSAGE_TEXT = "RN03:El usuario ya tiene esa aficion";
	END IF;
	
	IF v_hobby_id IS NULL THEN
		INSERT INTO hobbies (hobby_name) VALUES (p_hobby_name);
		SET v_hobby_id = LAST_INSERT_ID();
	END IF;
	
	INSERT INTO users_hobbies(uset_id, hobby_id) VALUES (p_user_id, v_hobby_id);
END //
CALL p_populate();
DELIMITER ; 

SELECT uh.users_id, h_hobby_name
FROM users_hobbies uh
JOIN hobbies h ON h.hobby_id = uh.hobby_id
WHERE uh.user_id = 1;

CALL p_add_hobby_to_user(1, "Cine");

SELECT uh.users_id, h_hobby_name
FROM users_hobbies uh
JOIN hobbies h ON h.hobby_id = uh.hobby_id
WHERE uh.user_id = 1;
SELECT COUNT(*) AS hobbies_in_catalog
FROM hobbies h;	


DELIMITER //
CREATE OR REPLACE PROCEDURE p_add_hobby_to_users_ts(
	IN p_user_id INT,
	IN p_hobby_name VARCHAR(128)
)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		RESIGNAL;
	END;
	START TRANSACTION;
		CALL  p_add_hobby_to_user(p_user_id, p_hobby_name);
	COMMIT;
END //
DELIMITER ; 

CALL p_add_hobby_to_users_ts(3, "Ajedrez");

SELECT uh.users_id, h.hobby_id, h.hobby_name
FROM users_hobbies uh
JOIN hobbies h ON h.hobby_id = uh.hobby_id
WHERE uh.users_id = 3;

CALL p_add_hobby_to_users_ts(3, "Ajedrez");

SELECT uh.users_id, h.hobby_id, h.hobby_name
FROM users_hobbies uh
JOIN hobbies h ON h.hobby_id = uh.hobby_id
WHERE uh.users_id = 3;



