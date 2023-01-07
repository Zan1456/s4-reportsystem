CREATE TABLE `reports` (
  `id` int(11) NOT NULL,
  `owner` text NOT NULL,
  `text` text NOT NULL,
  `pid` int(11) NOT NULL DEFAULT current_timestamp(),
  `datetime` date NOT NULL DEFAULT current_timestamp(),
  `rname` text NOT NULL,
  `identifier` text NOT NULL,
  `rip` int(11) NOT NULL,
  `uniqueid` bigint(20) NOT NULL,
  `img` text NOT NULL,
  `extends` text NOT NULL DEFAULT '#ff004c'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `reports_players` (
  `id` int(11) NOT NULL,
  `identifier` text NOT NULL,
  `points` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `reports`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `reports_players`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

START TRANSACTION;
ALTER TABLE `reports_players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

CREATE TABLE `reports_banlist` (
  `id` int(11) NOT NULL,
  `identifiers` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `reports_banlist`
  ADD PRIMARY KEY (`id`);

START TRANSACTION;
ALTER TABLE `reports_banlist`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;