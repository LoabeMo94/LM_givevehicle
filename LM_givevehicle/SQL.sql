CREATE TABLE `owned_vehicles` (
    `id` int NOT NULL AUTO_INCREMENT,
    `owner` varchar(50) NOT NULL,
    `plate` varchar(20) NOT NULL,
    `vehicle` json NOT NULL,
    `stored` int NOT NULL DEFAULT 1,
    `type` varchar(20) DEFAULT 'car',
    PRIMARY KEY (`id`)
);
