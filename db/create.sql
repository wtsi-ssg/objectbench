drop table if exists job ;
CREATE TABLE `job` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` enum('ddn','cleversafe','null') DEFAULT NULL,
  `operation` enum('read','write','partial_read') DEFAULT NULL,
  `size` int(11) NOT NULL,
  `length` int(11) NOT NULL,
  `reference_file` varchar(2048) NOT NULL,
  `md5sum` varchar(80) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;
