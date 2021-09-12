CREATE TABLE `whitelist` (
  `identifier` varchar(100) NOT NULL,
  `prenom` varchar(255) NOT NULL DEFAULT 'Inconnu'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `whitelist`
  ADD PRIMARY KEY (`identifier`);
COMMIT;