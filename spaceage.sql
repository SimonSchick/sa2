SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

DELIMITER $$

CREATE DEFINER=`root`@`localhost` FUNCTION `IntToSteam`(communityid bigint(64)) RETURNS varchar(64) CHARSET latin1
BEGIN
    declare ret varchar(64);
    declare authserver int;
    declare authid bigint;

    set communityid = communityid-76561197960265728;
    set authserver = mod(communityid,2);
    set communityid = communityid-authserver;
    set authid = communityid/2;
    set ret = concat("STEAM_0:",authserver,":",authid);
    return ret;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `SteamToInt`(steamid varchar(64)) RETURNS bigint(64)
BEGIN
    declare authserver int;
    declare authid int;

    set authserver = cast(substr(steamid,9,1) as unsigned integer);
    set authid = cast(substr(steamid,11) as unsigned integer);
    return 76561197960265728+(authid*2)+authserver;
END$$

DELIMITER ;

CREATE TABLE IF NOT EXISTS `saa_event` (
  `eventid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `event_name` varchar(64) NOT NULL,
  PRIMARY KEY (`eventid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `saa_group` (
  `groupid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `immunity` tinyint(3) unsigned NOT NULL,
  `red` tinyint(3) unsigned NOT NULL DEFAULT '255',
  `green` tinyint(3) unsigned NOT NULL DEFAULT '255',
  `blue` tinyint(3) unsigned NOT NULL DEFAULT '255',
  PRIMARY KEY (`groupid`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=10 ;


INSERT INTO `saa_group` (`groupid`, `name`, `immunity`, `red`, `green`, `blue`) VALUES
(1, 'Owner', 100, 255, 255, 255),
(2, 'Developer', 99, 255, 255, 255),
(3, 'Super Admin', 90, 255, 255, 255),
(4, 'Admin', 80, 255, 255, 255),
(5, 'Moderator', 70, 255, 255, 255),
(6, 'Special', 60, 255, 255, 255),
(7, 'VIP', 50, 255, 255, 255),
(8, 'Regular', 10, 255, 255, 255),
(9, 'Scum', 0, 255, 255, 255);

CREATE TABLE IF NOT EXISTS `saa_groupxpermission` (
  `groupid` int(10) unsigned NOT NULL,
  `permissionid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`groupid`,`permissionid`),
  KEY `permissionid` (`permissionid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `saa_permission` (
  `permissionid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `description` varchar(128) NOT NULL,
  PRIMARY KEY (`permissionid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `saa_playerxevent` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerid` int(10) unsigned NOT NULL,
  `eventid` int(10) unsigned NOT NULL,
  `timestamp` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `playerid` (`playerid`),
  KEY `eventid` (`eventid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `saa_playerxgroup` (
  `playerid` int(10) unsigned NOT NULL,
  `groupid` int(10) unsigned NOT NULL,
  `timestamp` int(10) unsigned NOT NULL,
  PRIMARY KEY (`playerid`,`groupid`,`timestamp`),
  KEY `groupid` (`groupid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `saa_playerxpermission` (
  `playerid` int(10) unsigned NOT NULL,
  `permissionid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`playerid`,`permissionid`),
  KEY `playerid` (`playerid`),
  KEY `permissionid` (`permissionid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_application` (
  `playerid` int(10) unsigned NOT NULL,
  `factionid` int(10) unsigned NOT NULL,
  `content` mediumblob NOT NULL,
  `creation_time` int(10) unsigned NOT NULL,
  PRIMARY KEY (`playerid`,`factionid`),
  KEY `factionid` (`factionid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_chatlog` (
  `playerid` int(10) unsigned NOT NULL,
  `serverid` tinyint(2) unsigned NOT NULL,
  `text` varchar(125) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL,
  UNIQUE KEY `playerid` (`playerid`,`serverid`,`timestamp`),
  KEY `serverid` (`serverid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_clienterror` (
  `reportid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `serverid` tinyint(2) unsigned NOT NULL,
  `playerid` int(10) unsigned NOT NULL,
  `timestamp` int(10) unsigned NOT NULL,
  `errorcrc` int(10) unsigned NOT NULL,
  `report` text NOT NULL,
  PRIMARY KEY (`reportid`),
  UNIQUE KEY `errorcrc` (`errorcrc`),
  KEY `playerid` (`playerid`),
  KEY `serverid` (`serverid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `sa_credit_transfer` (
  `senderid` int(10) unsigned NOT NULL,
  `receiverid` int(10) unsigned NOT NULL,
  `amount` bigint(20) unsigned NOT NULL,
  `timestamp` int(10) unsigned NOT NULL,
  PRIMARY KEY (`senderid`,`receiverid`,`timestamp`),
  KEY `receiverid` (`receiverid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_faction` (
  `factionid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `description` mediumblob NOT NULL,
  `red` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `green` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `blue` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`factionid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=7 ;

INSERT INTO `sa_faction` (`factionid`, `name`, `description`, `red`, `green`, `blue`) VALUES
(1, 'Major Miners', '', 128, 64, 0),
(2, 'The Corporation', '', 0, 150, 255),
(3, 'Freelancers', '', 158, 134, 97),
(4, 'Star Fleet', '', 210, 210, 210),
(5, 'The Legion', '', 85, 221, 34),
(6, 'The Alliance', '', 229, 33, 222);

CREATE TABLE IF NOT EXISTS `sa_faction_membership` (
  `playerid` int(10) unsigned NOT NULL,
  `factionid` int(10) unsigned NOT NULL,
  `join_time` int(10) unsigned NOT NULL,
  PRIMARY KEY (`playerid`,`factionid`,`join_time`),
  KEY `factionid` (`factionid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_friendship` (
  `playerid` int(10) unsigned NOT NULL,
  `friendid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`playerid`,`friendid`),
  KEY `friendid` (`friendid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_garrybans` (
  `64bit` bigint(20) unsigned NOT NULL,
  `normal` varchar(18) NOT NULL,
  PRIMARY KEY (`64bit`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_global_chatlog` (
  `playerid` int(10) unsigned NOT NULL,
  `serverid` tinyint(2) unsigned NOT NULL,
  `text` varchar(125) NOT NULL,
  `timestamp` int(10) unsigned NOT NULL,
  UNIQUE KEY `playerid` (`playerid`,`serverid`,`timestamp`),
  KEY `serverid` (`serverid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_passlog` (
  `steamid` bigint(20) NOT NULL,
  `pass` varbinary(32) NOT NULL,
  `ip` int(11) NOT NULL,
  `timestamp` int(11) NOT NULL,
  PRIMARY KEY (`steamid`,`pass`,`ip`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_player` (
  `backpack_capacity` int(10) unsigned NOT NULL DEFAULT '100',
  `playerid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `steamid` bigint(20) unsigned NOT NULL,
  `unique_token` binary(32) NOT NULL,
  `email` varchar(64) NOT NULL,
  `haswindows` tinyint(1) unsigned NOT NULL,
  `hasosx` tinyint(1) unsigned NOT NULL,
  `haslinux` tinyint(1) unsigned NOT NULL,
  `hasnotebook` tinyint(1) unsigned NOT NULL,
  `screenwidth` smallint(5) unsigned NOT NULL,
  `screenheight` smallint(5) unsigned NOT NULL,
  `password` binary(32) NOT NULL COMMENT 'sha2 256bit',
  `use_password` tinyint(1) unsigned NOT NULL,
  `score` bigint(19) unsigned NOT NULL DEFAULT '0',
  `credits` bigint(20) unsigned NOT NULL DEFAULT '0',
  `faction_rank` tinyint(4) NOT NULL DEFAULT '0',
  `storage_capacity` int(10) unsigned NOT NULL DEFAULT '0',
  `play_time` int(10) unsigned NOT NULL DEFAULT '0',
  `immunity` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `playtime` int(10) unsigned NOT NULL,
  `no_pass` tinyint(1) NOT NULL,
  `description` text NOT NULL,
  `current_faction` int(10) unsigned NOT NULL,
  PRIMARY KEY (`playerid`),
  UNIQUE KEY `steamid` (`steamid`),
  KEY `current_faction` (`current_faction`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=236 ;

CREATE TABLE IF NOT EXISTS `sa_playerxresearch` (
  `playerid` int(10) unsigned NOT NULL,
  `researchid` int(10) unsigned NOT NULL,
  `paid_credits` int(10) unsigned NOT NULL,
  `level` int(10) unsigned NOT NULL,
  `completion_time` int(10) unsigned NOT NULL,
  PRIMARY KEY (`playerid`,`researchid`),
  KEY `researchid` (`researchid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_playerxresearchpaused` (
  `playerid` int(10) unsigned NOT NULL,
  `researchid` int(10) unsigned NOT NULL,
  `paid_credits` int(10) unsigned NOT NULL,
  `level` int(10) unsigned NOT NULL,
  `start_time` int(10) unsigned NOT NULL,
  `pause_time` int(10) unsigned NOT NULL,
  `end_time` int(10) unsigned NOT NULL,
  PRIMARY KEY (`playerid`,`researchid`),
  KEY `researchid` (`researchid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_playerxresearchrunning` (
  `playerid` int(10) unsigned NOT NULL,
  `researchid` int(10) unsigned NOT NULL,
  `paid_credits` int(10) unsigned NOT NULL,
  `level` int(10) unsigned NOT NULL,
  `start_time` int(10) unsigned NOT NULL,
  `end_time` int(10) unsigned NOT NULL,
  PRIMARY KEY (`playerid`,`researchid`),
  KEY `researchid` (`researchid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_player_advert` (
  `id` int(10) unsigned NOT NULL,
  `playerid` int(10) unsigned NOT NULL,
  `contents` varchar(512) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `playerid` (`playerid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_player_join` (
  `playerid` int(10) unsigned NOT NULL,
  `ip` int(4) unsigned NOT NULL,
  `timestamp` int(10) unsigned NOT NULL,
  PRIMARY KEY (`playerid`,`ip`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_rcon_account` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL,
  `use_blacklist` tinyint(1) NOT NULL,
  `password` binary(32) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `password` (`password`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

CREATE TABLE IF NOT EXISTS `sa_rcon_command_blacklist` (
  `commandid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `command` varchar(32) NOT NULL,
  PRIMARY KEY (`commandid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

CREATE TABLE IF NOT EXISTS `sa_rcon_log` (
  `rconid` int(10) unsigned NOT NULL,
  `command` varbinary(256) NOT NULL,
  `timestamp` int(11) NOT NULL,
  KEY `rconid` (`rconid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_research` (
  `researchid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `subcategoryid` int(10) unsigned NOT NULL,
  `name` varchar(64) NOT NULL,
  `runtime` int(10) unsigned NOT NULL,
  `description` varbinary(512) NOT NULL,
  `max_level` int(10) unsigned NOT NULL,
  `basecost` int(10) unsigned NOT NULL,
  PRIMARY KEY (`researchid`),
  KEY `subcategoryid` (`subcategoryid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `sa_research_category` (
  `categoryid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`categoryid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=10 ;

INSERT INTO `sa_research_category` (`categoryid`, `name`, `description`) VALUES
(1, 'Mining', 'This category contains all mining related subcategories.'),
(2, 'Refinement', 'This category contains everything about refining mined resources.'),
(3, 'Defense', 'This category contains all defense related researches such as hull, armor and shield improvements and projectile defense.'),
(4, 'Marketing', 'This category contains everything about marketing, improve your skills are a resource broker or simply increase your wage.'),
(5, 'Player', 'This category contains everything regarding your player such as health endurance and so on.'),
(6, 'Manual mining', 'This category is for improving your manual mining skills.'),
(7, 'Weapons', 'This category features weapon development, be aware, these developments are expensive.'),
(8, 'Life Support', 'This category features life support improvements to make your life on strange planets or the deep space a little easier.'),
(9, 'Construction', 'This category features for your construction, such as building materials, faster construction of parts and their costs.');

CREATE TABLE IF NOT EXISTS `sa_research_dependency` (
  `researchid` int(10) unsigned NOT NULL,
  `dependenceid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`researchid`,`dependenceid`),
  KEY `dependenceid` (`dependenceid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_research_sub_category` (
  `subcategoryid` int(10) unsigned NOT NULL,
  `categoryid` int(10) unsigned NOT NULL DEFAULT '6',
  `name` varchar(128) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`subcategoryid`,`categoryid`),
  KEY `categoryid` (`categoryid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `sa_research_sub_category` (`subcategoryid`, `categoryid`, `name`, `description`) VALUES
(1, 1, 'Shovel digging', 'A shovel might not be a heavy hitter in terms of modern mining but maybe you find some neat things when digging around enough.'),
(1, 3, 'Hull Properties', ''),
(1, 6, 'Shovel digging', 'A shovel might not be a heavy hitter in terms of modern mining but maybe you find some neat things when digging around enough.'),
(1, 7, 'Projectile Weapons', ''),
(1, 9, 'Materials', ''),
(2, 1, 'Photon Mining', 'Photon mining is one of the most common mining methods, since it is basically laser mining.\r\n\r\nIn photon mining, the wavelength determines your mining power, a lower wavelength means the photons pack more energy.\r\n\r\nThis ranges from weak infrared light to high power gamma rays.\r\n\r\nPhoton mining is perfectly save, for the user that is, it can be abused as a weapon and can blind player at even the lowest power and allows precise mining.\r\n\r\nOn the downside this mining method is as good as useless to mine any mineral except you reach extremely short wavelengths.\r\n\r\nDue to it''s high precision, the resource output is rather low and the exponential enegry consumption is not to be underestimated either.'),
(2, 3, 'Armor Properties', ''),
(2, 6, 'Photon Mining', 'Photon mining is one of the most common mining methods, since it is basically laser mining.\r\n\r\nIn photon mining, the wavelength determines your mining power, a lower wavelength means the photons pack more energy.\r\n\r\nThis ranges from weak infrared light to high power gamma rays.\r\n\r\nPhoton mining is perfectly save, for the user that is, it can be abused as a weapon and can blind player at even the lowest power and allows precise mining.\r\n\r\nOn the downside this mining method is as good as useless to mine any mineral except you reach extremely short wavelengths.\r\n\r\nDue to it''s high precision, the resource output is rather low and the exponential enegry consumption is not to be underestimated either.'),
(2, 7, 'High Temperature Weapons', ''),
(2, 9, 'Build Speed', ''),
(3, 1, 'Drill Mining', ''),
(3, 3, 'Shield Properties', ''),
(3, 6, 'Drill Mining', ''),
(3, 7, 'Explosive Weapons', ''),
(3, 9, 'Build Capacity', ''),
(4, 1, 'Electro Mining', ''),
(4, 6, 'Electro Mining', ''),
(4, 7, 'Electric Weapons', ''),
(4, 9, 'Build Costs', ''),
(5, 1, 'Plasma Mining', ''),
(5, 6, 'Plasma Mining', ''),
(5, 7, 'Energy Weapons', ''),
(6, 1, 'Super Sonic Mining', ''),
(6, 6, 'Super Sonic Mining', ''),
(6, 7, 'Particle Weapons', ''),
(7, 1, 'Gas Collection', ''),
(7, 6, 'Gas Collection', ''),
(7, 7, 'Chemical Weapons', ''),
(8, 7, 'Plasma Weapons', '');


CREATE TABLE IF NOT EXISTS `sa_resource` (
  `resourceid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `resource_name` varchar(128) NOT NULL,
  `weight` float NOT NULL DEFAULT '0.1',
  `base_value` float unsigned NOT NULL DEFAULT '0.1',
  PRIMARY KEY (`resourceid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=27 ;

INSERT INTO `sa_resource` (`resourceid`, `resource_name`, `weight`, `base_value`) VALUES
(1, 'Hydrogen', 0.1, 0),
(2, 'Carbon', 0.1, 0),
(3, 'Nitrogen', 0.1, 0),
(4, 'Oxygen', 0.1, 0),
(5, 'Gold', 0.1, 0),
(6, 'Diamond', 0.1, 0),
(7, 'Emerald', 0.1, 0),
(8, 'Obsidian', 0.1, 0),
(9, 'Ruby', 0.1, 0),
(10, 'Saphire', 0.1, 0),
(11, 'Amethyst', 0.1, 0),
(12, 'Deuterium', 0.1, 0),
(13, 'Tritium', 0.1, 0),
(14, 'Amphere Hours', 0.1, 0),
(15, 'Water', 0.1, 0),
(16, 'Steam', 0.1, 0),
(17, 'Silver', 0.1, 0),
(18, 'Crystals', 0.1, 0),
(19, 'Heavy Water', 0.1, 0),
(20, 'Iron Ore', 0.1, 0),
(21, 'Iron', 0.1, 0),
(22, 'Aluminium', 0.1, 0),
(23, 'Platinum', 0.1, 0),
(24, 'Titanium', 0.1, 0),
(25, 'Steel', 0.1, 0),
(26, 'oil', 0.1, 0.1);

CREATE TABLE IF NOT EXISTS `sa_resource_backpack` (
  `playerid` int(10) unsigned NOT NULL,
  `resourceid` int(10) unsigned NOT NULL,
  `amount` int(10) unsigned NOT NULL,
  PRIMARY KEY (`playerid`,`resourceid`),
  KEY `resourceid` (`resourceid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE IF NOT EXISTS `sa_resource_storage` (
  `playerid` int(10) unsigned NOT NULL,
  `resourceid` int(10) unsigned NOT NULL,
  `amount` int(10) unsigned NOT NULL,
  PRIMARY KEY (`playerid`,`resourceid`),
  KEY `resourceid` (`resourceid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_server` (
  `serverid` tinyint(2) unsigned NOT NULL,
  `servername` varbinary(64) NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `port` smallint(5) NOT NULL,
  PRIMARY KEY (`serverid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `sa_server` (`serverid`, `servername`, `ip`, `port`) VALUES
(1, 'DEV', 0, 27015);

CREATE TABLE IF NOT EXISTS `sa_servererror` (
  `reportid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `serverid` tinyint(2) unsigned NOT NULL,
  `timestamp` int(10) unsigned NOT NULL,
  `errorcrc` int(10) unsigned NOT NULL,
  `report` text NOT NULL,
  PRIMARY KEY (`reportid`),
  UNIQUE KEY `errorcrc` (`errorcrc`),
  KEY `serverid` (`serverid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `sa_storage_backup` (
  `playerid` int(10) unsigned NOT NULL,
  `resourceid` int(10) unsigned NOT NULL,
  `value` int(10) unsigned NOT NULL,
  `timestamp` int(10) unsigned NOT NULL,
  PRIMARY KEY (`playerid`,`resourceid`),
  KEY `resourceid` (`resourceid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `sa_topbar_message` (
  `messageid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `message` varchar(256) NOT NULL,
  PRIMARY KEY (`messageid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

ALTER TABLE `saa_groupxpermission`
  ADD CONSTRAINT `saa_groupxpermission_ibfk_1` FOREIGN KEY (`groupid`) REFERENCES `saa_group` (`groupid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `saa_groupxpermission_ibfk_2` FOREIGN KEY (`permissionid`) REFERENCES `saa_permission` (`permissionid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `saa_playerxevent`
  ADD CONSTRAINT `saa_playerxevent_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `saa_playerxevent_ibfk_2` FOREIGN KEY (`eventid`) REFERENCES `saa_event` (`eventid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `saa_playerxgroup`
  ADD CONSTRAINT `saa_playerxgroup_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `saa_playerxgroup_ibfk_2` FOREIGN KEY (`groupid`) REFERENCES `saa_group` (`groupid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `saa_playerxpermission`
  ADD CONSTRAINT `saa_playerxpermission_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `saa_playerxpermission_ibfk_2` FOREIGN KEY (`permissionid`) REFERENCES `saa_permission` (`permissionid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_application`
  ADD CONSTRAINT `sa_application_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_application_ibfk_2` FOREIGN KEY (`factionid`) REFERENCES `sa_faction` (`factionid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_chatlog`
  ADD CONSTRAINT `sa_chatlog_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_chatlog_ibfk_2` FOREIGN KEY (`serverid`) REFERENCES `sa_server` (`serverid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_clienterror`
  ADD CONSTRAINT `sa_clienterror_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_clienterror_ibfk_2` FOREIGN KEY (`serverid`) REFERENCES `sa_server` (`serverid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_credit_transfer`
  ADD CONSTRAINT `sa_credit_transfer_ibfk_1` FOREIGN KEY (`senderid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_credit_transfer_ibfk_2` FOREIGN KEY (`receiverid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_faction_membership`
  ADD CONSTRAINT `sa_faction_membership_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_faction_membership_ibfk_2` FOREIGN KEY (`factionid`) REFERENCES `sa_faction` (`factionid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_friendship`
  ADD CONSTRAINT `sa_friendship_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_friendship_ibfk_2` FOREIGN KEY (`friendid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_friendship_ibfk_3` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_global_chatlog`
  ADD CONSTRAINT `sa_global_chatlog_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_global_chatlog_ibfk_2` FOREIGN KEY (`serverid`) REFERENCES `sa_server` (`serverid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_playerxresearch`
  ADD CONSTRAINT `sa_playerxresearch_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_playerxresearch_ibfk_2` FOREIGN KEY (`researchid`) REFERENCES `sa_research` (`researchid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_playerxresearchpaused`
  ADD CONSTRAINT `sa_playerxresearchpaused_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_playerxresearchpaused_ibfk_2` FOREIGN KEY (`researchid`) REFERENCES `sa_research` (`researchid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_playerxresearchrunning`
  ADD CONSTRAINT `sa_playerxresearchrunning_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_playerxresearchrunning_ibfk_2` FOREIGN KEY (`researchid`) REFERENCES `sa_research` (`researchid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_player_advert`
  ADD CONSTRAINT `sa_player_advert_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_player_advert_ibfk_2` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE;
  
ALTER TABLE `sa_player_join`
  ADD CONSTRAINT `sa_player_join_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_rcon_log`
  ADD CONSTRAINT `sa_rcon_log_ibfk_1` FOREIGN KEY (`rconid`) REFERENCES `sa_rcon_account` (`id`);

ALTER TABLE `sa_research`
  ADD CONSTRAINT `sa_research_ibfk_1` FOREIGN KEY (`subcategoryid`) REFERENCES `sa_research_sub_category` (`subcategoryid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_research_dependency`
  ADD CONSTRAINT `sa_research_dependency_ibfk_1` FOREIGN KEY (`researchid`) REFERENCES `sa_research` (`researchid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_research_dependency_ibfk_2` FOREIGN KEY (`dependenceid`) REFERENCES `sa_research` (`researchid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_research_sub_category`
  ADD CONSTRAINT `sa_research_sub_category_ibfk_1` FOREIGN KEY (`categoryid`) REFERENCES `sa_research_category` (`categoryid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_resource_backpack`
  ADD CONSTRAINT `sa_resource_backpack_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_resource_backpack_ibfk_2` FOREIGN KEY (`resourceid`) REFERENCES `sa_resource` (`resourceid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_resource_storage`
  ADD CONSTRAINT `sa_resource_storage_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_resource_storage_ibfk_2` FOREIGN KEY (`resourceid`) REFERENCES `sa_resource` (`resourceid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_servererror`
  ADD CONSTRAINT `sa_servererror_ibfk_1` FOREIGN KEY (`serverid`) REFERENCES `sa_server` (`serverid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `sa_storage_backup`
  ADD CONSTRAINT `sa_storage_backup_ibfk_1` FOREIGN KEY (`playerid`) REFERENCES `sa_player` (`playerid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sa_storage_backup_ibfk_2` FOREIGN KEY (`resourceid`) REFERENCES `sa_resource` (`resourceid`) ON DELETE CASCADE ON UPDATE CASCADE;
