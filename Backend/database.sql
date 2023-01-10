-- "BAMX" database v3.3.2
DROP DATABASE IF EXISTS BAMX;
CREATE DATABASE BAMX;
USE BAMX;

DROP TABLE IF EXISTS Donor;
CREATE TABLE Donor(
	donor_id INT NOT NULL AUTO_INCREMENT,
	donor_name CHAR(50),
    donor_city CHAR(50),
    donor_colony CHAR(50),
    donor_organization CHAR(100),
    donor_website1 CHAR(50),
    donor_website2 CHAR(50),
    donor_cfdi BLOB,

    PRIMARY KEY(donor_id)
);

DROP TABLE IF EXISTS Product;
CREATE TABLE Product(
	product_id INT NOT NULL AUTO_INCREMENT,
	product_name CHAR(25) NOT NULL,

    PRIMARY KEY(product_id)
);

DROP TABLE IF EXISTS DonorProduct;
CREATE TABLE DonorProduct(
	donation_id INT NOT NULL AUTO_INCREMENT,
	donor_id INT NOT NULL,
    product_id INT NOT NULL,
    donation_date TIMESTAMP,
    donation_observation CHAR(200),
    product_quantity FLOAT,
    product_unit CHAR(25),

    PRIMARY KEY(donation_id),
    FOREIGN KEY(donor_id) REFERENCES Donor(donor_id),
    FOREIGN KEY(product_id) REFERENCES Product(product_id)
);

DROP TABLE IF EXISTS DonorMail;
CREATE TABLE DonorMail(
	mail_id INT NOT NULL AUTO_INCREMENT,
	donor_id INT NOT NULL,
    donor_mail CHAR(100),

    PRIMARY KEY(mail_id),
    FOREIGN KEY(donor_id) REFERENCES Donor(donor_id)
);

DROP TABLE IF EXISTS DonorPhone;
CREATE TABLE DonorPhone(
	phone_id INT NOT NULL AUTO_INCREMENT,
	donor_id INT NOT NULL,
    donor_phone CHAR(15),

    PRIMARY KEY(phone_id),
    FOREIGN KEY(donor_id) REFERENCES Donor(donor_id)
);

DROP TABLE IF EXISTS DonorType;
CREATE TABLE DonorType(
	donor_id INT NOT NULL,
    type_id INT NOT NULL,

    PRIMARY KEY(donor_id, type_id),
    FOREIGN KEY(donor_id) REFERENCES Donor(donor_id),
    FOREIGN KEY(type_id)  REFERENCES Type(type_id)
);

DROP TABLE IF EXISTS Unit;
CREATE TABLE Unit(
	unit_name CHAR(25) NOT NULL,

    PRIMARY KEY(unit_name)
);

DROP TABLE IF EXISTS Type;
CREATE TABLE Type(
	type_id INT NOT NULL AUTO_INCREMENT,
    type_name CHAR(25),

    PRIMARY KEY(type_id)
);

DROP TABLE IF EXISTS Category;
CREATE TABLE Category(
	cat_id INT NOT NULL AUTO_INCREMENT,
    cat_name CHAR(25),

    PRIMARY KEY(cat_id)
);

DROP TABLE IF EXISTS DonorCategory;
CREATE TABLE DonorCategory(
    donor_id INT NOT NULL,
    category_id INT NOT NULL,

    FOREIGN KEY (donor_id) REFERENCES Donor(donor_id),
    FOREIGN KEY (category_id) REFERENCES Category(cat_id),
    PRIMARY KEY (donor_id, category_id)
);
-- -------------------------------------------------------------------

-- CRUD Procedures

-- Create a donor
DROP PROCEDURE IF EXISTS CreateDonor;
DELIMITER //
CREATE PROCEDURE CreateDonor (
    IN _jsonA JSON
)
BEGIN
    DECLARE _json JSON;
    DECLARE _idUsuario INT;
    DECLARE name CHAR(100);
    DECLARE city CHAR(100);
    DECLARE colony CHAR(100);
    DECLARE organization CHAR(100);
    DECLARE website1 CHAR(100);
    DECLARE website2 CHAR(100);
    DECLARE cfdi BLOB;
    DECLARE category INT;

    DECLARE types JSON;
    DECLARE tempType INT;
    DECLARE _count INT DEFAULT 0;
    DECLARE _index INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'ERROR!' AS 'RESULTADO';
        ROLLBACK;
    END ;

    SET _json = JSON_EXTRACT(_jsonA, '$[0]');
    SET name = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.name'));
    SET city = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.city'));
    SET colony = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.colony'));
    SET organization = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.organization'));
    SET website1 = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.website1'));
    SET website2 = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.website2'));
    SET cfdi = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.cfdi'));
    SET category = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.category'));
    SET types = JSON_EXTRACT(_json, '$.type');

    SET _count = JSON_LENGTH(types) - 1;

    START TRANSACTION ;

        IF (cfdi = 'null') THEN
            INSERT INTO Donor VALUES (0, name, city, colony, organization, website1, website2, null);
        ELSE
            INSERT INTO Donor VALUES (0, name, city, colony, organization, website1, website2, cfdi);
        END IF;
        SELECT LAST_INSERT_ID() INTO _idUsuario;
        IF((SELECT ROW_COUNT()) = 0) THEN
            SELECT CONCAT('No se pudo insertar el usuario') as 'STATUS';
            ROLLBACK ;
        END IF;

        INSERT INTO DonorCategory VALUES (_idUsuario, category);
        IF((SELECT ROW_COUNT()) = 0) THEN
                SELECT CONCAT('No se pudo agregar la categoria') as 'STATUS';
                ROLLBACK ;
            END IF;

        WHILE _count >= 0 DO
            SET _json = JSON_EXTRACT(types, CONCAT('$[',_index,']'));
            SET _index = _index + 1;
            SET tempType = JSON_UNQUOTE(JSON_EXTRACT(_json, '$.id'));
            INSERT INTO DonorType VALUES (_idUsuario, tempType);
        END WHILE ;

        SELECT 'Usuario agregado' AS 'STATUS';
    COMMIT ;


END //

DELIMITER ;

-- Add data contact to a donor
DROP PROCEDURE IF EXISTS AddPhoneToDonor;
DELIMITER //
CREATE PROCEDURE AddPhoneToDonor(
	donor_id INT,
	donor_phone CHAR(15)
)
BEGIN
	INSERT INTO DonorPhone VALUES(null, donor_id, donor_phone);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS AddMailToDonor;
DELIMITER //
CREATE PROCEDURE AddMailToDonor(
	donor_id INT,
    donor_mail CHAR(100)
)
BEGIN
	INSERT INTO DonorMail VALUES(null, donor_id, donor_mail);
END //
DELIMITER ;

-- Add products for donators
DROP PROCEDURE IF EXISTS AddProductForDonation;
DELIMITER //
CREATE PROCEDURE AddProductForDonation(
	new_product_name CHAR(25)
)
BEGIN

	IF NOT EXISTS (SELECT product_name FROM Product WHERE product_name = LOWER(new_product_name)) THEN
		INSERT INTO Product VALUES (null, LOWER(new_product_name));
	END IF;
END //
DELIMITER ;

-- Add a new unit
DROP PROCEDURE IF EXISTS AddDonationUnit;
DELIMITER //
CREATE PROCEDURE AddDonationUnit(
	unit_name CHAR(25)
)
BEGIN
	IF NOT EXISTS (SELECT Unit.unit_name FROM Unit WHERE Unit.unit_name = unit_name) THEN
		INSERT INTO Unit VALUES (LOWER(unit_name));
	END IF;
END //
DELIMITER ;

-- Add donation/products for a donor
DROP PROCEDURE IF EXISTS AddDonationToDonor;
DELIMITER //
CREATE PROCEDURE AddDonationToDonor(
	donor_id INT,
    product_name CHAR(25),
    donation_date TIMESTAMP,
    donation_observation CHAR(200),
    product_quantity FLOAT,
    product_unit CHAR(25)
)
BEGIN
	INSERT INTO DonorProduct VALUES(null, donor_id, product_name, donation_date, donation_observation, product_quantity, product_unit);
END //
DELIMITER ;

-- Delete donor from all tables
DROP PROCEDURE IF EXISTS DeleteDonor;
DELIMITER //
CREATE PROCEDURE DeleteDonor(
	donor_id INT
)
BEGIN
	IF EXISTS (SELECT * FROM DonorPhone WHERE DonorPhone.donor_id = donor_id) THEN
		DELETE FROM DonorPhone WHERE DonorPhone.donor_id = donor_id;
	END IF;
	IF EXISTS (SELECT * FROM DonorMail WHERE DonorMail.donor_id = donor_id) THEN
		DELETE FROM DonorMail WHERE DonorMail.donor_id = donor_id;
	END IF;
    IF EXISTS (SELECT * FROM DonorProduct WHERE DonorProduct.donor_id = donor_id) THEN
		DELETE FROM DonorProduct WHERE DonorProduct.donor_id = donor_id;
    END IF;
	DELETE FROM Donor WHERE Donor.donor_id = donor_id;
END //
DELIMITER ;

INSERT INTO bamx.category (cat_id, cat_name) VALUES (0, 'Bronce');
INSERT INTO bamx.category (cat_id, cat_name) VALUES (0, 'Plata');
INSERT INTO bamx.category (cat_id, cat_name) VALUES (0, 'Oro');
INSERT INTO bamx.category (cat_id, cat_name) VALUES (0, 'Diamante');

INSERT INTO bamx.type (type_id, type_name)  VALUES (0, 'Recurrente'),
                                                   (0, 'Por temporada'),
                                                   (0, 'Compra'),
                                                   (0, 'Prospecto');