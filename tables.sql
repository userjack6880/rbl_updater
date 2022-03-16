CREATE TABLE `asn_blocklist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `asn` int(10) unsigned NOT NULL,
  `blocked_ranges` int(10) unsigned NOT NULL,
  `total_ranges` int(10) unsigned NOT NULL,
  `infractions` int(10) unsigned NOT NULL,
  `infractions_type` tinyint(4) NOT NULL,
  `permaban` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `asn` (`asn`)
)

CREATE TABLE `ip_blocklist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip4` int(10) unsigned NOT NULL,
  `ip4_net` varchar(20) NOT NULL,
  `infractions` int(10) unsigned NOT NULL,
  `infractions_type` tinyint(4) NOT NULL,
  `ban_expiration` datetime NOT NULL,
  `permaban` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ip4` (`ip4`)
)

CREATE TABLE `ipnet_blocklist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip4_net` varchar(20) NOT NULL,
  `asn` int(11) DEFAULT NULL,
  `infractions` int(10) unsigned NOT NULL,
  `infractions_type` tinyint(4) NOT NULL,
  `ban_expiration` datetime NOT NULL,
  `permaban` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ip4_net` (`ip4_net`),
)
