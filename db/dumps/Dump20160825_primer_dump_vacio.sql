CREATE DATABASE  IF NOT EXISTS `dawProcessDb` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `dawProcessDb`;
-- MySQL dump 10.13  Distrib 5.6.25, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: dawProcessDb
-- ------------------------------------------------------
-- Server version	5.6.25-0ubuntu0.15.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `classes_planifications`
--

DROP TABLE IF EXISTS `classes_planifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classes_planifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meGeneralObjective` varchar(255) DEFAULT NULL,
  `meSpecificObjective` varchar(255) DEFAULT NULL,
  `meSpecificObjDesc` text,
  `topicName` varchar(255) DEFAULT NULL,
  `videos` varchar(255) DEFAULT NULL,
  `subject_planification_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  `period` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_classes_planifications_on_subject_planification_id` (`subject_planification_id`),
  CONSTRAINT `fk_rails_31ad4f0115` FOREIGN KEY (`subject_planification_id`) REFERENCES `subject_planifications` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classes_planifications`
--

LOCK TABLES `classes_planifications` WRITE;
/*!40000 ALTER TABLE `classes_planifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `classes_planifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cp_changes`
--

DROP TABLE IF EXISTS `cp_changes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cp_changes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `changeDate` date DEFAULT NULL,
  `changeDetail` varchar(255) DEFAULT NULL,
  `changedFrom` text,
  `changedTo` text,
  `comments` text,
  `uname` varchar(255) DEFAULT NULL,
  `classes_planification_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `topicName` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cp_changes_on_classes_planification_id` (`classes_planification_id`),
  KEY `index_cp_changes_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_d6ab377467` FOREIGN KEY (`classes_planification_id`) REFERENCES `classes_planifications` (`id`),
  CONSTRAINT `fk_rails_f86fa3eed3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cp_changes`
--

LOCK TABLES `cp_changes` WRITE;
/*!40000 ALTER TABLE `cp_changes` DISABLE KEYS */;
/*!40000 ALTER TABLE `cp_changes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `design_assignments`
--

DROP TABLE IF EXISTS `design_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `design_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(255) DEFAULT NULL,
  `assignedName` varchar(255) DEFAULT NULL,
  `comments` text,
  `user_id` int(11) DEFAULT NULL,
  `design_dpt_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_design_assignments_on_user_id` (`user_id`),
  KEY `index_design_assignments_on_design_dpt_id` (`design_dpt_id`),
  CONSTRAINT `fk_rails_082510d2f0` FOREIGN KEY (`design_dpt_id`) REFERENCES `design_dpts` (`id`),
  CONSTRAINT `fk_rails_f2cea68c69` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `design_assignments`
--

LOCK TABLES `design_assignments` WRITE;
/*!40000 ALTER TABLE `design_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `design_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `design_dpts`
--

DROP TABLE IF EXISTS `design_dpts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `design_dpts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(255) DEFAULT NULL,
  `comments` text,
  `vdm_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_design_dpts_on_vdm_id` (`vdm_id`),
  CONSTRAINT `fk_rails_f3294d84cd` FOREIGN KEY (`vdm_id`) REFERENCES `vdms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `design_dpts`
--

LOCK TABLES `design_dpts` WRITE;
/*!40000 ALTER TABLE `design_dpts` DISABLE KEYS */;
/*!40000 ALTER TABLE `design_dpts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firstName` varchar(255) DEFAULT NULL,
  `middleName` varchar(255) DEFAULT NULL,
  `firstSurname` varchar(255) DEFAULT NULL,
  `secondSurname` varchar(255) DEFAULT NULL,
  `currentSalary` float DEFAULT NULL,
  `birthDate` date DEFAULT NULL,
  `personalId` varchar(255) DEFAULT NULL,
  `rif` varchar(255) DEFAULT NULL,
  `jobTittle` varchar(255) DEFAULT NULL,
  `admissionDate` date DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `cellphone` varchar(255) DEFAULT NULL,
  `address` text,
  `email` varchar(255) DEFAULT NULL,
  `email2` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `gender` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (1,'Fabiola',NULL,'Alvarado','Mejias',NULL,NULL,'20132552',NULL,NULL,NULL,NULL,NULL,NULL,'fab.alvaradom@gmail.com',NULL,'0000-00-00 00:00:00','0000-00-00 00:00:00',NULL),(2,'Andrés',NULL,'Ortega',NULL,NULL,NULL,'11740009',NULL,NULL,NULL,NULL,NULL,NULL,'andresortega1975@gmail.com',NULL,'0000-00-00 00:00:00','0000-00-00 00:00:00',NULL),(3,'Luis',NULL,'Squitieri',NULL,NULL,NULL,'19209383',NULL,NULL,NULL,NULL,NULL,NULL,'squitieri89@gmail.com',NULL,'0000-00-00 00:00:00','0000-00-00 00:00:00',NULL),(4,'Alfredo',NULL,'Sarmiento',NULL,NULL,NULL,'18915942',NULL,NULL,NULL,NULL,NULL,NULL,'hualsarmiento@gmail.com',NULL,'0000-00-00 00:00:00','0000-00-00 00:00:00',NULL),(5,'Antonio',NULL,'Marquez',NULL,NULL,NULL,'21344528',NULL,NULL,NULL,NULL,NULL,NULL,'junior_marquez_29@hotmail.com',NULL,'0000-00-00 00:00:00','0000-00-00 00:00:00',NULL),(6,'Florangel',NULL,'Bosman',NULL,NULL,NULL,'22030862',NULL,NULL,NULL,NULL,NULL,NULL,'floribosman@gmail.com',NULL,'0000-00-00 00:00:00','0000-00-00 00:00:00',NULL),(7,'Kishka',NULL,'Suarez',NULL,NULL,NULL,'18942813',NULL,NULL,NULL,NULL,NULL,NULL,'kishka.suarez@gmail.com',NULL,'0000-00-00 00:00:00','0000-00-00 00:00:00',NULL),(8,'Miguel',NULL,'Hernandez',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'mehg31@gmail.com',NULL,'0000-00-00 00:00:00','0000-00-00 00:00:00',NULL),(9,'Irays',NULL,'Monterola',NULL,NULL,NULL,'18467752',NULL,NULL,NULL,NULL,NULL,NULL,'iraysmonterola440@gmail.com',NULL,'0000-00-00 00:00:00','0000-00-00 00:00:00',NULL),(10,'Alessandra',NULL,'Alarcon',NULL,NULL,NULL,'21105361',NULL,NULL,NULL,NULL,NULL,NULL,'cuchuna92@hotmail.com',NULL,'0000-00-00 00:00:00','0000-00-00 00:00:00',NULL),(11,'Gabriela',NULL,'Do Espiritu',NULL,NULL,NULL,'19734731',NULL,NULL,NULL,NULL,NULL,NULL,'gabrieladesp@hotmail.com',NULL,'0000-00-00 00:00:00','0000-00-00 00:00:00',NULL),(12,'Adriana',NULL,'Parra',NULL,NULL,NULL,'19586251',NULL,NULL,NULL,NULL,NULL,NULL,'adriana56743@gmail.com',NULL,'0000-00-00 00:00:00','0000-00-00 00:00:00',NULL),(13,'Douglas',NULL,'Hernandez',NULL,NULL,NULL,'18530955',NULL,NULL,NULL,NULL,NULL,NULL,'hernandezdougg@gmail.com',NULL,'0000-00-00 00:00:00','0000-00-00 00:00:00',NULL),(14,'Samuel',NULL,'Tovar',NULL,NULL,NULL,'23642497',NULL,NULL,NULL,NULL,NULL,NULL,'samueltovarheredia@gmail.com',NULL,'0000-00-00 00:00:00','0000-00-00 00:00:00',NULL),(15,'Alejandro',NULL,'Solé',NULL,NULL,NULL,'17705599',NULL,NULL,NULL,NULL,NULL,NULL,'alesole@gmail.com',NULL,'0000-00-00 00:00:00','0000-00-00 00:00:00',NULL),(16,'Carlos',NULL,'Martinez',NULL,NULL,NULL,'0000000',NULL,NULL,NULL,NULL,NULL,NULL,'cmmrtinez@gmail.com',NULL,'2016-08-25 14:45:25','2016-08-25 14:45:26',NULL);
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grades`
--

DROP TABLE IF EXISTS `grades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `grades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grades`
--

LOCK TABLES `grades` WRITE;
/*!40000 ALTER TABLE `grades` DISABLE KEYS */;
INSERT INTO `grades` VALUES (1,'1er año','primer año','2016-08-24 11:09:58','2016-08-24 11:09:59'),(2,'2do año','segundo año','2016-08-24 11:10:10','2016-08-24 11:10:11'),(3,'3er año','tercer año','2016-08-24 11:10:23','2016-08-24 11:10:24'),(4,'4to año','cuarto año','2016-08-24 11:10:34','2016-08-24 11:10:35'),(5,'5to año','quinto año','2016-08-24 11:10:46','2016-08-24 11:10:47');
/*!40000 ALTER TABLE `grades` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post_prod_dpt_assignments`
--

DROP TABLE IF EXISTS `post_prod_dpt_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `post_prod_dpt_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(255) DEFAULT NULL,
  `assignedName` varchar(255) DEFAULT NULL,
  `comments` text,
  `user_id` int(11) DEFAULT NULL,
  `post_prod_dpt_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_post_prod_dpt_assignments_on_user_id` (`user_id`),
  KEY `index_post_prod_dpt_assignments_on_post_prod_dpt_id` (`post_prod_dpt_id`),
  CONSTRAINT `fk_rails_10de908539` FOREIGN KEY (`post_prod_dpt_id`) REFERENCES `post_prod_dpts` (`id`),
  CONSTRAINT `fk_rails_37d7052fd2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_prod_dpt_assignments`
--

LOCK TABLES `post_prod_dpt_assignments` WRITE;
/*!40000 ALTER TABLE `post_prod_dpt_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `post_prod_dpt_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post_prod_dpts`
--

DROP TABLE IF EXISTS `post_prod_dpts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `post_prod_dpts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(255) DEFAULT NULL,
  `comments` text,
  `vdm_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_post_prod_dpts_on_vdm_id` (`vdm_id`),
  CONSTRAINT `fk_rails_d6013ae03b` FOREIGN KEY (`vdm_id`) REFERENCES `vdms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_prod_dpts`
--

LOCK TABLES `post_prod_dpts` WRITE;
/*!40000 ALTER TABLE `post_prod_dpts` DISABLE KEYS */;
/*!40000 ALTER TABLE `post_prod_dpts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_managements`
--

DROP TABLE IF EXISTS `product_managements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_managements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `productionStatus` varchar(255) DEFAULT NULL,
  `editionStatus` varchar(255) DEFAULT NULL,
  `designStatus` varchar(255) DEFAULT NULL,
  `postProductionStatus` varchar(255) DEFAULT NULL,
  `vdm_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_product_managements_on_vdm_id` (`vdm_id`),
  CONSTRAINT `fk_rails_d38f8c7498` FOREIGN KEY (`vdm_id`) REFERENCES `vdms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_managements`
--

LOCK TABLES `product_managements` WRITE;
/*!40000 ALTER TABLE `product_managements` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_managements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `production_dpt_assignments`
--

DROP TABLE IF EXISTS `production_dpt_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `production_dpt_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(255) DEFAULT NULL,
  `assignedName` varchar(255) DEFAULT NULL,
  `comments` text,
  `user_id` int(11) DEFAULT NULL,
  `production_dpt_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_production_dpt_assignments_on_user_id` (`user_id`),
  KEY `index_production_dpt_assignments_on_production_dpt_id` (`production_dpt_id`),
  CONSTRAINT `fk_rails_743e3a7d73` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_9fe6c802b5` FOREIGN KEY (`production_dpt_id`) REFERENCES `production_dpts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `production_dpt_assignments`
--

LOCK TABLES `production_dpt_assignments` WRITE;
/*!40000 ALTER TABLE `production_dpt_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `production_dpt_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `production_dpts`
--

DROP TABLE IF EXISTS `production_dpts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `production_dpts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(255) DEFAULT NULL,
  `script` text,
  `comments` text,
  `intro` tinyint(1) DEFAULT NULL,
  `vidDev` tinyint(1) DEFAULT NULL,
  `conclu` tinyint(1) DEFAULT NULL,
  `vdm_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_production_dpts_on_vdm_id` (`vdm_id`),
  CONSTRAINT `fk_rails_6c6d407772` FOREIGN KEY (`vdm_id`) REFERENCES `vdms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `production_dpts`
--

LOCK TABLES `production_dpts` WRITE;
/*!40000 ALTER TABLE `production_dpts` DISABLE KEYS */;
/*!40000 ALTER TABLE `production_dpts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `primary` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_roles_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_ab35d699f0` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'production',1,'0000-00-00 00:00:00','0000-00-00 00:00:00',1),(2,'productManager',2,'0000-00-00 00:00:00','0000-00-00 00:00:00',1),(3,'postProLeader',3,'0000-00-00 00:00:00','0000-00-00 00:00:00',1),(4,'contentLeader',4,'0000-00-00 00:00:00','0000-00-00 00:00:00',1),(5,'designer',5,'0000-00-00 00:00:00','0000-00-00 00:00:00',1),(6,'designer',6,'0000-00-00 00:00:00','0000-00-00 00:00:00',1),(7,'productManager',7,'0000-00-00 00:00:00','0000-00-00 00:00:00',1),(8,'production',9,'0000-00-00 00:00:00','0000-00-00 00:00:00',1),(9,'editor',10,'0000-00-00 00:00:00','0000-00-00 00:00:00',1),(10,'post-producer',11,'0000-00-00 00:00:00','0000-00-00 00:00:00',1),(11,'post-producer',12,'0000-00-00 00:00:00','0000-00-00 00:00:00',1),(12,'post-producer',13,'0000-00-00 00:00:00','0000-00-00 00:00:00',1),(13,'editor',14,'0000-00-00 00:00:00','0000-00-00 00:00:00',1),(14,'production',15,'0000-00-00 00:00:00','0000-00-00 00:00:00',1),(15,'designLeader',2,'2016-08-24 14:54:46','2016-08-24 14:54:47',NULL),(16,'designLeader',3,'2016-08-24 14:54:59','2016-08-24 14:55:00',NULL),(17,'production',2,'2016-08-24 15:09:35','2016-08-24 15:09:36',NULL),(18,'contentLeader',7,'2016-08-24 15:17:42','2016-08-24 15:17:43',NULL),(19,'postProLeader',7,'2016-08-24 15:18:03','2016-08-24 15:18:04',NULL),(20,'designLeader',7,'2016-08-24 15:18:27','2016-08-24 15:18:29',NULL),(21,'production',7,'2016-08-24 15:19:48','2016-08-24 15:19:51',NULL),(22,'post-producer',16,'2016-08-25 14:45:03','2016-08-25 14:45:05',NULL);
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20160721140735'),('20160721141119'),('20160721141346'),('20160722192541'),('20160722193225'),('20160722193602'),('20160722195247'),('20160722201950'),('20160722202424'),('20160725153157'),('20160725154344'),('20160726193123'),('20160727125956'),('20160727130121'),('20160727130247'),('20160728031716'),('20160728191804'),('20160728192103'),('20160728192223'),('20160730170328'),('20160730203314'),('20160730215032'),('20160730222345'),('20160731172340'),('20160801011219'),('20160801140316'),('20160801174034'),('20160802193804'),('20160803170259'),('20160804220922'),('20160805185341'),('20160805185712'),('20160805185916'),('20160805211625'),('20160805211738'),('20160811150445'),('20160819140844'),('20160819141150');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subject_planifications`
--

DROP TABLE IF EXISTS `subject_planifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subject_planifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(255) DEFAULT NULL,
  `teacher_id` int(11) DEFAULT NULL,
  `subject_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `firstPeriodCompleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_subject_planifications_on_teacher_id` (`teacher_id`),
  KEY `index_subject_planifications_on_subject_id` (`subject_id`),
  KEY `index_subject_planifications_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_0445effdd1` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`),
  CONSTRAINT `fk_rails_2774b3d66a` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`),
  CONSTRAINT `fk_rails_31f0e66780` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subject_planifications`
--

LOCK TABLES `subject_planifications` WRITE;
/*!40000 ALTER TABLE `subject_planifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `subject_planifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subjects`
--

DROP TABLE IF EXISTS `subjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subjects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `shortDescription` text,
  `longDescription` text,
  `firstPeriodDesc` text,
  `secondPeriodDesc` text,
  `thirdPeriodDesc` text,
  `goal` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `grade_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_subjects_on_grade_id` (`grade_id`),
  CONSTRAINT `fk_rails_33d539df11` FOREIGN KEY (`grade_id`) REFERENCES `grades` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subjects`
--

LOCK TABLES `subjects` WRITE;
/*!40000 ALTER TABLE `subjects` DISABLE KEYS */;
/*!40000 ALTER TABLE `subjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teachers`
--

DROP TABLE IF EXISTS `teachers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teachers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cvLong` text,
  `cvShort` text,
  `firstName` varchar(255) DEFAULT NULL,
  `middleName` varchar(255) DEFAULT NULL,
  `lastName` varchar(255) DEFAULT NULL,
  `personalId` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teachers`
--

LOCK TABLES `teachers` WRITE;
/*!40000 ALTER TABLE `teachers` DISABLE KEYS */;
/*!40000 ALTER TABLE `teachers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `profilePicture` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `employee_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_users_on_employee_id` (`employee_id`),
  CONSTRAINT `fk_rails_bb0d626f7d` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'fabbs','fabbs123',NULL,NULL,1,'0000-00-00 00:00:00','0000-00-00 00:00:00'),(2,'tyrion','tyrion123',NULL,NULL,2,'0000-00-00 00:00:00','0000-00-00 00:00:00'),(3,'squitieri','squitieri123',NULL,NULL,3,'0000-00-00 00:00:00','0000-00-00 00:00:00'),(4,'alfredo10','alfredo123',NULL,NULL,4,'0000-00-00 00:00:00','0000-00-00 00:00:00'),(5,'kuma','kuma123',NULL,NULL,5,'0000-00-00 00:00:00','0000-00-00 00:00:00'),(6,'hana','hana123',NULL,NULL,6,'0000-00-00 00:00:00','0000-00-00 00:00:00'),(7,'kishka','kishka123',NULL,NULL,7,'0000-00-00 00:00:00','0000-00-00 00:00:00'),(8,'mike','mike123',NULL,NULL,8,'0000-00-00 00:00:00','0000-00-00 00:00:00'),(9,'irays','irays123',NULL,NULL,9,'0000-00-00 00:00:00','0000-00-00 00:00:00'),(10,'alessa','alessa123',NULL,NULL,10,'0000-00-00 00:00:00','0000-00-00 00:00:00'),(11,'gaby','gaby123',NULL,NULL,11,'0000-00-00 00:00:00','0000-00-00 00:00:00'),(12,'adriana','adriana123',NULL,NULL,12,'0000-00-00 00:00:00','0000-00-00 00:00:00'),(13,'dhernandez','dhernandez123',NULL,NULL,13,'0000-00-00 00:00:00','0000-00-00 00:00:00'),(14,'samuel','samuel123',NULL,NULL,14,'0000-00-00 00:00:00','0000-00-00 00:00:00'),(15,'alesole','alesole123',NULL,NULL,15,'0000-00-00 00:00:00','0000-00-00 00:00:00'),(16,'carlos','carlos123',NULL,NULL,16,'2016-08-25 14:45:41','2016-08-25 14:45:44');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vdm_changes`
--

DROP TABLE IF EXISTS `vdm_changes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vdm_changes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `changeDate` date DEFAULT NULL,
  `changeDetail` text,
  `changedFrom` text,
  `changedTo` text,
  `vdm_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `comments` text,
  `uname` varchar(255) DEFAULT NULL,
  `videoId` varchar(255) DEFAULT NULL,
  `department` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_vdm_changes_on_vdm_id` (`vdm_id`),
  KEY `index_vdm_changes_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_45390505ba` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_6ad4a92cf5` FOREIGN KEY (`vdm_id`) REFERENCES `vdms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=189 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vdm_changes`
--

LOCK TABLES `vdm_changes` WRITE;
/*!40000 ALTER TABLE `vdm_changes` DISABLE KEYS */;
/*!40000 ALTER TABLE `vdm_changes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vdms`
--

DROP TABLE IF EXISTS `vdms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vdms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `videoId` varchar(255) DEFAULT NULL,
  `videoTittle` varchar(255) DEFAULT NULL,
  `videoContent` text,
  `status` varchar(255) DEFAULT NULL,
  `comments` text,
  `classes_planification_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `number` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_vdms_on_classes_planification_id` (`classes_planification_id`),
  CONSTRAINT `fk_rails_cc41426c6e` FOREIGN KEY (`classes_planification_id`) REFERENCES `classes_planifications` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vdms`
--

LOCK TABLES `vdms` WRITE;
/*!40000 ALTER TABLE `vdms` DISABLE KEYS */;
/*!40000 ALTER TABLE `vdms` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-08-25 14:46:52
