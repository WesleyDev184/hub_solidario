-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.


CREATE TABLE `orthopedic_bank` (
    `id` UUID  NOT NULL ,
    `name` VARCHAR(255)  NOT NULL ,
    `city` VARCHAR(255)  NOT NULL ,
    `created_at` TIMESTAMP  NOT NULL ,
    `updated_at` TIMESTAMP  NOT NULL ,
    PRIMARY KEY (
        `id`
    )
);

CREATE TABLE `users` (
    `id` UUID  NOT NULL ,
    `name` VARCHAR(255)  NOT NULL ,
    `email` VARCHAR(255)  NOT NULL ,
    `password` TEXT  NOT NULL ,
    `phone` VARCHAR(20)  NULL ,
    `orthopedic_bank_id` UUID  NOT NULL ,
    `created_at` TIMESTAMP  NULL ,
    `updated_at` TIMESTAMP  NULL ,
    PRIMARY KEY (
        `id`
    )
);

CREATE TABLE `applicants` (
    `id` UUID  NOT NULL ,
    `name` VARCHAR(255)  NOT NULL ,
    `cpf` VARCHAR(14)  NOT NULL ,
    `phone` VARCHAR(20)  NULL ,
    `email` VARCHAR(255)  NOT NULL ,
    `address` TEXT  NULL ,
    `created_at` TIMESTAMP  NOT NULL ,
    `updated_at` TIMESTAMP  NOT NULL ,
    PRIMARY KEY (
        `id`
    )
);

CREATE TABLE `beneficiaries` (
    `id` UUID  NOT NULL ,
    `applicant_id` UUID  NOT NULL ,
    `is_beneficiary` BOOLEAN  NOT NULL ,
    `name` VARCHAR(255)  NOT NULL ,
    `cpf` VARCHAR(14)  NOT NULL ,
    `phone` VARCHAR(20)  NOT NULL ,
    `created_at` TIMESTAMP  NOT NULL ,
    `updated_at` TIMESTAMP  NOT NULL ,
    PRIMARY KEY (
        `id`
    )
);

CREATE TABLE `stock` (
    `id` UUID  NOT NULL ,
    -- enum
    `type` VARCHAR(255)  NOT NULL ,
    `maintenance_qtd` INT  NOT NULL ,
    `available_qtt` INT  NOT NULL ,
    `borrowed_qtd` INT  NOT NULL ,
    `created_at` TIMESTAMP  NOT NULL ,
    `updated_at` TIMESTAMP  NOT NULL ,
    PRIMARY KEY (
        `id`
    )
);

CREATE TABLE `item` (
    `id` UUID  NOT NULL ,
    `serial_code` INT  NOT NULL ,
    -- enum
    `status` VARCHAR(255)  NOT NULL ,
    `stock_id` UUID  NOT NULL ,
    `created_at` TIMESTAMP  NOT NULL ,
    `updated_at` TIMESTAMP  NOT NULL ,
    PRIMARY KEY (
        `id`
    )
);

CREATE TABLE `loans` (
    `id` UUID  NOT NULL ,
    `applicant_id` UUID  NOT NULL ,
    `responsible` UUID  NOT NULL ,
    `stock_id` UUID  NOT NULL ,
    `return_date` TIMESTAMP  NOT NULL ,
    `reason` TEXT  NOT NULL ,
    `loaned` BOOLEAN  NOT NULL ,
    `created_at` TIMESTAMP  NOT NULL ,
    `updated_at` TIMESTAMP  NOT NULL ,
    PRIMARY KEY (
        `id`
    )
);

ALTER TABLE `users` ADD CONSTRAINT `fk_users_orthopedic_bank_id` FOREIGN KEY(`orthopedic_bank_id`)
REFERENCES `orthopedic_bank` (`id`);

ALTER TABLE `beneficiaries` ADD CONSTRAINT `fk_beneficiaries_applicant_id` FOREIGN KEY(`applicant_id`)
REFERENCES `applicants` (`id`);

ALTER TABLE `item` ADD CONSTRAINT `fk_item_stock_id` FOREIGN KEY(`stock_id`)
REFERENCES `stock` (`id`);

ALTER TABLE `loans` ADD CONSTRAINT `fk_loans_applicant_id` FOREIGN KEY(`applicant_id`)
REFERENCES `applicants` (`id`);

ALTER TABLE `loans` ADD CONSTRAINT `fk_loans_responsible` FOREIGN KEY(`responsible`)
REFERENCES `users` (`id`);

ALTER TABLE `loans` ADD CONSTRAINT `fk_loans_stock_id` FOREIGN KEY(`stock_id`)
REFERENCES `stock` (`id`);

