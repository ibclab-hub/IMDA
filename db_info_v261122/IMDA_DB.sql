-- MySQL dump 10.13  Distrib 8.0.32, for Linux (x86_64)
--
-- Host: localhost    Database: KUBDS
-- ------------------------------------------------------
-- Server version	8.0.32-0ubuntu0.20.04.2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Epigenome_ChIP`
--

DROP TABLE IF EXISTS `Epigenome_ChIP`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Epigenome_ChIP` (
  `data_id` int NOT NULL AUTO_INCREMENT,
  `sample_set_id` int DEFAULT NULL,
  `data_type` text,
  `json_path` text,
  `parameter_path` text,
  `SRA_id` text,
  `reference` text,
  `antibody` text,
  `param_bandwith` int DEFAULT NULL,
  `param_minqual` int DEFAULT NULL,
  `param_qcutoff` double DEFAULT NULL,
  `paired` int DEFAULT NULL,
  `ref_assembly` int DEFAULT NULL,
  PRIMARY KEY (`data_id`),
  KEY `sample_set_id` (`sample_set_id`),
  KEY `ref_assembly` (`ref_assembly`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Epigenome_ChIP`
--

LOCK TABLES `Epigenome_ChIP` WRITE;
/*!40000 ALTER TABLE `Epigenome_ChIP` DISABLE KEYS */;
INSERT INTO `Epigenome_ChIP` VALUES (6,99,'fastq','Multiomics/Epigenome_chip/6/SRR16918058',NULL,'SRR16918058',NULL,NULL,NULL,NULL,NULL,0,12),(8,101,'fastq','Multiomics/Epigenome_chip/8/SRR13296022',NULL,'SRR13296022',NULL,'H3K4me3',NULL,NULL,NULL,1,34),(9,102,'fastq','Multiomics/Epigenome_chip/9/SRR18514252',NULL,'SRR18514252',NULL,'H3K27me3',NULL,NULL,NULL,1,5),(10,103,'fastq','Multiomics/Epigenome_chip/10/SRR18151038',NULL,'SRR18151038',NULL,'H3K9me3',NULL,NULL,NULL,1,31),(12,105,'fastq','Multiomics/Epigenome_chip/12/SRR1552250',NULL,'SRR1552250',NULL,'H3K27me3',NULL,NULL,NULL,0,38),(13,106,'fastq','Multiomics/Epigenome_chip/13/ERR2731591',NULL,'ERR2731591',NULL,'H3K4me3,H3K27ac,H3K4me1',NULL,NULL,NULL,1,19),(15,108,'fastq','Multiomics/Epigenome_chip/15/SRR15658154',NULL,'SRR15658154',NULL,'H3K4me3',NULL,NULL,NULL,0,43),(16,109,'fastq','Multiomics/Epigenome_chip/16/SRR18354928',NULL,'SRR18354928',NULL,'H3K4me1',NULL,NULL,NULL,0,37),(17,110,'fastq','Multiomics/Epigenome_chip/17/SRR5086619',NULL,'SRR5086619',NULL,'H3K4me3',NULL,NULL,NULL,1,41),(18,111,'fastq','Multiomics/Epigenome_chip/18/SRR16611061',NULL,'SRR16611061',NULL,'H3K4me3',NULL,NULL,NULL,0,11),(19,112,'fastq','Multiomics/Epigenome_chip/19/SRR21488061',NULL,'SRR21488061',NULL,'H3K27ac',NULL,NULL,NULL,1,2),(20,113,'fastq','Multiomics/Epigenome_chip/20/SRR12806713',NULL,'SRR12806713',NULL,'H3K27me3',NULL,NULL,NULL,1,32),(21,114,'fastq','Multiomics/Epigenome_chip/21/SRR12916433',NULL,'SRR12916433',NULL,'H3K4me3',NULL,NULL,NULL,1,30),(22,115,'fastq','Multiomics/Epigenome_chip/22/SRR888896',NULL,'SRR888896',NULL,'H3K27me3',NULL,NULL,NULL,0,7),(24,117,'fastq','Multiomics/Epigenome_chip/24/SRR10075687',NULL,'SRR10075687',NULL,'H3K9me3',NULL,NULL,NULL,0,27),(25,118,'fastq','Multiomics/Epigenome_chip/25/SRR20326869',NULL,'SRR20326869',NULL,'H3K9ac',NULL,NULL,NULL,0,17),(26,119,'fastq','Multiomics/Epigenome_chip/26/SRR2075659',NULL,'SRR2075659',NULL,'H3K4me3',NULL,NULL,NULL,0,40),(27,120,'fastq','Multiomics/Epigenome_chip/27/SRR4445470',NULL,'SRR4445470',NULL,'H3K27ac',NULL,NULL,NULL,1,20),(28,121,'fastq','Multiomics/Epigenome_chip/28/SRR3498898',NULL,'SRR3498898',NULL,'H3K27me3',NULL,NULL,NULL,0,29),(29,122,'fastq','Multiomics/Epigenome_chip/29/SRR8742376',NULL,'SRR8742376',NULL,'H3K27me3',NULL,NULL,NULL,0,8),(30,123,'fastq','Multiomics/Epigenome_chip/30/SRR17737106',NULL,'SRR17737106',NULL,'H3K27me3',NULL,NULL,NULL,0,35),(31,124,'fastq','Multiomics/Epigenome_chip/31/SRR6652578',NULL,'SRR6652578',NULL,'H3K27me3',NULL,NULL,NULL,0,24),(32,125,'fastq','Multiomics/Epigenome_chip/32/SRR029266',NULL,'SRR029266',NULL,'H3K4me3',NULL,NULL,NULL,0,9),(33,126,'fastq','Multiomics/Epigenome_chip/33/SRR15712053',NULL,'SRR15712053',NULL,'H3K27me3',NULL,NULL,NULL,0,42),(48,138,'fastq','Multiomics/Epigenome_chip/48/SRR6660455',NULL,'SRR6660455',NULL,'H3K27ac',NULL,NULL,NULL,0,2),(49,139,'fastq','Multiomics/Epigenome_chip/49/ERR2731446',NULL,'ERR2731446',NULL,'H3K27ac',NULL,NULL,NULL,0,22),(50,140,'fastq','Multiomics/Epigenome_chip/50/SRR4445040',NULL,'SRR4445040',NULL,'H3K4me1',NULL,NULL,NULL,0,22),(51,141,'fastq','Multiomics/Epigenome_chip/51/SRR19787582',NULL,'SRR19787582',NULL,'H3K4me3',NULL,NULL,NULL,1,18),(52,142,'fastq','Multiomics/Epigenome_chip/52/ERR2731545',NULL,'ERR2731545',NULL,'H3K27ac',NULL,NULL,NULL,0,19),(53,143,'fastq','Multiomics/Epigenome_chip/53/ERR2731544',NULL,'ERR2731544',NULL,'H3K27ac',NULL,NULL,NULL,0,19),(54,144,'fastq','Multiomics/Epigenome_chip/54/SRR12764838',NULL,'SRR12764838',NULL,'H3K27ac',NULL,NULL,NULL,1,30),(55,145,'fastq','Multiomics/Epigenome_chip/55/SRR4445030',NULL,'SRR4445030',NULL,'H3K27ac',NULL,NULL,NULL,0,30),(56,146,'fastq','Multiomics/Epigenome_chip/56/SRR4445020',NULL,'SRR4445020',NULL,'H3K27ac',NULL,NULL,NULL,0,20),(57,147,'fastq','Multiomics/Epigenome_chip/57/SRR12764830',NULL,'SRR12764830',NULL,'H3K27ac',NULL,NULL,NULL,0,20),(58,148,'fastq','Multiomics/Epigenome_chip/58/SRR19787573',NULL,'SRR19787573',NULL,'H3K4me3',NULL,NULL,NULL,1,40),(63,138,'profile','Multiomics/Epigenome_chip/63/',NULL,'SRR6660455',NULL,'H3K27ac',300,NULL,0.05,0,2),(64,120,'profile','Multiomics/Epigenome_chip/64/',NULL,'SRR4445470',NULL,'H3K27ac',300,NULL,0.05,NULL,20),(66,205,'fastq','Multiomics/Epigenome_chip/66/SRR20653140',NULL,'SRR20653140',NULL,'S5',NULL,NULL,NULL,1,3),(67,140,'profile','Multiomics/Epigenome_chip/67/',NULL,'SRR4445040',NULL,'H3K4me1',300,NULL,0.05,0,22),(69,112,'profile','Multiomics/Epigenome_chip/69/',NULL,'SRR21488061',NULL,'H3K27ac',300,NULL,0.05,NULL,2),(70,199,'profile','Multiomics/Epigenome_chip/70/',NULL,'SRR20653140,SRR6660455',NULL,'H3K27ac,S5',300,NULL,0.05,NULL,2),(75,201,'profile','Multiomics/Epigenome_chip/75/',NULL,'SRR21488061,SRR6660455',NULL,'H3K27ac',300,NULL,0.05,NULL,2),(88,103,'profile','Multiomics/Epigenome_chip/88/',NULL,'SRR18151038',NULL,'H3K9me3',300,NULL,0.05,NULL,31),(89,105,'profile','Multiomics/Epigenome_chip/89/',NULL,'SRR1552250',NULL,'H3K27me3',300,NULL,0.05,NULL,38),(90,141,'profile','Multiomics/Epigenome_chip/90/',NULL,'SRR19787582',NULL,'H3K4me3',300,NULL,0.05,NULL,18),(91,103,'profile','Multiomics/Epigenome_chip/91/',NULL,'SRR18151038',NULL,'H3K9me3',200,NULL,0.1,NULL,31),(92,138,'profile','Multiomics/Epigenome_chip/92/',NULL,'SRR6660455',NULL,'H3K27ac',200,NULL,0.05,NULL,2),(93,109,'profile','Multiomics/Epigenome_chip/93/',NULL,'SRR18354928',NULL,'H3K4me1',300,NULL,0.05,NULL,36),(94,124,'profile','Multiomics/Epigenome_chip/94/',NULL,'SRR6652578',NULL,'H3K27me3',300,NULL,0.05,NULL,24),(95,102,'profile','Multiomics/Epigenome_chip/95/',NULL,'SRR18514252',NULL,'H3K27me3',300,NULL,0.05,NULL,5),(96,138,'profile','Multiomics/Epigenome_chip/96/',NULL,'SRR6660455',NULL,'H3K27ac',296,NULL,0.05,NULL,2),(97,103,'profile','Multiomics/Epigenome_chip/97/',NULL,'SRR18151038',NULL,'H3K9me3',297,NULL,0.05,NULL,31),(98,103,'profile','Multiomics/Epigenome_chip/98/',NULL,'SRR18151038',NULL,'H3K9me3',100,NULL,0.05,NULL,31),(99,124,'profile','Multiomics/Epigenome_chip/99/',NULL,'SRR6652578',NULL,'H3K27me3',100,NULL,0.05,NULL,24),(100,111,'profile','Multiomics/Epigenome_chip/100/',NULL,'SRR16611061',NULL,'H3K4me3',300,NULL,0.05,NULL,11),(101,122,'profile','Multiomics/Epigenome_chip/101/',NULL,'SRR8742376',NULL,'H3K27me3',300,NULL,0.05,NULL,8),(102,287,'profile','Multiomics/Epigenome_chip/102/',NULL,'SRR4445020,SRR4445470',NULL,'H3K27ac',200,NULL,0.05,NULL,20),(103,99,'profile','Multiomics/Epigenome_chip/103/',NULL,'SRR16918058',NULL,NULL,300,NULL,0.05,NULL,12),(104,99,'profile','Multiomics/Epigenome_chip/104/',NULL,'SRR16918058',NULL,NULL,100,NULL,0.05,NULL,12),(105,125,'profile','Multiomics/Epigenome_chip/105/',NULL,'SRR029266',NULL,'H3K4me3',300,NULL,0.05,NULL,9),(106,124,'profile','Multiomics/Epigenome_chip/106/',NULL,'SRR6652578',NULL,'H3K27me3',500,NULL,0.05,NULL,24),(107,125,'profile','Multiomics/Epigenome_chip/107/',NULL,'SRR029266',NULL,'H3K4me3',500,NULL,0.05,NULL,9),(108,125,'profile','Multiomics/Epigenome_chip/108/',NULL,'SRR029266',NULL,'H3K4me3',400,NULL,0.05,NULL,9);
/*!40000 ALTER TABLE `Epigenome_ChIP` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Epigenome_ChIP_diff`
--

DROP TABLE IF EXISTS `Epigenome_ChIP_diff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Epigenome_ChIP_diff` (
  `diff_id` int NOT NULL,
  `path` text,
  `reference_assembly` int DEFAULT NULL,
  `generated_synteny` int DEFAULT NULL,
  `inter_intra` varchar(40) NOT NULL,
  PRIMARY KEY (`diff_id`),
  KEY `reference_assembly` (`reference_assembly`),
  KEY `generated_synteny` (`generated_synteny`),
  CONSTRAINT `Epigenome_ChIP_diff_ibfk_1` FOREIGN KEY (`reference_assembly`) REFERENCES `assembly` (`assembly_id`),
  CONSTRAINT `Epigenome_ChIP_diff_ibfk_2` FOREIGN KEY (`reference_assembly`) REFERENCES `assembly` (`assembly_id`),
  CONSTRAINT `Epigenome_ChIP_diff_ibfk_3` FOREIGN KEY (`generated_synteny`) REFERENCES `synteny` (`synteny_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Epigenome_ChIP_diff`
--

LOCK TABLES `Epigenome_ChIP_diff` WRITE;
/*!40000 ALTER TABLE `Epigenome_ChIP_diff` DISABLE KEYS */;
INSERT INTO `Epigenome_ChIP_diff` VALUES (2,'Multiomics/Diff/CHIP/2',2,107,'inter'),(10,'Multiomics/Diff/CHIP/10',20,107,'intra'),(11,'Multiomics/Diff/CHIP/11',2,107,'intra'),(12,'Multiomics/Diff/CHIP/12',24,130,'intra'),(13,'Multiomics/Diff/CHIP/13',9,130,'inter'),(14,'Multiomics/Diff/CHIP/14',2,107,'inter');
/*!40000 ALTER TABLE `Epigenome_ChIP_diff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Epigenome_ChIP_diff_ids`
--

DROP TABLE IF EXISTS `Epigenome_ChIP_diff_ids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Epigenome_ChIP_diff_ids` (
  `diff_id` int DEFAULT NULL,
  `multiomics_data_id` int DEFAULT NULL,
  KEY `diff_id` (`diff_id`),
  KEY `multiomics_data_id` (`multiomics_data_id`),
  CONSTRAINT `Epigenome_ChIP_diff_ids_ibfk_1` FOREIGN KEY (`diff_id`) REFERENCES `Epigenome_ChIP_diff` (`diff_id`),
  CONSTRAINT `Epigenome_ChIP_diff_ids_ibfk_2` FOREIGN KEY (`multiomics_data_id`) REFERENCES `Epigenome_ChIP` (`data_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Epigenome_ChIP_diff_ids`
--

LOCK TABLES `Epigenome_ChIP_diff_ids` WRITE;
/*!40000 ALTER TABLE `Epigenome_ChIP_diff_ids` DISABLE KEYS */;
INSERT INTO `Epigenome_ChIP_diff_ids` VALUES (2,70),(2,69),(2,63),(2,64),(10,64),(10,102),(11,63),(11,69),(11,70),(11,75),(12,94),(12,99),(13,94),(13,99),(13,105),(13,106),(13,107),(13,108),(14,92),(14,96),(14,69),(14,102);
/*!40000 ALTER TABLE `Epigenome_ChIP_diff_ids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Epigenome_HiC`
--

DROP TABLE IF EXISTS `Epigenome_HiC`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Epigenome_HiC` (
  `data_id` int NOT NULL AUTO_INCREMENT,
  `sample_set_id` int DEFAULT NULL,
  `data_type` text,
  `json_path` text,
  `parameter_path` text,
  `SRA_id` text,
  `reference` text,
  `paired` int DEFAULT NULL,
  `ref_assembly` int DEFAULT NULL,
  `param_binsize` int DEFAULT NULL,
  `param_bin_cnt` int DEFAULT NULL,
  `param_resolution` int DEFAULT NULL,
  PRIMARY KEY (`data_id`),
  KEY `sample_set_id` (`sample_set_id`),
  KEY `ref_assembly` (`ref_assembly`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Epigenome_HiC`
--

LOCK TABLES `Epigenome_HiC` WRITE;
/*!40000 ALTER TABLE `Epigenome_HiC` DISABLE KEYS */;
INSERT INTO `Epigenome_HiC` VALUES (2,41,'fastq','Multiomics/Epigenome_hic/2/ERR9356802',NULL,'ERR9356802',NULL,NULL,13,NULL,NULL,NULL),(3,42,'fastq','Multiomics/Epigenome_hic/3/ERR9811602',NULL,'ERR9811602',NULL,NULL,10,NULL,NULL,NULL),(4,43,'fastq','Multiomics/Epigenome_hic/4/SRR7224594',NULL,'SRR7224594',NULL,NULL,4,NULL,NULL,NULL),(5,44,'fastq','Multiomics/Epigenome_hic/5/SRR13786526',NULL,'SRR13786526',NULL,NULL,18,NULL,NULL,NULL),(7,46,'fastq','Multiomics/Epigenome_hic/7/DRR221560',NULL,'DRR221560',NULL,NULL,22,NULL,NULL,NULL),(8,47,'fastq','Multiomics/Epigenome_hic/8/SRR12511409',NULL,'SRR12511409',NULL,NULL,34,NULL,NULL,NULL),(9,48,'fastq','Multiomics/Epigenome_hic/9/SRR15037326',NULL,'SRR15037326',NULL,NULL,5,NULL,NULL,NULL),(10,49,'fastq','Multiomics/Epigenome_hic/10/SRR11813284',NULL,'SRR11813284',NULL,NULL,31,NULL,NULL,NULL),(11,50,'fastq','Multiomics/Epigenome_hic/11/SRR6374290',NULL,'SRR6374290',NULL,NULL,19,NULL,NULL,NULL),(12,51,'fastq','Multiomics/Epigenome_hic/12/SRR12331759',NULL,'SRR12331759',NULL,NULL,38,NULL,NULL,NULL),(13,52,'fastq','Multiomics/Epigenome_hic/13/SRR13374520',NULL,'SRR13374520',NULL,NULL,43,NULL,NULL,NULL),(14,53,'fastq','Multiomics/Epigenome_hic/14/SRR15571570',NULL,'SRR15571570',NULL,NULL,37,NULL,NULL,NULL),(15,54,'fastq','Multiomics/Epigenome_hic/15/SRR12494514',NULL,'SRR12494514',NULL,NULL,11,NULL,NULL,NULL),(16,55,'fastq','Multiomics/Epigenome_hic/16/SRR16465801',NULL,'SRR16465801',NULL,NULL,2,NULL,NULL,NULL),(17,56,'fastq','Multiomics/Epigenome_hic/17/DRR208970',NULL,'DRR208970',NULL,NULL,32,NULL,NULL,NULL),(18,57,'fastq','Multiomics/Epigenome_hic/18/SRR13786551',NULL,'SRR13786551',NULL,NULL,30,NULL,NULL,NULL),(19,58,'fastq','Multiomics/Epigenome_hic/19/SRR13252782',NULL,'SRR13252782',NULL,NULL,30,NULL,NULL,NULL),(20,59,'fastq','Multiomics/Epigenome_hic/20/SRR8616961',NULL,'SRR8616961',NULL,NULL,7,NULL,NULL,NULL),(21,60,'fastq','Multiomics/Epigenome_hic/21/SRR15663814',NULL,'SRR15663814',NULL,NULL,3,NULL,NULL,NULL),(22,61,'fastq','Multiomics/Epigenome_hic/22/SRR7232221',NULL,'SRR7232221',NULL,NULL,27,NULL,NULL,NULL),(23,62,'fastq','Multiomics/Epigenome_hic/23/SRR6702446',NULL,'SRR6702446',NULL,NULL,25,NULL,NULL,NULL),(24,63,'fastq','Multiomics/Epigenome_hic/24/SRR10123324',NULL,'SRR10123324',NULL,NULL,17,NULL,NULL,NULL),(25,64,'fastq','Multiomics/Epigenome_hic/25/SRR13786532',NULL,'SRR13786532',NULL,NULL,40,NULL,NULL,NULL),(26,65,'fastq','Multiomics/Epigenome_hic/26/SRR8782022',NULL,'SRR8782022',NULL,NULL,33,NULL,NULL,NULL),(27,66,'fastq','Multiomics/Epigenome_hic/27/SRR8782019',NULL,'SRR8782019',NULL,NULL,20,NULL,NULL,NULL),(28,67,'fastq','Multiomics/Epigenome_hic/28/SRR17631657',NULL,'SRR17631657',NULL,NULL,35,NULL,NULL,NULL),(29,68,'fastq','Multiomics/Epigenome_hic/29/DRR374915',NULL,'DRR374915',NULL,NULL,24,NULL,NULL,NULL),(30,69,'fastq','Multiomics/Epigenome_hic/30/ERR4179377',NULL,'ERR4179377',NULL,NULL,44,NULL,NULL,NULL),(31,70,'fastq','Multiomics/Epigenome_hic/31/SRR11085806',NULL,'SRR11085806',NULL,NULL,9,NULL,NULL,NULL),(32,71,'fastq','Multiomics/Epigenome_hic/32/SRR13386567',NULL,'SRR13386567',NULL,NULL,42,NULL,NULL,NULL),(44,175,'fastq','Multiomics/Epigenome_hic/44/SRR7802504',NULL,'SRR7802504',NULL,NULL,2,NULL,NULL,NULL),(45,176,'fastq','Multiomics/Epigenome_hic/45/SRR14999686',NULL,'SRR14999686',NULL,NULL,3,NULL,NULL,NULL),(46,177,'fastq','Multiomics/Epigenome_hic/46/SRR19426890',NULL,'SRR19426890',NULL,NULL,40,NULL,NULL,NULL),(49,205,'profile','Multiomics/Epigenome_hic/49/49.json',NULL,'SRR16465801',NULL,NULL,2,NULL,10,50000),(52,205,'fastq.gz','Multiomics/Epigenome_hic/52/4DNFIMCGWTFO',NULL,'4DNFIMCGWTFO',NULL,NULL,3,NULL,NULL,NULL),(78,68,'profile','Multiomics/Epigenome_hic/78/',NULL,'DRR374915',NULL,NULL,24,100000,10,50000),(79,68,'profile','Multiomics/Epigenome_hic/79/',NULL,'DRR374915',NULL,NULL,24,100000,10,100000),(80,68,'profile','Multiomics/Epigenome_hic/80/',NULL,'DRR374915',NULL,NULL,24,100000,4,10000),(81,175,'profile','Multiomics/Epigenome_hic/81/',NULL,'SRR7802504',NULL,NULL,2,100000,10,100000),(83,282,'profile','Multiomics/Epigenome_hic/83/',NULL,'4DNFIMCGWTFO',NULL,NULL,2,100000,10,50000),(84,288,'profile','Multiomics/Epigenome_hic/84/',NULL,'SRR7802504,4DNFIMCGWTFO',NULL,NULL,2,100000,10,50000),(85,51,'profile','Multiomics/Epigenome_hic/85/',NULL,'SRR12331759',NULL,NULL,38,100000,10,50000),(86,70,'profile',NULL,NULL,'SRR11085806',NULL,NULL,NULL,100000,12,100000),(87,68,'profile','Multiomics/Epigenome_hic/87/',NULL,'DRR374915',NULL,NULL,24,100000,10,1000000);
/*!40000 ALTER TABLE `Epigenome_HiC` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Epigenome_HiC_diff`
--

DROP TABLE IF EXISTS `Epigenome_HiC_diff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Epigenome_HiC_diff` (
  `diff_id` int NOT NULL,
  `path` text,
  `reference_assembly` int DEFAULT NULL,
  `generated_synteny` int DEFAULT NULL,
  `inter_intra` varchar(40) NOT NULL,
  PRIMARY KEY (`diff_id`),
  KEY `reference_assembly` (`reference_assembly`),
  KEY `generated_synteny` (`generated_synteny`),
  CONSTRAINT `Epigenome_HiC_diff_ibfk_1` FOREIGN KEY (`reference_assembly`) REFERENCES `assembly` (`assembly_id`),
  CONSTRAINT `Epigenome_HiC_diff_ibfk_2` FOREIGN KEY (`generated_synteny`) REFERENCES `synteny` (`synteny_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Epigenome_HiC_diff`
--

LOCK TABLES `Epigenome_HiC_diff` WRITE;
/*!40000 ALTER TABLE `Epigenome_HiC_diff` DISABLE KEYS */;
INSERT INTO `Epigenome_HiC_diff` VALUES (1,'Multiomics/Diff/HIC/1',2,107,'intra'),(2,'Multiomics/Diff/HIC/2',2,107,'intra'),(3,'Multiomics/Diff/HIC/3',24,130,'intra');
/*!40000 ALTER TABLE `Epigenome_HiC_diff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Epigenome_HiC_diff_ids`
--

DROP TABLE IF EXISTS `Epigenome_HiC_diff_ids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Epigenome_HiC_diff_ids` (
  `diff_id` int DEFAULT NULL,
  `multiomics_data_id` int DEFAULT NULL,
  KEY `diff_id` (`diff_id`),
  KEY `multiomics_data_id` (`multiomics_data_id`),
  CONSTRAINT `Epigenome_HiC_diff_ids_ibfk_1` FOREIGN KEY (`diff_id`) REFERENCES `Epigenome_HiC_diff` (`diff_id`),
  CONSTRAINT `Epigenome_HiC_diff_ids_ibfk_2` FOREIGN KEY (`multiomics_data_id`) REFERENCES `Epigenome_HiC` (`data_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Epigenome_HiC_diff_ids`
--

LOCK TABLES `Epigenome_HiC_diff_ids` WRITE;
/*!40000 ALTER TABLE `Epigenome_HiC_diff_ids` DISABLE KEYS */;
INSERT INTO `Epigenome_HiC_diff_ids` VALUES (1,49),(1,81),(2,49),(2,81),(2,83),(3,78),(3,79);
/*!40000 ALTER TABLE `Epigenome_HiC_diff_ids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Epigenome_Meth`
--

DROP TABLE IF EXISTS `Epigenome_Meth`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Epigenome_Meth` (
  `data_id` int NOT NULL AUTO_INCREMENT,
  `sample_set_id` int DEFAULT NULL,
  `data_type` text,
  `json_path` text,
  `parameter_path` text,
  `reference` text,
  `SRA_id` text,
  `param_score_min` text,
  `param_N` int DEFAULT NULL,
  `param_L` int DEFAULT NULL,
  `param_mincov` int DEFAULT NULL,
  `param_minqual` int DEFAULT NULL,
  `paired` int DEFAULT NULL,
  `ref_assembly` int DEFAULT NULL,
  PRIMARY KEY (`data_id`),
  KEY `sample_set_id` (`sample_set_id`),
  KEY `ref_assembly` (`ref_assembly`)
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Epigenome_Meth`
--

LOCK TABLES `Epigenome_Meth` WRITE;
/*!40000 ALTER TABLE `Epigenome_Meth` DISABLE KEYS */;
INSERT INTO `Epigenome_Meth` VALUES (2,73,'fastq','Multiomics/Epigenome_meth/2/SRR17709545',NULL,NULL,'SRR17709545',NULL,NULL,NULL,NULL,NULL,1,10),(3,74,'fastq','Multiomics/Epigenome_meth/3/DRR400327',NULL,NULL,'DRR400327',NULL,NULL,NULL,NULL,NULL,1,4),(4,75,'fastq','Multiomics/Epigenome_meth/4/SRR18091043',NULL,NULL,'SRR18091043',NULL,NULL,NULL,NULL,NULL,1,23),(5,76,'fastq','Multiomics/Epigenome_meth/5/SRR18399732',NULL,NULL,'SRR18399732',NULL,NULL,NULL,NULL,NULL,1,18),(6,77,'fastq','Multiomics/Epigenome_meth/6/SRR14664591',NULL,NULL,'SRR14664591',NULL,NULL,NULL,NULL,NULL,1,34),(7,78,'fastq','Multiomics/Epigenome_meth/7/SRR12797060',NULL,NULL,'SRR12797060',NULL,NULL,NULL,NULL,NULL,1,5),(8,79,'fastq','Multiomics/Epigenome_meth/8/SRR17311560',NULL,NULL,'SRR17311560',NULL,NULL,NULL,NULL,NULL,1,NULL),(9,80,'fastq','Multiomics/Epigenome_meth/9/SRR14664594',NULL,NULL,'SRR14664594',NULL,NULL,NULL,NULL,NULL,1,37),(10,81,'fastq','Multiomics/Epigenome_meth/10/SRR8307460',NULL,NULL,'SRR8307460',NULL,NULL,NULL,NULL,NULL,1,11),(11,82,'fastq','Multiomics/Epigenome_meth/11/SRR12190331',NULL,NULL,'SRR12190331',NULL,NULL,NULL,NULL,NULL,1,11),(12,83,'fastq','Multiomics/Epigenome_meth/12/ERR3220177',NULL,NULL,'ERR3220177',NULL,NULL,NULL,NULL,NULL,1,32),(13,84,'fastq','Multiomics/Epigenome_meth/13/SRR10882826',NULL,NULL,'SRR10882826',NULL,NULL,NULL,NULL,NULL,1,30),(14,85,'fastq','Multiomics/Epigenome_meth/14/SRR20694223',NULL,NULL,'SRR20694223',NULL,NULL,NULL,NULL,NULL,1,3),(15,86,'fastq','Multiomics/Epigenome_meth/15/SRR14935314',NULL,NULL,'SRR14935314',NULL,NULL,NULL,NULL,NULL,1,17),(16,87,'fastq','Multiomics/Epigenome_meth/16/SRR19759300',NULL,NULL,'SRR19759300',NULL,NULL,NULL,NULL,NULL,1,40),(17,88,'fastq','Multiomics/Epigenome_meth/17/SRR18578169',NULL,NULL,'SRR18578169',NULL,NULL,NULL,NULL,NULL,1,40),(18,89,'fastq','Multiomics/Epigenome_meth/18/SRR5590025',NULL,NULL,'SRR5590025',NULL,NULL,NULL,NULL,NULL,1,20),(19,90,'fastq','Multiomics/Epigenome_meth/19/SRR9668894',NULL,NULL,'SRR9668894',NULL,NULL,NULL,NULL,NULL,0,8),(20,91,'fastq','Multiomics/Epigenome_meth/20/SRR15404318',NULL,NULL,'SRR15404318',NULL,NULL,NULL,NULL,NULL,1,35),(21,92,'fastq','Multiomics/Epigenome_meth/21/SRR15712135',NULL,NULL,'SRR15712135',NULL,NULL,NULL,NULL,NULL,1,42),(22,93,'fastq','Multiomics/Epigenome_meth/22/SRR15427066',NULL,NULL,'SRR15427066',NULL,NULL,NULL,NULL,NULL,1,2),(34,178,'fastq','Multiomics/Epigenome_meth/34/SRR7289953',NULL,NULL,'SRR7289953',NULL,NULL,NULL,NULL,NULL,0,2),(35,179,'fastq','Multiomics/Epigenome_meth/35/SRR7289946',NULL,NULL,'SRR7289946',NULL,NULL,NULL,NULL,NULL,0,2),(36,180,'fastq','Multiomics/Epigenome_meth/36/SRR7289949',NULL,NULL,'SRR7289949',NULL,NULL,NULL,NULL,NULL,0,2),(37,181,'fastq','Multiomics/Epigenome_meth/37/SRR7289950',NULL,NULL,'SRR7289950',NULL,NULL,NULL,NULL,NULL,0,2),(38,182,'fastq','Multiomics/Epigenome_meth/38/SRR11922814',NULL,NULL,'SRR11922814',NULL,NULL,NULL,NULL,NULL,1,20),(39,183,'fastq','Multiomics/Epigenome_meth/39/SRR7289904',NULL,NULL,'SRR7289904',NULL,NULL,NULL,NULL,NULL,0,20),(40,184,'fastq','Multiomics/Epigenome_meth/40/SRR7289908',NULL,NULL,'SRR7289908',NULL,NULL,NULL,NULL,NULL,0,20),(41,185,'fastq','Multiomics/Epigenome_meth/41/SRR7289910',NULL,NULL,'SRR7289910',NULL,NULL,NULL,NULL,NULL,0,20),(42,186,'fastq','Multiomics/Epigenome_meth/42/SRR7289912',NULL,NULL,'SRR7289912',NULL,NULL,NULL,NULL,NULL,0,20),(43,187,'fastq','Multiomics/Epigenome_meth/43/SRR17850708',NULL,NULL,'SRR17850708',NULL,NULL,NULL,NULL,NULL,0,22),(44,188,'fastq','Multiomics/Epigenome_meth/44/SRR17852279',NULL,NULL,'SRR17852279',NULL,NULL,NULL,NULL,NULL,0,22),(45,189,'fastq','Multiomics/Epigenome_meth/45/SRR7289989',NULL,NULL,'SRR7289989',NULL,NULL,NULL,NULL,NULL,0,30),(46,190,'fastq','Multiomics/Epigenome_meth/46/SRR11922836',NULL,NULL,'SRR11922836',NULL,NULL,NULL,NULL,NULL,1,30),(47,191,'fastq','Multiomics/Epigenome_meth/47/SRR7289990',NULL,NULL,'SRR7289990',NULL,NULL,NULL,NULL,NULL,0,30),(48,192,'fastq','Multiomics/Epigenome_meth/48/SRR7289982',NULL,NULL,'SRR7289982',NULL,NULL,NULL,NULL,NULL,0,30),(49,193,'fastq','Multiomics/Epigenome_meth/49/SRR7289985',NULL,NULL,'SRR7289985',NULL,NULL,NULL,NULL,NULL,0,30),(50,194,'fastq','Multiomics/Epigenome_meth/50/SRR7289987',NULL,NULL,'SRR7289987',NULL,NULL,NULL,NULL,NULL,0,30),(51,195,'fastq','Multiomics/Epigenome_meth/51/SRR15209958',NULL,NULL,'SRR15209958',NULL,NULL,NULL,NULL,NULL,1,18),(52,196,'fastq','Multiomics/Epigenome_meth/52/SRR19759301',NULL,NULL,'SRR19759301',NULL,NULL,NULL,NULL,NULL,1,18),(53,197,'fastq','Multiomics/Epigenome_meth/53/SRR19759298',NULL,NULL,'SRR19759298',NULL,NULL,NULL,NULL,NULL,1,40),(54,198,'fastq','Multiomics/Epigenome_meth/54/ERR3329201',NULL,NULL,'ERR3329201',NULL,NULL,NULL,NULL,NULL,0,19),(56,180,'profile','Multiomics/Epigenome_meth/56/56.json',NULL,NULL,'SRR7289949',NULL,NULL,NULL,NULL,NULL,0,2),(57,185,'profile','Multiomics/Epigenome_meth/57/57.json',NULL,NULL,'SRR7289910',NULL,NULL,NULL,NULL,NULL,0,20),(58,85,'profile','Multiomics/Epigenome_meth/58/58.json',NULL,NULL,'SRR20694223',NULL,NULL,NULL,NULL,NULL,1,3),(59,187,'profile','Multiomics/Epigenome_meth/59/',NULL,NULL,'SRR17850708',NULL,NULL,NULL,NULL,NULL,0,22),(62,72,'profile',NULL,NULL,NULL,NULL,'L,0,-0.6',0,20,10,10,NULL,NULL),(63,74,'profile','Multiomics/Epigenome_meth/63/',NULL,NULL,'DRR400327','L,0,-0.6',0,20,10,10,NULL,4),(64,74,'profile','Multiomics/Epigenome_meth/64/',NULL,NULL,'DRR400327','L,0,-0.6',0,20,3,10,NULL,4),(65,78,'profile','Multiomics/Epigenome_meth/65/',NULL,NULL,'SRR12797060','L,0,-0.6',0,20,10,10,NULL,5),(66,90,'profile','Multiomics/Epigenome_meth/66',NULL,NULL,'SRR9668894','L,0,-0.6',0,20,10,10,NULL,8),(67,178,'profile','Multiomics/Epigenome_meth/67/',NULL,NULL,'SRR7289953','L,0,-0.6',0,20,10,10,NULL,2),(68,78,'profile','Multiomics/Epigenome_meth/68/',NULL,NULL,'SRR12797060','L,0,-0.6',0,20,2,10,NULL,5),(69,93,'profile',NULL,NULL,NULL,NULL,'L,0,-0.6',0,20,10,10,NULL,NULL),(70,78,'profile','Multiomics/Epigenome_meth/70/',NULL,NULL,'SRR12797060','L,0,-0.6',0,20,20,10,NULL,5);
/*!40000 ALTER TABLE `Epigenome_Meth` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Epigenome_Meth_diff`
--

DROP TABLE IF EXISTS `Epigenome_Meth_diff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Epigenome_Meth_diff` (
  `diff_id` int NOT NULL,
  `path` text,
  `reference_assembly` int DEFAULT NULL,
  `generated_synteny` int DEFAULT NULL,
  `inter_intra` varchar(40) NOT NULL,
  PRIMARY KEY (`diff_id`),
  KEY `reference_assembly` (`reference_assembly`),
  KEY `generated_synteny` (`generated_synteny`),
  CONSTRAINT `Epigenome_Meth_diff_ibfk_1` FOREIGN KEY (`reference_assembly`) REFERENCES `assembly` (`assembly_id`),
  CONSTRAINT `Epigenome_Meth_diff_ibfk_2` FOREIGN KEY (`generated_synteny`) REFERENCES `synteny` (`synteny_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Epigenome_Meth_diff`
--

LOCK TABLES `Epigenome_Meth_diff` WRITE;
/*!40000 ALTER TABLE `Epigenome_Meth_diff` DISABLE KEYS */;
INSERT INTO `Epigenome_Meth_diff` VALUES (1,'Multiomics/Diff/METH/1',2,122,'intra'),(2,'Multiomics/Diff/METH/2',5,118,'intra');
/*!40000 ALTER TABLE `Epigenome_Meth_diff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Epigenome_Meth_diff_ids`
--

DROP TABLE IF EXISTS `Epigenome_Meth_diff_ids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Epigenome_Meth_diff_ids` (
  `diff_id` int DEFAULT NULL,
  `multiomics_data_id` int DEFAULT NULL,
  KEY `diff_id` (`diff_id`),
  KEY `multiomics_data_id` (`multiomics_data_id`),
  CONSTRAINT `Epigenome_Meth_diff_ids_ibfk_1` FOREIGN KEY (`diff_id`) REFERENCES `Epigenome_Meth_diff` (`diff_id`),
  CONSTRAINT `Epigenome_Meth_diff_ids_ibfk_2` FOREIGN KEY (`multiomics_data_id`) REFERENCES `Epigenome_Meth` (`data_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Epigenome_Meth_diff_ids`
--

LOCK TABLES `Epigenome_Meth_diff_ids` WRITE;
/*!40000 ALTER TABLE `Epigenome_Meth_diff_ids` DISABLE KEYS */;
INSERT INTO `Epigenome_Meth_diff_ids` VALUES (1,56),(1,67),(2,65),(2,68),(2,70);
/*!40000 ALTER TABLE `Epigenome_Meth_diff_ids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Genome`
--

DROP TABLE IF EXISTS `Genome`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Genome` (
  `data_id` int NOT NULL AUTO_INCREMENT,
  `synteny_id` int DEFAULT NULL,
  `data_type` text,
  `path` text,
  PRIMARY KEY (`data_id`),
  KEY `synteny_id` (`synteny_id`),
  CONSTRAINT `Genome_ibfk_1` FOREIGN KEY (`synteny_id`) REFERENCES `synteny` (`synteny_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Genome`
--

LOCK TABLES `Genome` WRITE;
/*!40000 ALTER TABLE `Genome` DISABLE KEYS */;
INSERT INTO `Genome` VALUES (6,107,'profile','Multiomics/Genome/107'),(7,108,'profile','Multiomics/Genome/108'),(10,113,'profile','Multiomics/Genome/113'),(11,114,'profile','Multiomics/Genome/114'),(14,115,'profile','Multiomics/Genome/115'),(16,118,'profile','Multiomics/Genome/118'),(17,122,'profile','Multiomics/Genome/122'),(20,127,'profile','Multiomics/Genome/127'),(21,128,'profile','Multiomics/Genome/128'),(22,129,'profile','Multiomics/Genome/129'),(23,130,'profile','Multiomics/Genome/130'),(24,131,'profile','Multiomics/Genome/131'),(25,133,'profile','Multiomics/Genome/133'),(26,134,'profile','Multiomics/Genome/134');
/*!40000 ALTER TABLE `Genome` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Transcriptome`
--

DROP TABLE IF EXISTS `Transcriptome`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Transcriptome` (
  `data_id` int NOT NULL AUTO_INCREMENT,
  `sample_set_id` int DEFAULT NULL,
  `data_type` text,
  `json_path` text,
  `parameter_path` text,
  `reference` text,
  `SRA_id` text,
  `param_genomeSAindexNbases` int DEFAULT NULL,
  `paired` int DEFAULT NULL,
  `ref_assembly` int DEFAULT NULL,
  PRIMARY KEY (`data_id`),
  KEY `sample_set_id` (`sample_set_id`),
  KEY `ref_assembly` (`ref_assembly`)
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Transcriptome`
--

LOCK TABLES `Transcriptome` WRITE;
/*!40000 ALTER TABLE `Transcriptome` DISABLE KEYS */;
INSERT INTO `Transcriptome` VALUES (2,2,'fastq.gz','Multiomics/Transcriptome/2/SRR9987838',NULL,NULL,'SRR9987838',NULL,1,13),(3,3,'fastq','Multiomics/Transcriptome/3/SRR17709541',NULL,NULL,'SRR17709541',NULL,1,4),(4,4,'fastq.gz','Multiomics/Transcriptome/4/SRR526996',NULL,NULL,'SRR526996',NULL,1,18),(5,5,'fastq.gz','Multiomics/Transcriptome/5/SRR17319961',NULL,NULL,'SRR17319961',NULL,1,12),(6,6,'fastq','Multiomics/Transcriptome/6/SRR17335940',NULL,NULL,'SRR17335940',NULL,1,22),(7,7,'fastq','Multiomics/Transcriptome/7/SRR19614472',NULL,NULL,'SRR19614472',NULL,1,34),(8,8,'fastq','Multiomics/Transcriptome/8/SRR21177740',NULL,NULL,'SRR21177740',NULL,1,5),(9,9,'fastq','Multiomics/Transcriptome/9/ERR5198846',NULL,NULL,'ERR5198846',NULL,1,31),(10,10,'fastq','Multiomics/Transcriptome/10/SRR16153092',NULL,NULL,'SRR16153092',NULL,0,39),(11,11,'fastq','Multiomics/Transcriptome/11/SRR9678426',NULL,NULL,'SRR9678426',NULL,1,38),(12,12,'fastq.gz','Multiomics/Transcriptome/12/SRR21046748',NULL,NULL,'SRR21046748',NULL,1,19),(13,13,'fastq.gz','Multiomics/Transcriptome/13/SRR21160529',NULL,NULL,'SRR21160529',NULL,1,NULL),(14,14,'fastq','Multiomics/Transcriptome/14/SRR19454929',NULL,NULL,'SRR19454929',NULL,1,43),(15,15,'fastq','Multiomics/Transcriptome/15/SRR20821354',NULL,NULL,'SRR20821354',NULL,1,36),(16,16,'fastq','Multiomics/Transcriptome/16/SRR19629937',NULL,NULL,'SRR19629937',NULL,1,41),(17,17,'fastq.gz','Multiomics/Transcriptome/17/SRR089762',NULL,NULL,'SRR089762',NULL,0,11),(18,18,'fastq.gz','Multiomics/Transcriptome/18/SRR18961106',NULL,NULL,'SRR18961106',NULL,1,32),(19,19,'fastq.gz','Multiomics/Transcriptome/19/SRR10746623',NULL,NULL,'SRR10746623',NULL,1,15),(20,20,'fastq','Multiomics/Transcriptome/20/SRR18171586',NULL,NULL,'SRR18171586',NULL,1,30),(21,21,'fastq','Multiomics/Transcriptome/21/SRR13142105',NULL,NULL,'SRR13142105',NULL,1,7),(22,22,'fastq','Multiomics/Transcriptome/22/ERR3418017',NULL,NULL,'ERR3418017',NULL,1,7),(23,23,'fastq','Multiomics/Transcriptome/23/SRR21229726',NULL,NULL,'SRR21229726',NULL,1,3),(24,24,'fastq.gz','Multiomics/Transcriptome/24/SRR10075409',NULL,NULL,'SRR10075409',NULL,1,27),(25,25,'fastq.gz','Multiomics/Transcriptome/25/SRR5412241',NULL,NULL,'SRR5412241',NULL,0,25),(26,26,'fastq.gz','Multiomics/Transcriptome/26/SRR21019288',NULL,NULL,'SRR21019288',NULL,1,17),(27,27,'fastq','Multiomics/Transcriptome/27/SRR21177733',NULL,NULL,'SRR21177733',NULL,1,40),(28,28,'fastq','Multiomics/Transcriptome/28/SRR19917845',NULL,NULL,'SRR19917845',NULL,1,40),(29,29,'fastq','Multiomics/Transcriptome/29/SRR8750444',NULL,NULL,'SRR8750444',NULL,1,33),(30,30,'fastq','Multiomics/Transcriptome/30/SRR17171631',NULL,NULL,'SRR17171631',NULL,0,20),(31,31,'fastq','Multiomics/Transcriptome/31/SRR12416113',NULL,NULL,'SRR12416113',NULL,0,29),(32,32,'fastq.gz','Multiomics/Transcriptome/32/SRR8468522',NULL,NULL,'SRR8468522',NULL,1,26),(33,33,'fastq.gz','Multiomics/Transcriptome/33/SRR12414065',NULL,NULL,'SRR12414065',NULL,1,21),(34,34,'fastq','Multiomics/Transcriptome/34/SRR11462690',NULL,NULL,'SRR11462690',NULL,0,8),(35,35,'fastq','Multiomics/Transcriptome/35/SRR21229178',NULL,NULL,'SRR21229178',NULL,1,35),(36,36,'fastq.gz','Multiomics/Transcriptome/36/SRR8261764',NULL,NULL,'SRR8261764',NULL,0,14),(37,37,'fastq.gz','Multiomics/Transcriptome/37/SRR8065008',NULL,NULL,'SRR8065008',NULL,0,24),(38,38,'fastq','Multiomics/Transcriptome/38/SRR12415882',NULL,NULL,'SRR12415882',NULL,1,44),(39,39,'fastq','Multiomics/Transcriptome/39/SRR13080677',NULL,NULL,'SRR13080677',NULL,1,9),(51,149,'fastq','Multiomics/Transcriptome/51/SRR6900785',NULL,NULL,'SRR6900785',NULL,0,2),(52,150,'fastq','Multiomics/Transcriptome/52/SRR6900782',NULL,NULL,'SRR6900782',NULL,0,2),(53,151,'fastq','Multiomics/Transcriptome/53/SRR21474014',NULL,NULL,'SRR21474014',NULL,1,2),(54,152,'fastq','Multiomics/Transcriptome/54/SRR6900784',NULL,NULL,'SRR6900784',NULL,0,2),(55,153,'fastq','Multiomics/Transcriptome/55/SRR6900765',NULL,NULL,'SRR6900765',NULL,0,20),(56,154,'fastq','Multiomics/Transcriptome/56/SRR6900766',NULL,NULL,'SRR6900766',NULL,0,20),(57,155,'fastq','Multiomics/Transcriptome/57/SRR6900767',NULL,NULL,'SRR6900767',NULL,0,20),(58,156,'fastq','Multiomics/Transcriptome/58/SRR6900768',NULL,NULL,'SRR6900768',NULL,0,20),(59,157,'fastq','Multiomics/Transcriptome/59/SRR12764821',NULL,NULL,'SRR12764821',NULL,1,20),(60,158,'fastq','Multiomics/Transcriptome/60/ERR3492178',NULL,NULL,'ERR3492178',NULL,1,20),(61,159,'fastq','Multiomics/Transcriptome/61/ERR3491497',NULL,NULL,'ERR3491497',NULL,1,33),(62,160,'fastq','Multiomics/Transcriptome/62/SRR306836',NULL,NULL,'SRR306836',NULL,0,33),(63,161,'fastq','Multiomics/Transcriptome/63/SRR11232021',NULL,NULL,'SRR11232021',NULL,0,22),(64,162,'fastq','Multiomics/Transcriptome/64/SRR9825007',NULL,NULL,'SRR9825007',NULL,0,22),(65,163,'fastq','Multiomics/Transcriptome/65/SRR11734136',NULL,NULL,'SRR11734136',NULL,0,22),(66,164,'fastq','Multiomics/Transcriptome/66/SRR6900801',NULL,NULL,'SRR6900801',NULL,0,30),(67,165,'fastq','Multiomics/Transcriptome/67/SRR6900798',NULL,NULL,'SRR6900798',NULL,0,30),(68,166,'fastq','Multiomics/Transcriptome/68/SRR6900799',NULL,NULL,'SRR6900799',NULL,0,30),(69,167,'fastq','Multiomics/Transcriptome/69/SRR6900900',NULL,NULL,'SRR6900900',NULL,1,30),(71,169,'fastq','Multiomics/Transcriptome/71/SRR18095901',NULL,NULL,'SRR18095901',NULL,1,18),(72,170,'fastq','Multiomics/Transcriptome/72/SRR14093221',NULL,NULL,'SRR14093221',NULL,0,18),(73,171,'fastq','Multiomics/Transcriptome/73/ERR3418011',NULL,NULL,'ERR3418011',NULL,1,40),(74,172,'fastq','Multiomics/Transcriptome/74/SRR19662886',NULL,NULL,'SRR19662886',NULL,1,40),(75,173,'fastq','Multiomics/Transcriptome/75/SRR12442779',NULL,NULL,'SRR12442779',NULL,0,19),(82,150,'profile','Multiomics/Transcriptome/52/SRR6900782',NULL,NULL,'SRR6900782',NULL,0,2),(83,23,'profile','Multiomics/Transcriptome/83/83.json',NULL,NULL,'SRR21229726',NULL,1,3),(84,154,'profile','Multiomics/Transcriptome/56/SRR6900766',NULL,NULL,'SRR6900766',NULL,0,20),(85,6,'profile','Multiomics/Transcriptome/85/85.json',NULL,NULL,'SRR17335940',NULL,1,22),(86,158,'profile','Multiomics/Transcriptome/86/',NULL,NULL,'ERR3492178',NULL,NULL,20),(87,3,'profile','Multiomics/Transcriptome/87/',NULL,NULL,'SRR17709541',NULL,NULL,4),(89,169,'profile','Multiomics/Transcriptome/89/',NULL,NULL,'SRR18095901',NULL,NULL,18),(91,30,'profile','Multiomics/Transcriptome/91/',NULL,NULL,'SRR17171631',NULL,NULL,20),(92,39,'profile','Multiomics/Transcriptome/92/',NULL,NULL,'SRR13080677',NULL,NULL,9),(104,15,'profile','Multiomics/Transcriptome/104/',NULL,NULL,'SRR20821354',NULL,NULL,36),(105,10,'profile','Multiomics/Transcriptome/105/',NULL,NULL,'SRR16153092',NULL,NULL,39),(108,162,'profile','Multiomics/Transcriptome/108/',NULL,NULL,'SRR9825007',NULL,NULL,22),(111,27,'profile','Multiomics/Transcriptome/111/',NULL,NULL,'SRR21177733',NULL,NULL,40),(112,11,'profile','Multiomics/Transcriptome/112/',NULL,NULL,'SRR9678426',NULL,NULL,38),(113,17,'profile','Multiomics/Transcriptome/113/',NULL,NULL,'SRR089762',NULL,NULL,11),(116,9,'profile','Multiomics/Transcriptome/116/',NULL,NULL,'ERR5198846',NULL,NULL,31),(117,38,'profile','Multiomics/Transcriptome/117/',NULL,NULL,'SRR12415882',NULL,NULL,44),(118,8,'profile','Multiomics/Transcriptome/118/',NULL,NULL,'SRR21177740',NULL,NULL,5),(119,5,'profile','Multiomics/Transcriptome/119/',NULL,NULL,'SRR17319961',NULL,NULL,12),(120,37,'profile','Multiomics/Transcriptome/120/',NULL,NULL,'SRR8065008',NULL,NULL,24);
/*!40000 ALTER TABLE `Transcriptome` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Transcriptome_diff`
--

DROP TABLE IF EXISTS `Transcriptome_diff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Transcriptome_diff` (
  `diff_id` int NOT NULL,
  `path` text,
  `reference_assembly` int DEFAULT NULL,
  `generated_synteny` int DEFAULT NULL,
  `inter_intra` varchar(40) NOT NULL,
  PRIMARY KEY (`diff_id`),
  KEY `reference_assembly` (`reference_assembly`),
  KEY `generated_synteny` (`generated_synteny`),
  CONSTRAINT `Transcriptome_diff_ibfk_1` FOREIGN KEY (`reference_assembly`) REFERENCES `assembly` (`assembly_id`),
  CONSTRAINT `Transcriptome_diff_ibfk_2` FOREIGN KEY (`generated_synteny`) REFERENCES `synteny` (`synteny_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Transcriptome_diff`
--

LOCK TABLES `Transcriptome_diff` WRITE;
/*!40000 ALTER TABLE `Transcriptome_diff` DISABLE KEYS */;
INSERT INTO `Transcriptome_diff` VALUES (1,'Multiomics/Diff/RNA/1/',20,107,'intra'),(2,'Multiomics/Diff/RNA/2',20,107,'intra');
/*!40000 ALTER TABLE `Transcriptome_diff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Transcriptome_diff_ids`
--

DROP TABLE IF EXISTS `Transcriptome_diff_ids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Transcriptome_diff_ids` (
  `diff_id` int DEFAULT NULL,
  `multiomics_data_id` int DEFAULT NULL,
  KEY `diff_id` (`diff_id`),
  KEY `multiomics_data_id` (`multiomics_data_id`),
  CONSTRAINT `Transcriptome_diff_ids_ibfk_1` FOREIGN KEY (`diff_id`) REFERENCES `Transcriptome_diff` (`diff_id`),
  CONSTRAINT `Transcriptome_diff_ids_ibfk_2` FOREIGN KEY (`multiomics_data_id`) REFERENCES `Transcriptome` (`data_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Transcriptome_diff_ids`
--

LOCK TABLES `Transcriptome_diff_ids` WRITE;
/*!40000 ALTER TABLE `Transcriptome_diff_ids` DISABLE KEYS */;
INSERT INTO `Transcriptome_diff_ids` VALUES (1,84),(1,86),(2,84),(2,86),(2,91);
/*!40000 ALTER TABLE `Transcriptome_diff_ids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alignment`
--

DROP TABLE IF EXISTS `alignment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alignment` (
  `alignment_id` int DEFAULT NULL,
  `reference_assembly` int DEFAULT NULL,
  `target_assembly` int DEFAULT NULL,
  `path` text,
  `status` int DEFAULT NULL,
  `program` text,
  KEY `reference_assembly` (`reference_assembly`),
  KEY `target_assembly` (`target_assembly`),
  CONSTRAINT `alignment_ibfk_1` FOREIGN KEY (`reference_assembly`) REFERENCES `assembly` (`assembly_id`),
  CONSTRAINT `alignment_ibfk_2` FOREIGN KEY (`target_assembly`) REFERENCES `species_set_header` (`species_set_id`),
  CONSTRAINT `alignment_ibfk_3` FOREIGN KEY (`target_assembly`) REFERENCES `species_set_header` (`species_set_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alignment`
--

LOCK TABLES `alignment` WRITE;
/*!40000 ALTER TABLE `alignment` DISABLE KEYS */;
INSERT INTO `alignment` VALUES (1,36,12,'ALIGNMENT/LASTZ/1/',1,'LASTZ'),(3,36,16,'ALIGNMENT/LASTZ/3/',1,'LASTZ'),(5,9,15,'ALIGNMENT/LASTZ/5/',1,'LASTZ'),(6,18,10,'ALIGNMENT/LASTZ/6/',1,'LASTZ'),(7,18,11,'ALIGNMENT/LASTZ/7/',1,'LASTZ'),(8,18,9,'ALIGNMENT/LASTZ/8/',1,'LASTZ'),(9,18,13,'ALIGNMENT/LASTZ/9/',1,'LASTZ'),(10,18,12,'ALIGNMENT/LASTZ/10/',1,'LASTZ'),(11,18,2,'ALIGNMENT/LASTZ/11/',1,'LASTZ'),(12,2,5,'ALIGNMENT/LASTZ/12/',1,'LASTZ'),(13,2,2,'ALIGNMENT/LASTZ/13/',1,'LASTZ'),(14,2,55,'ALIGNMENT/LASTZ/14/',1,'LASTZ'),(15,2,8,'ALIGNMENT/LASTZ/15/',1,'LASTZ'),(16,2,56,'ALIGNMENT/LASTZ/16/',1,'LASTZ'),(17,2,7,'ALIGNMENT/LASTZ/17/',1,'LASTZ'),(18,2,1,'ALIGNMENT/LASTZ/18/',1,'LASTZ'),(19,2,57,'ALIGNMENT/LASTZ/19/',1,'LASTZ'),(20,2,12,'ALIGNMENT/LASTZ/20/',1,'LASTZ'),(24,4,60,'ALIGNMENT/LASTZ/24/',1,'LASTZ'),(25,4,61,'ALIGNMENT/LASTZ/25/',1,'LASTZ'),(26,4,62,'ALIGNMENT/LASTZ/26/',1,'LASTZ'),(27,5,63,'ALIGNMENT/LASTZ/27/',1,'LASTZ'),(2,36,4,'ALIGNMENT/LASTZ/2/',1,'LASTZ'),(32,3,196,'ALIGNMENT/LASTZ/32/',1,'LASTZ'),(33,3,198,'ALIGNMENT/LASTZ/33/',1,'LASTZ'),(34,47,246,'ALIGNMENT/LASTZ/34',1,'LASTZ'),(36,39,220,'ALIGNMENT/LASTZ/36',1,'LASTZ'),(37,39,252,'ALIGNMENT/LASTZ/37',1,'LASTZ'),(43,11,219,'ALIGNMENT/LASTZ/43',1,'LASTZ'),(44,8,219,'ALIGNMENT/LASTZ/44',1,'LASTZ'),(45,12,59,'ALIGNMENT/LASTZ/45',1,'LASTZ'),(46,12,58,'ALIGNMENT/LASTZ/46',1,'LASTZ'),(50,39,59,'ALIGNMENT/LASTZ/50',1,'LASTZ'),(53,11,62,'ALIGNMENT/LASTZ/53',1,'LASTZ'),(55,12,222,'ALIGNMENT/LASTZ/55',1,'LASTZ'),(56,5,16,'ALIGNMENT/LASTZ/56',1,'LASTZ'),(57,5,252,'ALIGNMENT/LASTZ/57',1,'LASTZ'),(58,11,3,'ALIGNMENT/LASTZ/58',1,'LASTZ'),(59,5,222,'ALIGNMENT/LASTZ/59',1,'LASTZ'),(60,5,218,'ALIGNMENT/LASTZ/60',1,'LASTZ'),(66,31,58,'ALIGNMENT/LASTZ/66',1,'LASTZ'),(67,2,218,'ALIGNMENT/LASTZ/67',1,'LASTZ'),(68,2,14,'ALIGNMENT/LASTZ/68',1,'LASTZ'),(69,20,212,NULL,0,'LASTZ'),(70,24,59,'ALIGNMENT/LASTZ/70',1,'LASTZ'),(71,2,264,NULL,0,'LASTZ'),(72,2,198,NULL,0,'LASTZ'),(73,38,58,NULL,0,'LASTZ'),(74,9,16,'ALIGNMENT/LASTZ/74',1,'LASTZ'),(75,9,252,'ALIGNMENT/LASTZ/75',1,'LASTZ'),(76,NULL,261,'ALIGNMENT/LASTZ/76',1,'LASTZ'),(77,12,6,'ALIGNMENT/LASTZ/77',1,'LASTZ'),(78,12,204,'ALIGNMENT/LASTZ/78',1,'LASTZ'),(79,43,269,'ALIGNMENT/LASTZ/79',1,'LASTZ'),(80,19,5,NULL,0,'LASTZ');
/*!40000 ALTER TABLE `alignment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assembly`
--

DROP TABLE IF EXISTS `assembly`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assembly` (
  `assembly_id` int NOT NULL AUTO_INCREMENT,
  `resource` char(30) DEFAULT NULL,
  `taxon_id` int DEFAULT NULL,
  `accession` char(30) DEFAULT NULL,
  `breed` char(50) DEFAULT NULL,
  `path` text,
  `annotation_path` text,
  `status` int DEFAULT NULL,
  PRIMARY KEY (`assembly_id`),
  KEY `assembly_ibfk_1` (`taxon_id`),
  CONSTRAINT `assembly_ibfk_1` FOREIGN KEY (`taxon_id`) REFERENCES `taxon_id` (`taxon_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=135 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assembly`
--

LOCK TABLES `assembly` WRITE;
/*!40000 ALTER TABLE `assembly` DISABLE KEYS */;
INSERT INTO `assembly` VALUES (2,'refseq',9606,'GCF_000001405.39','GRCh38.p13','2/2.fa','2/2.gtf',1),(3,'refseq',10090,'GCF_000001635.27','GRCm39','3/3.fa','3/3.gtf',1),(4,'refseq',3702,'GCF_000001735.4','TAIR10.1','4/4.fa','4/4.gtf',1),(5,'refseq',7955,'GCF_000002035.6','GRCz11','5/5.fa','5/5.gtf',1),(6,'refseq',9612,'GCF_000002285.5','Dog10K_Boxer_Tasha','6/6.fa','6/6.gtf',1),(7,'refseq',13616,'GCF_000002295.2','MonDom5','7/7.fa','7/7.gtf',1),(8,'refseq',3694,'GCF_000002775.4','Pop_tri_v3','8/8.fa','8/8.gtf',1),(9,'refseq',8364,'GCF_000004195.4','UCB_Xtro_10.0','9/9.fa','9/9.gtf',1),(10,'refseq',59689,'GCF_000004255.2','v.1.0','10/10.fa','10/10.gtf',1),(11,'refseq',3847,'GCF_000004515.6','Glycine_max_v4.0','11/11.fa','11/11.gtf',1),(12,'refseq',6238,'GCF_000004555.2','CB4','12/12.fa','12/12.gtf',1),(13,'refseq',7165,'GCF_000005575.2','AgamP3','13/13.fa','13/13.gtf',1),(14,'refseq',88036,'GCF_000143415.4','v1.0','14/14.fa','14/14.gtf',1),(15,'refseq',9103,'GCF_000146605.3','Turkey_5.1','15/15.fa','15/15.gtf',1),(16,'refseq',9541,'GCF_000364345.1','Macaca_fascicularis_5.0','16/16.fa','16/16.gtf',1),(17,'refseq',4530,'GCF_001433935.1','IRGSP-1.0','17/17.fa','17/17.gtf',1),(18,'refseq',9913,'GCF_002263795.1','ARS-UCD1.2','18/18.fa','18/18.gtf',1),(19,'refseq',9796,'GCF_002863925.1','EquCab3.0','19/19.fa','19/19.gtf',1),(20,'refseq',9598,'GCF_002880755.1','Clint_PTRv2','20/20.fa','20/20.gtf',1),(21,'refseq',9601,'GCF_002880775.1','Susie_PABv2','21/21.fa','21/21.gtf',1),(22,'refseq',9483,'GCF_009663435.1','Callithrix_jacchus_cj1700_1.1','22/22.fa','22/22.gtf',1),(23,'refseq',30522,'GCF_003369695.1','UOA_Brahman_1','23/23.fa','23/23.gtf',1),(24,'refseq',59729,'GCF_003957565.2','bTaeGut1.4.pri','24/24.fa','24/24.gtf',1),(25,'refseq',9258,'GCF_004115215.2','mOrnAna1.pri.v4','25/25.fa','25/25.gtf',1),(26,'refseq',64176,'GCF_004329235.1','PodMur_1.0','26/26.fa','26/26.gtf',1),(27,'refseq',61853,'GCF_006542625.1','Asia_NLE_v1','27/27.fa','27/27.gtf',1),(28,'refseq',9595,'GCF_008122165.1','Kamilah_GGO_v0','28/28.fa','28/28.gtf',1),(29,'refseq',9555,'GCF_008728515.1','Panubis1.0','29/29.fa','29/29.gtf',1),(30,'refseq',9544,'GCF_003339765.1','Mmul_10','30/30.fa','30/30.gtf',1),(31,'refseq',7237,'GCF_009870125.1','UCI_Dpse_MV25','31/31.fa','31/31.gtf',1),(32,'refseq',9541,'GCF_012559485.2','MFA1912RKSv2','32/32.fa','32/32.gtf',1),(33,'refseq',9597,'GCF_013052645.1','Mhudiblu_PPA_v0','33/33.fa','33/33.gtf',1),(34,'refseq',9612,'GCF_014441545.1','ROS_Cfam_1.0','34/34.fa','34/34.gtf',1),(35,'refseq',10116,'GCF_015227675.2','mRatBN7.2','35/35.fa','35/35.gtf',1),(36,'refseq',9031,'GCF_016699485.2','bGalGal1.mat.broiler.GRCg7b','36/36.fa','36/36.gtf',1),(37,'refseq',9031,'GCF_016700215.1','bGalGal1.pat.whiteleghornlayer.GRCg7w','37/37.fa','37/37.gtf',1),(38,'refseq',7245,'GCF_016746365.2','Prin_Dyak_Tai18E2_2.1','38/38.fa','38/38.gtf',1),(39,'refseq',7240,'GCF_016746395.2','Prin_Dsim_3.1','39/39.fa','39/39.gtf',1),(40,'refseq',9940,'GCF_016772045.1','ARS-UI_Ramb_v2.0','40/40.fa','40/40.gtf',1),(41,'refseq',69293,'GCF_016920845.1','GAculeatus_UGA_version5','41/41.fa','41/41.gtf',1),(42,'refseq',8355,'GCF_017654675.1','Xenopus_laevis_v10.1','42/42.fa','42/42.gtf',1),(43,'refseq',9685,'GCF_018350175.1','F.catus_Fca126_mat1.0','43/43.fa','43/43.gtf',1),(44,'refseq',31033,'GCF_901000725.2','fTakRub1.2','44/44.fa','44/44.gtf',1),(45,'refseq',7070,'GCF_000002335.3','Tcas5.2','45/45.fa','45/45.gtf',1),(46,'refseq',3218,'GCF_000002425.4','Phypa_V3','46/46.fa','46/46.gtf',1),(47,'refseq',5478,'GCF_000002545.3','ASM254v2','47/47.fa','47/47.gtf',1),(48,'refseq',3055,'GCF_000002595.2','Chlamydomonas_reinhardtii_v5.5','48/48.fa','48/48.gtf',1),(49,'refseq',330879,'GCF_000002655.1','ASM265v1','49/49.fa','49/49.gtf',1),(50,'refseq',9986,'GCF_000003625.3','OryCun2.0','50/50.fa','50/50.gtf',1),(51,'refseq',79684,'GCF_000317375.1','MicOch1.0','51/51.fa','51/51.gtf',1),(52,'refseq',7739,'GCF_000003815.2','Bfl_VNyyK','52/52.fa','52/52.gtf',1),(53,'refseq',3659,'GCF_000004075.3','Cucumber_9930_V3','53/53.fa','53/53.gtf',1),(54,'refseq',28377,'GCF_000090745.1','AnoCar2.0','54/54.fa','54/54.gtf',1),(55,'refseq',15368,'GCF_000005505.3','Brachypodium_distachyon_v3.0','55/55.fa','55/55.gtf',1),(56,'refseq',8996,'GCF_002078875.1','NumMel1.0','56/56.fa','56/56.gtf',1),(57,'refseq',106582,'GCF_000238955.4','M_zebra_UMD2a','57/57.fa','57/57.gtf',1);
/*!40000 ALTER TABLE `assembly` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `diff_data_set`
--

DROP TABLE IF EXISTS `diff_data_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `diff_data_set` (
  `data_id` int NOT NULL,
  `profile_name` text,
  `profile_id` int NOT NULL,
  `assembly` int NOT NULL,
  KEY `assembly` (`assembly`),
  CONSTRAINT `diff_data_set_ibfk_1` FOREIGN KEY (`assembly`) REFERENCES `assembly` (`assembly_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diff_data_set`
--

LOCK TABLES `diff_data_set` WRITE;
/*!40000 ALTER TABLE `diff_data_set` DISABLE KEYS */;
INSERT INTO `diff_data_set` VALUES (1,'meth',56,2),(1,'meth',58,3);
/*!40000 ALTER TABLE `diff_data_set` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `distance`
--

DROP TABLE IF EXISTS `distance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `distance` (
  `species1` int NOT NULL,
  `species2` int NOT NULL,
  `distance` double NOT NULL,
  KEY `species1` (`species1`),
  KEY `species2` (`species2`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `distance`
--

LOCK TABLES `distance` WRITE;
/*!40000 ALTER TABLE `distance` DISABLE KEYS */;
INSERT INTO `distance` VALUES (36,3,623.80784),(36,24,196.08574),(36,15,74.4),(9,42,113.24273),(18,23,1.25284),(5,24,870.64818),(18,19,155.50991),(18,40,49.2),(18,33,192.92478),(2,20,13.30181),(2,33,13.30181),(2,22,58.88309),(2,28,18.12619),(24,38,1593.11126),(2,27,40.37843),(2,15,623.80742),(2,21,31.52433),(1,31,74.36916),(1,39,11.75024),(1,38,22.88219),(4,17,320.95425),(5,41,459.80552),(18,43,155.50991),(36,37,0),(18,3,192.92478),(18,22,192.92478),(19,20,192.9248),(43,25,353.85477),(12,5,1593.11157),(12,31,1486.00029),(9,26,703.51696),(9,24,703.51695),(2,32,58.88305),(19,3,192.92484),(36,30,623.8074),(39,38,22.8822),(20,33,5.64012),(14,36,2991.52847),(12,39,1486.00026),(12,38,1486.00025),(8,4,211.99993),(11,43,2991.5273),(5,3,870.64779),(39,26,1593.11126),(14,26,2991.52841),(7,16,317.19511),(2,36,623.80743),(11,30,2991.52726),(1,11,2991.52759),(2,29,58.88309),(2,16,58.88309),(37,24,196.08588),(8,12,2991.52789),(14,9,2991.52835),(27,40,192.92468),(11,26,2991.52775),(2,8,2991.52725),(5,20,870.64774),(14,39,2991.52826),(14,12,2991.5286),(5,36,870.64824),(39,31,74.36919),(5,2,870.64773),(22,29,86.30253),(19,40,155.50982),(12,26,1593.11161),(29,42,703.51643),(4,20,2991.5278),(4,21,2991.5278),(8,11,211.99997),(1,5,1593.11123),(14,31,2991.52829),(12,22,1593.11125),(2,43,192.92475),(3,7,317.1952),(3,40,192.92474),(30,7,317.19511),(30,18,192.92464),(3,35,41.77483),(42,19,703.51652),(2,31,1593.11085),(2,3,179.64637),(2,18,192.92468),(14,2,2991.52796),(14,37,2991.52847),(7,19,317.19519),(35,24,623.80742),(1,2,1593.11082),(5,44,459.80552),(42,3,703.51652),(24,15,196.08587),(47,49,9999),(35,18,192.92473),(8,38,2991.52754),(2,30,58.88305),(26,36,559.31408),(26,35,623.80742),(1,4,2991.52756),(1,12,1486.00026),(9,4,2991.52765),(14,8,862.50269),(4,11,211.99993),(26,5,870.64818),(14,11,862.50274),(26,44,870.64814),(14,4,862.5027),(5,8,2991.52766),(12,24,1593.1116),(12,44,1593.11153),(12,2,1593.11116),(2,19,192.92468);
/*!40000 ALTER TABLE `distance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `metadata`
--

DROP TABLE IF EXISTS `metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `metadata` (
  `data_type` text,
  `filename` text,
  `path` text,
  `update_date` date DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metadata`
--

LOCK TABLES `metadata` WRITE;
/*!40000 ALTER TABLE `metadata` DISABLE KEYS */;
INSERT INTO `metadata` VALUES ('dataroot','/mss_ds/project/denovo2_pipe/DATA/','/mss_ds/project/denovo2_pipe/DATA/',NULL),('tree','Eukaryota_species.nw','metadata/tree/',NULL),('tree','Archaea_species.nw','metadata/tree/',NULL),('tree','Bacteria_species.nw','metadata/tree/',NULL),('webroot',NULL,'/genome_browser/database/DATA',NULL),('dataroot_docker','/DATA/','/DATA/',NULL),('name','names.dmp','metadata/dmp','2022-04-24'),('node','nodes.dmp','metadata/dmp','2022-04-24'),('cpu','biweb','10','2023-12-21');
/*!40000 ALTER TABLE `metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sample_information`
--

DROP TABLE IF EXISTS `sample_information`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sample_information` (
  `sample_id` int NOT NULL AUTO_INCREMENT,
  `sample_name` text,
  `species` int DEFAULT NULL,
  `tissue` text,
  `cell_type` text,
  `Transcriptome` int DEFAULT NULL,
  `Epigenome_Meth` int DEFAULT NULL,
  `Epigenome_ChIP` int DEFAULT NULL,
  `Epigenome_HiC` int DEFAULT NULL,
  `reference` text,
  `general_information` text,
  PRIMARY KEY (`sample_id`),
  KEY `species` (`species`),
  CONSTRAINT `sample_information_ibfk_1` FOREIGN KEY (`species`) REFERENCES `taxon_id` (`taxon_id`)
) ENGINE=InnoDB AUTO_INCREMENT=207 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sample_information`
--

LOCK TABLES `sample_information` WRITE;
/*!40000 ALTER TABLE `sample_information` DISABLE KEYS */;
INSERT INTO `sample_information` VALUES (1,'SRR20072341',7227,'Head',NULL,1,NULL,NULL,NULL,NULL,'SAMN29624163'),(2,'SRR9987838',7165,'Whole_organism',NULL,1,NULL,NULL,NULL,NULL,'SAMN12587782'),(3,'SRR17709541',3702,'Leaf',NULL,1,NULL,NULL,NULL,NULL,'SAMN25184184'),(4,'SRR526996',9913,'Omental_fat_tissue',NULL,1,NULL,NULL,NULL,NULL,'SAMN01093727'),(5,'SRR17319961',6238,'Whole_worm',NULL,1,NULL,NULL,NULL,NULL,'SAMN24366033'),(6,'SRR17335940',9483,'Frontal_cortex',NULL,1,NULL,NULL,NULL,NULL,'SAMN24440905'),(7,'SRR19614472',9612,'Lung',NULL,1,NULL,NULL,NULL,NULL,'SAMN28959286'),(8,'SRR21177740',7955,NULL,NULL,1,NULL,NULL,NULL,NULL,'SAMN30418578'),(9,'ERR5198846',7237,'Ovary',NULL,1,NULL,NULL,NULL,NULL,'SAMEA7879256'),(10,'SRR16153092',7240,'Whole_adults',NULL,1,NULL,NULL,NULL,NULL,'SAMN21974715'),(11,'SRR9678426',7245,'Brain',NULL,1,NULL,NULL,NULL,NULL,'SAMN12261851'),(12,'SRR21046748',9796,'Liver',NULL,1,NULL,NULL,NULL,NULL,'SAMN30308107'),(13,'SRR21160529',562,NULL,'Cell_culture',1,NULL,NULL,NULL,NULL,'SAMN30438077'),(14,'SRR19454929',9685,'Lung',NULL,1,NULL,NULL,NULL,NULL,'SAMN28779728'),(15,'SRR20821354',9031,'Liver',NULL,1,NULL,NULL,NULL,NULL,'SAMN30143342'),(16,'SRR19629937',69293,'Whole_organism',NULL,1,NULL,NULL,NULL,NULL,'SAMN28934269'),(17,'SRR089762',3847,'Seed',NULL,1,NULL,NULL,NULL,NULL,'SAMN00189460'),(18,'SRR18961106',9541,'Pancreas',NULL,1,NULL,NULL,NULL,NULL,'SAMN27770874'),(19,'SRR10746623',9103,'Testis',NULL,1,NULL,NULL,NULL,NULL,'SAMN13655934'),(20,'SRR18171586',9544,'Brain',NULL,1,NULL,NULL,NULL,NULL,'SAMN26314348'),(21,'SRR13142105',13616,'Testis',NULL,1,NULL,NULL,NULL,NULL,'SAMN16912864'),(22,'ERR3418017',13616,'Brain',NULL,1,NULL,NULL,NULL,NULL,'SAMEA5760501'),(23,'SRR21229726',10090,'Brain',NULL,1,NULL,NULL,NULL,NULL,'SAMN30490124'),(24,'SRR10075409',61853,'Immune_system','EBV-transformed_lymphocyte_cell_line',1,NULL,NULL,NULL,NULL,'SAMN12702569'),(25,'SRR5412241',9258,'Testis',NULL,1,NULL,NULL,NULL,NULL,'SAMN06679881'),(26,'SRR21019288',4530,'Leaf',NULL,1,NULL,NULL,NULL,NULL,'SAMN30181337'),(27,'SRR21177733',9940,'Testis',NULL,1,NULL,NULL,NULL,NULL,'SAMN30469772'),(28,'SRR19917845',9940,'Adipose',NULL,1,NULL,NULL,NULL,NULL,'SAMN29470693'),(29,'SRR8750444',9597,'Brain',NULL,1,NULL,NULL,NULL,NULL,'SAMN11165815'),(30,'SRR17171631',9598,'Muscle','Skeletal_muscle_cells',1,NULL,NULL,NULL,NULL,'SAMN23794932'),(31,'SRR12416113',9555,'Whole_blood',NULL,1,NULL,NULL,NULL,NULL,'SAMN15767738'),(32,'SRR8468522',64176,'Skin',NULL,1,NULL,NULL,NULL,NULL,'SAMN10786387'),(33,'SRR12414065',9601,NULL,'Urinary_cells',1,NULL,NULL,NULL,NULL,'SAMN15760353'),(34,'SRR11462690',3694,'Leaf',NULL,1,NULL,NULL,NULL,NULL,'SAMN13655808'),(35,'SRR21229178',10116,'Mesenteric_artery',NULL,1,NULL,NULL,NULL,NULL,'SAMN30472299'),(36,'SRR8261764',88036,'Leaf',NULL,1,NULL,NULL,NULL,NULL,'SAMN10498739'),(37,'SRR8065008',59729,'Spleen',NULL,1,NULL,NULL,NULL,NULL,'SAMN10247598'),(38,'SRR12415882',31033,'Gill',NULL,1,NULL,NULL,NULL,NULL,'SAMN15764877'),(39,'SRR13080677',8364,'Intestine',NULL,1,NULL,NULL,NULL,NULL,'SAMN16826747'),(40,'SRR18338781',7227,NULL,'Ras3',NULL,NULL,NULL,1,NULL,'SAMN26725403'),(41,'ERR9356802',7165,'Whole_organism',NULL,NULL,NULL,NULL,1,NULL,'SAMEA12928163'),(42,'ERR9811602',59689,'Whole_organism',NULL,NULL,NULL,NULL,1,NULL,'SAMEA14502729'),(43,'SRR7224594',3702,'Seeding',NULL,NULL,NULL,NULL,1,NULL,'SAMN09271102'),(44,'SRR13786526',9913,'Fibroblasts',NULL,NULL,NULL,NULL,1,NULL,'SAMN18060226'),(45,'SRR6384332',6238,'Whole_worm',NULL,NULL,NULL,NULL,1,NULL,'SAMN08195776'),(46,'DRR221560',9483,'Skeletal_muscle',NULL,NULL,NULL,NULL,1,NULL,'SAMD00215307'),(47,'SRR12511409',9612,'Black_fat',NULL,NULL,NULL,NULL,1,NULL,'SAMN15870126'),(48,'SRR15037326',7955,'Muscle',NULL,NULL,NULL,NULL,1,NULL,'SAMN19519142'),(49,'SRR11813284',7237,'Whole_body',NULL,NULL,NULL,NULL,1,NULL,'SAMN13616452'),(50,'SRR6374290',9796,'Whole_body',NULL,NULL,NULL,NULL,1,NULL,'SAMN02953672'),(51,'SRR12331759',7245,'Whole_body',NULL,NULL,NULL,NULL,1,NULL,'SAMN04448284'),(52,'SRR13374520',9685,'Fibroblasts',NULL,NULL,NULL,NULL,1,NULL,'SAMN17062193'),(53,'SRR15571570',9031,'Breast_muscle',NULL,NULL,NULL,NULL,1,NULL,'SAMN20934843'),(54,'SRR12494514',3847,'Leaf',NULL,NULL,NULL,NULL,1,NULL,'SAMN15835440'),(55,'SRR16465801',9606,NULL,'Melanoma_cell_line',NULL,NULL,NULL,1,NULL,'SAMN22370321'),(56,'DRR208970',9541,'Skeletal_muscle',NULL,NULL,NULL,NULL,1,NULL,'SAMD00204206'),(57,'SRR13786551',9544,'Lung',NULL,NULL,NULL,NULL,1,NULL,'SAMN18060220'),(58,'SRR13252782',9544,'Brain',NULL,NULL,NULL,NULL,1,NULL,'SAMN17078340'),(59,'SRR8616961',13616,'Blood',NULL,NULL,NULL,NULL,1,NULL,'SAMN10973733'),(60,'SRR15663814',10090,'Thymus',NULL,NULL,NULL,NULL,1,NULL,'SAMN21032549'),(61,'SRR7232221',61853,NULL,'EBV-transformed_cell_lineLymphoblasts',NULL,NULL,NULL,1,NULL,'SAMN09279526'),(62,'SRR6702446',9258,'Liver',NULL,NULL,NULL,NULL,1,NULL,'SAMN08511560'),(63,'SRR10123324',4530,'Young_leaf',NULL,NULL,NULL,NULL,1,NULL,'SAMN12753612'),(64,'SRR13786532',9940,'Ear',NULL,NULL,NULL,NULL,1,NULL,'SAMN18060225'),(65,'SRR8782022',9597,'Lymphocyte',NULL,NULL,NULL,NULL,1,NULL,'SAMN11249423'),(66,'SRR8782019',9598,'Lymphocyte',NULL,NULL,NULL,NULL,1,NULL,'SAMN11249406'),(67,'SRR17631657',10116,'Prefrontal_cortex',NULL,NULL,NULL,NULL,1,NULL,'SAMN25025976'),(68,'DRR374915',59729,'Muscle',NULL,NULL,NULL,NULL,1,NULL,'SAMD00448226'),(69,'ERR4179377',31033,NULL,'HMW_DNA',NULL,NULL,NULL,1,NULL,'SAMEA104384834'),(70,'SRR11085806',8364,'Liver',NULL,NULL,NULL,NULL,1,NULL,'SAMN14102303'),(71,'SRR13386567',8355,'sperm',NULL,NULL,NULL,NULL,1,NULL,'SAMN17257727'),(72,'SRR10447882',7227,'Thorax',NULL,NULL,1,NULL,NULL,NULL,'SAMN13290459'),(73,'SRR17709545',59689,'Leaf',NULL,NULL,1,NULL,NULL,NULL,'SAMN25184215'),(74,'DRR400327',3702,'Seeding',NULL,NULL,1,NULL,NULL,NULL,'SAMD00521553'),(75,'SRR18091043',30522,'Fibroblast',NULL,NULL,1,NULL,NULL,NULL,'SAMN26137940'),(76,'SRR18399732',9913,'Muscle',NULL,NULL,1,NULL,NULL,NULL,'SAMN26851845'),(77,'SRR14664591',9612,'Fibroblast',NULL,NULL,1,NULL,NULL,NULL,'SAMN19365372'),(78,'SRR12797060',7955,'Intestine',NULL,NULL,1,NULL,NULL,NULL,'SAMN16398776'),(79,'SRR17311560',562,NULL,'Bacterialcell',NULL,1,NULL,NULL,NULL,'SAMN24300613'),(80,'SRR14664594',9031,'Fibroblasts',NULL,NULL,1,NULL,NULL,NULL,'SAMN19365369'),(81,'SRR8307460',3847,'Head',NULL,NULL,1,NULL,NULL,NULL,'SAMN10590329'),(82,'SRR12190331',3847,'Leaf',NULL,NULL,1,NULL,NULL,NULL,'Leaf'),(83,'ERR3220177',9541,'Brain',NULL,NULL,1,NULL,NULL,NULL,'SAMEA5418778'),(84,'SRR10882826',9544,'Peripheral_blood',NULL,NULL,1,NULL,NULL,NULL,'SAMN13841198'),(85,'SRR20694223',10090,'Spleen',NULL,NULL,1,NULL,NULL,NULL,'SAMN30024309'),(86,'SRR14935314',4530,'Heading',NULL,NULL,1,NULL,NULL,NULL,'SAMN19907964'),(87,'SRR19759300',9940,'Liver',NULL,NULL,1,NULL,NULL,NULL,'SAMN29212783'),(88,'SRR18578169',9940,'Tail',NULL,NULL,1,NULL,NULL,NULL,'Tail_fat'),(89,'SRR5590025',9598,'Bone',NULL,NULL,1,NULL,NULL,NULL,'SAMN07160079'),(90,'SRR9668894',3694,'Leaf',NULL,NULL,1,NULL,NULL,NULL,'SAMN12251693'),(91,'SRR15404318',10116,'Sperm',NULL,NULL,1,NULL,NULL,NULL,'SAMN20695358'),(92,'SRR15712135',8355,'Eye',NULL,NULL,1,NULL,NULL,NULL,'SAMN21215147'),(93,'SRR15427066',9606,'Sperm',NULL,NULL,1,NULL,NULL,NULL,'SAMN20741127'),(94,'SRR21970083',7227,'Embryos',NULL,NULL,NULL,1,NULL,NULL,'Cycle_11_embryos'),(95,'SRR3055674',7165,'Midgut',NULL,NULL,NULL,1,NULL,NULL,'Anopheles_gambiae_infected_midguts'),(96,'SRR1162934',59689,'Young_Leaf',NULL,NULL,NULL,1,NULL,NULL,'Young_leaf'),(97,'SRR19811669',3702,'Seeding',NULL,NULL,NULL,1,NULL,NULL,'Etiolated_seeding'),(99,'SRR16918058',6238,'Whole_worms',NULL,NULL,NULL,1,NULL,NULL,'SAMN23069014'),(100,'SRR10598531',9483,'Skeletal_Muscle',NULL,NULL,NULL,1,NULL,NULL,'Skeletal_Muscle'),(101,'SRR13296022',9612,'Blood','Peripheral_blood_mononuclear_cells',NULL,NULL,1,NULL,NULL,'SAMN17148327'),(102,'SRR18514252',7955,'Embryo','early_embryonic_cell',NULL,NULL,1,NULL,NULL,'SAMN27034130'),(103,'SRR18151038',7237,'Brain',NULL,NULL,NULL,1,NULL,NULL,'SAMN25949491'),(104,'SRR1552244',7240,'Embryos',NULL,NULL,NULL,1,NULL,NULL,'Embryos'),(105,'SRR1552250',7245,'Embryos',NULL,NULL,NULL,1,NULL,NULL,'SAMN02991145'),(106,'ERR2731591',9796,'Liver',NULL,NULL,NULL,1,NULL,NULL,'SAMEA4823506'),(107,'SRR17847039',562,'Whole_cell',NULL,NULL,NULL,1,NULL,NULL,'Whole_cell'),(108,'SRR15658154',9685,'Liver',NULL,NULL,NULL,1,NULL,NULL,'SAMN21025006'),(109,'SRR18354928',9031,'Phalange',NULL,NULL,NULL,1,NULL,NULL,'SAMN26733768'),(110,'SRR5086619',69293,'Gills',NULL,NULL,NULL,1,NULL,NULL,'SAMN06115092'),(111,'SRR16611061',3847,'Developing_seeds',NULL,NULL,NULL,1,NULL,NULL,'SAMN22588403'),(112,'SRR21488061',9606,NULL,'PRF/PLC/5',NULL,NULL,1,NULL,NULL,'SAMN30728085'),(113,'SRR12806713',9541,'Blastocyst',NULL,NULL,NULL,1,NULL,NULL,'SAMN16410187'),(114,'SRR12916433',9544,'Liver',NULL,NULL,NULL,1,NULL,NULL,'SAMN16575444'),(115,'SRR888896',13616,'Ear',NULL,NULL,NULL,1,NULL,NULL,'SAMN02192037'),(116,'SRR22177529',10090,'Liver',NULL,NULL,NULL,1,NULL,NULL,'Liver'),(117,'SRR10075687',61853,'Immune_system','EBV-transformed_lymphocyte_cell_line',NULL,NULL,1,NULL,NULL,'SAMN12702552'),(118,'SRR20326869',4530,'Shoot',NULL,NULL,NULL,1,NULL,NULL,'SAMN29845905'),(119,'SRR2075659',9940,'Perirenal_adipose',NULL,NULL,NULL,1,NULL,NULL,'SAMN03787408'),(120,'SRR4445470',9598,'Liver',NULL,NULL,NULL,1,NULL,NULL,'SAMN05934460'),(121,'SRR3498898',9555,'Brain',NULL,NULL,NULL,1,NULL,NULL,'SAMN04992157'),(122,'SRR8742376',3694,'Leaf',NULL,NULL,NULL,1,NULL,NULL,'SAMN11158891'),(123,'SRR17737106',10116,'Carotid_artery',NULL,NULL,NULL,1,NULL,NULL,'SAMN25246082'),(124,'SRR6652578',59729,'Brain',NULL,NULL,NULL,1,NULL,NULL,'SAMN08434938'),(125,'SRR029266',8364,'Whole_embryo',NULL,NULL,NULL,1,NULL,NULL,'SAMN00004606'),(126,'SRR15712053',8355,'Flog_eyes',NULL,NULL,NULL,1,NULL,NULL,'SAMN21214995'),(127,'SRR77221127',10090,'Liver',NULL,1,1,1,1,NULL,'Liver'),(128,'SRR77221128',10090,'Kidney',NULL,1,1,1,1,NULL,'Kidney'),(129,'SRR77221129',10090,'Heart',NULL,1,1,1,1,NULL,'Heart'),(130,'SRR77221130',9031,'Kidney',NULL,1,1,1,1,NULL,'Kidney'),(131,'SRR77221131',9031,'Heart',NULL,1,1,1,1,NULL,'Heart'),(132,'SRR77221132',9606,'Brain',NULL,1,1,1,1,NULL,'Brain'),(133,'SRR77221133',9598,'Brain',NULL,1,1,1,1,NULL,'Brain'),(134,'SRR77221134',9598,'Liver',NULL,1,1,1,1,NULL,'Liver'),(135,'SRR77221135',9685,'Liver',NULL,1,1,1,1,NULL,'Liver'),(136,'SRR77221136',9913,'Liver',NULL,1,1,1,1,NULL,'Liver'),(137,'SRR77221137',9606,'Brain',NULL,NULL,NULL,1,NULL,NULL,NULL),(138,'SRR6660455',9606,'Liver',NULL,NULL,NULL,1,NULL,NULL,'SAMN08000635'),(139,'ERR2731446',9483,'Brain',NULL,NULL,NULL,1,NULL,NULL,'SAMEA4823361'),(140,'SRR4445040',9483,'Liver',NULL,NULL,NULL,1,NULL,NULL,'SAMN05934464'),(141,'SRR19787582',9913,'Liver',NULL,NULL,NULL,1,NULL,NULL,'SAMN29252817'),(142,'ERR2731545',9796,'Brain',NULL,NULL,NULL,1,NULL,NULL,'SAMEA4823460'),(143,'ERR2731544',9796,'Liver',NULL,NULL,NULL,1,NULL,NULL,'SAMEA4823459'),(144,'SRR12764838',9544,'Brain',NULL,NULL,NULL,1,NULL,NULL,'SAMN16351573'),(145,'SRR4445030',9544,'Liver',NULL,NULL,NULL,1,NULL,NULL,'SAMN05934462'),(146,'SRR4445020',9598,'Liver',NULL,NULL,NULL,1,NULL,NULL,'SAMN05934459'),(147,'SRR12764830',9598,'Brain',NULL,NULL,NULL,1,NULL,NULL,'SAMN16351493'),(148,'SRR19787573',9940,'Liver',NULL,NULL,NULL,1,NULL,NULL,'SAMN29252808'),(149,'SRR6900785',9606,'Heart',NULL,1,NULL,NULL,NULL,NULL,'SAMN08797932'),(150,'SRR6900782',9606,'Kidney',NULL,1,NULL,NULL,NULL,NULL,'SAMN08797899'),(151,'SRR21474014',9606,'Liver',NULL,1,NULL,NULL,NULL,NULL,'SAMN30714999'),(152,'SRR6900784',9606,'Lung',NULL,1,NULL,NULL,NULL,NULL,'SAMN08797934'),(153,'SRR6900765',9598,'Heart',NULL,1,NULL,NULL,NULL,NULL,'SAMN08797930'),(154,'SRR6900766',9598,'Kidney',NULL,1,NULL,NULL,NULL,NULL,'SAMN08797929'),(155,'SRR6900767',9598,'Liver',NULL,1,NULL,NULL,NULL,NULL,'SAMN08797928'),(156,'SRR6900768',9598,'Lung',NULL,1,NULL,NULL,NULL,NULL,'SAMN08797926'),(157,'SRR12764821',9598,'Brain',NULL,1,NULL,NULL,NULL,NULL,'SAMN16351637'),(158,'ERR3492178',9598,'Brain',NULL,1,NULL,NULL,NULL,NULL,'SAMEA5884969'),(159,'ERR3491497',9597,'Brain',NULL,1,NULL,NULL,NULL,NULL,'SAMEA5884287'),(160,'SRR306836',9597,'Liver',NULL,1,NULL,NULL,NULL,NULL,'SAMN00632230'),(161,'SRR11232021',9483,'Lung',NULL,1,NULL,NULL,NULL,NULL,'SAMN14270728'),(162,'SRR9825007',9483,'Brain',NULL,1,NULL,NULL,NULL,NULL,'SAMN12342317'),(163,'SRR11734136',9483,'Liver',NULL,1,NULL,NULL,NULL,NULL,'SAMN14854567'),(164,'SRR6900801',9544,'Heart',NULL,1,NULL,NULL,NULL,NULL,'SAMN08797955'),(165,'SRR6900798',9544,'Kidney',NULL,1,NULL,NULL,NULL,NULL,'SAMN08797960'),(166,'SRR6900799',9544,'Liver',NULL,1,NULL,NULL,NULL,NULL,'SAMN08797958'),(167,'SRR6900900',9544,'Lung',NULL,1,NULL,NULL,NULL,NULL,'SAMN08798067'),(168,'SRR14093221',9544,'Brain',NULL,1,NULL,NULL,NULL,NULL,'SAMN29094268'),(169,'SRR18095901',9913,'Brain',NULL,1,NULL,NULL,NULL,NULL,'SAMN26152233'),(170,'SRR14093221',9913,'Liver',NULL,1,NULL,NULL,NULL,NULL,'SAMN29094268'),(171,'ERR3418011',9940,'Brain',NULL,1,NULL,NULL,NULL,NULL,'SAMEA5760495'),(172,'SRR19662886',9940,'Liver',NULL,1,NULL,NULL,NULL,NULL,'SAMN29094265'),(173,'SRR12442779',9796,'Brain',NULL,1,NULL,NULL,NULL,NULL,'SAMN15762619'),(174,'SRR19662886',9796,'Liver',NULL,1,NULL,NULL,NULL,NULL,'SAMN29094265'),(175,'SRR7802504',9606,'Liver',NULL,NULL,NULL,NULL,1,NULL,'SAMN09930808'),(176,'SRR14999686',10090,'Liver',NULL,NULL,NULL,NULL,1,NULL,'SAMN19967939'),(177,'SRR19426890',9940,'Liver',NULL,NULL,NULL,NULL,1,NULL,'SAMN17088352'),(178,'SRR7289953',9606,'Heart',NULL,NULL,1,NULL,NULL,NULL,'SAMN09393957'),(179,'SRR7289946',9606,'Kidney',NULL,NULL,1,NULL,NULL,NULL,'SAMN09393964'),(180,'SRR7289949',9606,'Liver',NULL,NULL,1,NULL,NULL,NULL,'SAMN09393961'),(181,'SRR7289950',9606,'Lung',NULL,NULL,1,NULL,NULL,NULL,'SAMN09393960'),(182,'SRR11922814',9598,'Brain',NULL,NULL,1,NULL,NULL,NULL,'SAMN10602406'),(183,'SRR7289904',9598,'Heart',NULL,NULL,1,NULL,NULL,NULL,'SAMN09393990'),(184,'SRR7289908',9598,'Kidney',NULL,NULL,1,NULL,NULL,NULL,'SAMN09393986'),(185,'SRR7289910',9598,'Liver',NULL,NULL,1,NULL,NULL,NULL,'SAMN09393984'),(186,'SRR7289912',9598,'Lung',NULL,NULL,1,NULL,NULL,NULL,'SAMN09393982'),(187,'SRR17850708',9483,'Liver',NULL,NULL,1,NULL,NULL,NULL,'SAMN25560278'),(188,'SRR17852279',9483,'Heart',NULL,NULL,1,NULL,NULL,NULL,'SAMN25560400'),(189,'SRR7289989',9544,'Heart',NULL,NULL,1,NULL,NULL,NULL,'SAMN09394013'),(190,'SRR11922836',9544,'Brain',NULL,NULL,1,NULL,NULL,NULL,'SAMN10602441'),(191,'SRR7289990',9544,'Heart',NULL,NULL,1,NULL,NULL,NULL,'SAMN09394012'),(192,'SRR7289982',9544,'Kidney',NULL,NULL,1,NULL,NULL,NULL,'SAMN09394020'),(193,'SRR7289985',9544,'Liver',NULL,NULL,1,NULL,NULL,NULL,'SAMN09394017'),(194,'SRR7289987',9544,'Lung',NULL,NULL,1,NULL,NULL,NULL,'SAMN09394015'),(195,'SRR15209958',9913,'Brain',NULL,NULL,1,NULL,NULL,NULL,'SAMN20343497'),(196,'SRR19759301',9913,'Liver',NULL,NULL,1,NULL,NULL,NULL,'SAMN29212784'),(197,'SRR19759298',9940,'Liver',NULL,NULL,1,NULL,NULL,NULL,'SAMN29212781'),(198,'ERR3329201',9796,'Liver',NULL,NULL,1,NULL,NULL,NULL,'SAMEA104728881'),(199,'SRR77221150',9606,'Liver',NULL,1,1,1,1,NULL,NULL),(200,'SRR77221151',9606,'Liver',NULL,1,1,1,1,NULL,NULL),(201,'SRR77221152',9606,'Liver',NULL,1,1,1,1,NULL,NULL),(202,'SRR77221153',10090,'Brain',NULL,1,1,1,1,NULL,NULL),(203,'4DNFIMCGWTFO',9606,'Lymphocyte','K562',NULL,NULL,NULL,1,NULL,'4DNFIMCGWTFO'),(204,'4DNFIOWFH6R9',9606,'Lymphocyte','B_cell',NULL,NULL,NULL,1,NULL,'4DNFIOWFH6R9'),(205,'SRR20653140',9606,'Liver',NULL,NULL,NULL,1,NULL,NULL,NULL),(206,'SRR20653177',9103,NULL,NULL,NULL,NULL,1,NULL,'37',NULL);
/*!40000 ALTER TABLE `sample_information` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sample_set`
--

DROP TABLE IF EXISTS `sample_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sample_set` (
  `sample_set_id` int NOT NULL,
  `sample_id` int DEFAULT NULL,
  `species` int DEFAULT NULL,
  KEY `species` (`species`),
  KEY `sample_id` (`sample_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sample_set`
--

LOCK TABLES `sample_set` WRITE;
/*!40000 ALTER TABLE `sample_set` DISABLE KEYS */;
INSERT INTO `sample_set` VALUES (1,1,7227),(2,2,7165),(3,3,3702),(4,4,9913),(5,5,6238),(6,6,9483),(7,7,9612),(8,8,7955),(9,9,7237),(10,10,7240),(11,11,7245),(12,12,9796),(13,13,562),(14,14,9685),(15,15,9031),(16,16,69293),(17,17,3847),(18,18,9541),(19,19,9103),(20,20,9544),(21,21,13616),(22,22,13616),(23,23,10090),(24,24,61853),(25,25,9258),(26,26,4530),(27,27,9940),(28,28,9940),(29,29,9597),(30,30,9598),(31,31,9555),(32,32,64176),(33,33,9601),(34,34,3694),(35,35,10116),(36,36,88036),(37,37,59729),(38,38,31033),(39,39,8364),(40,40,7227),(41,41,7165),(42,42,59689),(43,43,3702),(44,44,9913),(45,45,6238),(46,46,9483),(47,47,9612),(48,48,7955),(49,49,7237),(50,50,9796),(51,51,7245),(52,52,9685),(53,53,9031),(54,54,3847),(55,55,9606),(56,56,9541),(57,57,9544),(58,58,9544),(59,59,13616),(60,60,10090),(61,61,61853),(62,62,9258),(63,63,4530),(64,64,9940),(65,65,9597),(66,66,9598),(67,67,10116),(68,68,59729),(69,69,31033),(70,70,8364),(71,71,8355),(72,72,7227),(73,73,59689),(74,74,3702),(75,75,30522),(76,76,9913),(77,77,9612),(78,78,7955),(79,79,562),(80,80,9031),(81,81,3847),(82,82,3847),(83,83,9541),(84,84,9544),(85,85,10090),(86,86,4530),(87,87,9940),(88,88,9940),(89,89,9598),(90,90,3694),(91,91,10116),(92,92,8355),(93,93,9606),(94,94,7227),(95,95,7165),(96,96,59689),(97,97,3702),(98,98,9913),(99,99,6238),(100,100,9483),(101,101,9612),(102,102,7955),(103,103,7237),(104,104,7240),(105,105,7245),(106,106,9796),(107,107,562),(108,108,9685),(109,109,9031),(110,110,69293),(111,111,3847),(112,112,9606),(113,113,9541),(114,114,9544),(115,115,13616),(116,116,10090),(117,117,61853),(118,118,4530),(119,119,9940),(120,120,9598),(121,121,9555),(122,122,3694),(123,123,10116),(124,124,59729),(125,125,8364),(126,126,8355),(127,127,10090),(128,128,10090),(129,129,9606),(130,130,9031),(131,131,9606),(132,132,9598),(133,133,9598),(134,134,9598),(135,135,9685),(136,136,9913),(137,137,9606),(138,138,9606),(139,139,9483),(140,140,9483),(141,141,9913),(142,142,9796),(143,143,9796),(144,144,9544),(145,145,9544),(146,146,9598),(147,147,9598),(148,148,9940),(149,149,9606),(150,150,9606),(151,151,9606),(152,152,9606),(153,153,9598),(154,154,9598),(155,155,9598),(156,156,9598),(157,157,9598),(158,158,9598),(159,159,9597),(160,160,9597),(161,161,9483),(162,162,9483),(163,163,9483),(164,164,9544),(165,165,9544),(166,166,9544),(167,167,9544),(168,168,9544),(169,169,9913),(170,170,9913),(171,171,9940),(172,172,9940),(173,173,9796),(174,174,9796),(175,175,9606),(176,176,10090),(177,177,9940),(178,178,9606),(179,179,9606),(180,180,9606),(181,181,9606),(182,182,9598),(183,183,9598),(184,184,9598),(185,185,9598),(186,186,9598),(187,187,9483),(188,188,9483),(189,189,9544),(190,190,9544),(191,191,9544),(192,192,9544),(193,193,9544),(194,194,9544),(195,195,9913),(196,196,9913),(197,197,9940),(198,198,9796),(199,138,9606),(199,205,9606),(201,112,9606),(201,138,9606),(204,98,9913),(204,98,9913),(240,120,9598),(240,146,9598),(240,147,9598),(205,205,9606),(266,139,9483),(266,140,9483),(277,93,9606),(277,178,9606),(278,60,10090),(278,176,10090),(279,89,9598),(279,182,9598),(280,55,9606),(280,175,9606),(281,30,9598),(281,153,9598),(282,203,9606),(287,120,9598),(287,146,9598),(288,175,9606),(288,203,9606);
/*!40000 ALTER TABLE `sample_set` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sample_set_header`
--

DROP TABLE IF EXISTS `sample_set_header`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sample_set_header` (
  `sample_set_id` int NOT NULL AUTO_INCREMENT,
  `single_species` int DEFAULT NULL,
  PRIMARY KEY (`sample_set_id`)
) ENGINE=MyISAM AUTO_INCREMENT=289 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sample_set_header`
--

LOCK TABLES `sample_set_header` WRITE;
/*!40000 ALTER TABLE `sample_set_header` DISABLE KEYS */;
INSERT INTO `sample_set_header` VALUES (1,1),(2,1),(3,1),(4,1),(5,1),(6,1),(7,1),(8,1),(9,1),(10,1),(11,1),(12,1),(13,1),(14,1),(15,1),(16,1),(17,1),(18,1),(19,1),(20,1),(21,1),(22,1),(23,1),(24,1),(25,1),(26,1),(27,1),(28,1),(29,1),(30,1),(31,1),(32,1),(33,1),(34,1),(35,1),(36,1),(37,1),(38,1),(39,1),(40,1),(41,1),(42,1),(43,1),(44,1),(45,1),(46,1),(47,1),(48,1),(49,1),(50,1),(51,1),(52,1),(53,1),(54,1),(55,1),(56,1),(57,1),(58,1),(59,1),(60,1),(61,1),(62,1),(63,1),(64,1),(65,1),(66,1),(67,1),(68,1),(69,1),(70,1),(71,1),(72,1),(73,1),(74,1),(75,1),(76,1),(77,1),(78,1),(79,1),(80,1),(81,1),(82,1),(83,1),(84,1),(85,1),(86,1),(87,1),(88,1),(89,1),(90,1),(91,1),(92,1),(93,1),(94,1),(95,1),(96,1),(97,1),(98,1),(99,1),(100,1),(101,1),(102,1),(103,1),(104,1),(105,1),(106,1),(107,1),(108,1),(109,1),(110,1),(111,1),(112,1),(113,1),(114,1),(115,1),(116,1),(117,1),(118,1),(119,1),(120,1),(121,1),(122,1),(123,1),(124,1),(125,1),(126,1),(127,1),(128,1),(129,1),(130,1),(131,1),(132,1),(133,1),(134,1),(135,1),(136,1),(137,1),(138,1),(139,1),(140,1),(141,1),(142,1),(143,1),(144,1),(145,1),(146,1),(147,1),(148,1),(149,1),(150,1),(151,1),(152,1),(153,1),(154,1),(155,1),(156,1),(157,1),(158,1),(159,1),(160,1),(161,1),(162,1),(163,1),(164,1),(165,1),(166,1),(167,1),(168,1),(169,1),(170,1),(171,1),(172,1),(173,1),(174,1),(175,1),(176,1),(177,1),(178,1),(179,1),(180,1),(181,1),(182,1),(183,1),(184,1),(185,1),(186,1),(187,1),(188,1),(189,1),(190,1),(191,1),(192,1),(193,1),(194,1),(195,1),(196,1),(197,1),(198,1),(199,1),(200,1),(201,1),(202,1),(203,1),(204,1),(205,1),(283,1),(207,1),(208,1),(209,1),(210,1),(211,1),(212,1),(213,1),(214,1),(215,1),(216,1),(217,1),(218,1),(219,1),(220,1),(221,1),(222,1),(223,1),(224,1),(225,1),(226,1),(227,1),(228,1),(229,1),(230,1),(231,1),(232,1),(233,1),(234,1),(235,1),(236,1),(237,1),(238,1),(239,1),(240,1),(241,1),(242,1),(243,1),(244,1),(245,1),(246,1),(247,1),(248,1),(249,1),(250,1),(251,1),(252,1),(253,1),(254,1),(255,1),(256,1),(257,1),(258,1),(259,1),(260,1),(261,1),(262,1),(263,1),(264,1),(265,1),(266,1),(267,1),(268,1),(269,1),(270,1),(271,1),(272,1),(273,1),(274,1),(275,1),(276,1),(277,1),(278,1),(279,1),(280,1),(281,1),(282,1),(284,1),(285,1),(286,1),(287,1),(288,1);
/*!40000 ALTER TABLE `sample_set_header` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `session_info`
--

DROP TABLE IF EXISTS `session_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `session_info` (
  `session_id` text,
  `job_number` int NOT NULL,
  `status` int DEFAULT NULL,
  `analysis` char(20) DEFAULT NULL,
  `data_id` int DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `session_info`
--

LOCK TABLES `session_info` WRITE;
/*!40000 ALTER TABLE `session_info` DISABLE KEYS */;
INSERT INTO `session_info` VALUES ('bw',10000,1,'RNA',NULL),('mgvrj9udqp5t5n7vvaqh63897j',6,0,'RNA',NULL),('mgvrj9udqp5t5n7vvaqh63897j',6,NULL,NULL,NULL),('mgvrj9udqp5t5n7vvaqh63897j',4,0,'GENOME_SYN_BEGIN',120),('mgvrj9udqp5t5n7vvaqh63897j',5,1,'GENOME_SYN_DONE',119),('mgvrj9udqp5t5n7vvaqh63897j',5,1,'GENOME_SYN_DONE',119),('dbhtf4j149h0g8dcio61nfjlj9',44,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',43,NULL,NULL,NULL),('mgvrj9udqp5t5n7vvaqh63897j',4,NULL,'GENOME_SYN_BEGIN',120),('mgvrj9udqp5t5n7vvaqh63897j',3,1,'CHIP',NULL),('mgvrj9udqp5t5n7vvaqh63897j',3,1,NULL,NULL),('mgvrj9udqp5t5n7vvaqh63897j',2,1,'CHIP',NULL),('mgvrj9udqp5t5n7vvaqh63897j',2,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',7,1,'METH',NULL),('vicngg5si637aas6510o5s24d5',51,1,'RNA',NULL),('vicngg5si637aas6510o5s24d5',51,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',50,1,'RNA',NULL),('vicngg5si637aas6510o5s24d5',50,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',49,1,'RNA',NULL),('vicngg5si637aas6510o5s24d5',49,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',48,0,'METH',NULL),('vicngg5si637aas6510o5s24d5',48,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',47,1,'HIC',NULL),('vicngg5si637aas6510o5s24d5',47,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',46,0,'CHIP',NULL),('vicngg5si637aas6510o5s24d5',46,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',8,1,'CHIP',NULL),('n3nug0f56pb29s3v18boufdf6c',35,0,'DIFF_RNA',1),('n3nug0f56pb29s3v18boufdf6c',34,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',77,0,'DIFF_CHIP',8),('5alk3vuimd2f7e1scl5rugdffp',76,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',75,1,'HIC',NULL),('5alk3vuimd2f7e1scl5rugdffp',75,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',74,0,'CHIP',63),('5alk3vuimd2f7e1scl5rugdffp',74,0,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',74,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',73,0,'CHIP',63),('5alk3vuimd2f7e1scl5rugdffp',73,0,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',73,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',72,0,'CHIP',68),('5alk3vuimd2f7e1scl5rugdffp',72,0,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',72,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',71,0,'CHIP',68),('5alk3vuimd2f7e1scl5rugdffp',71,0,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',71,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',10,0,'GENOME_ALN',0),('lobpenhddir2lvc3v7c4f9d7ap',10,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',9,1,'CHIP',NULL),('lobpenhddir2lvc3v7c4f9d7ap',9,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',8,1,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',33,1,'RNA',NULL),('n3nug0f56pb29s3v18boufdf6c',33,1,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',32,1,'RNA',NULL),('n3nug0f56pb29s3v18boufdf6c',32,1,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',31,1,'RNA',NULL),('n3nug0f56pb29s3v18boufdf6c',31,1,NULL,NULL),('jac4g459nek55ae0265bvloaja',7,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',45,0,'DIFF_CHIP',3),('vicngg5si637aas6510o5s24d5',44,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',7,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',6,1,'HIC',NULL),('lobpenhddir2lvc3v7c4f9d7ap',6,1,NULL,NULL),('jac4g459nek55ae0265bvloaja',8,1,'RNA',NULL),('jac4g459nek55ae0265bvloaja',8,1,NULL,NULL),('jac4g459nek55ae0265bvloaja',7,1,'RNA',NULL),('dbhtf4j149h0g8dcio61nfjlj9',42,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',6,1,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',41,0,'DIFF_CHIP',2),('dbhtf4j149h0g8dcio61nfjlj9',40,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',39,0,'DIFF_CHIP',2),('dbhtf4j149h0g8dcio61nfjlj9',38,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',37,0,'DIFF_CHIP',2),('dbhtf4j149h0g8dcio61nfjlj9',36,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',35,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',34,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',33,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',32,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',31,0,'DIFF_comp',1),('dbhtf4j149h0g8dcio61nfjlj9',30,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',6,1,'RNA',NULL),('jac4g459nek55ae0265bvloaja',5,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',5,0,'CHIP',68),('jac4g459nek55ae0265bvloaja',5,0,'CHIP',NULL),('vc3gnd2j2uq4dvi7kv366vefq1',1,1,'CHIP',NULL),('vc3gnd2j2uq4dvi7kv366vefq1',1,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',70,0,'CHIP',68),('5alk3vuimd2f7e1scl5rugdffp',70,0,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',70,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',69,0,'GENOME_ALN',0),('v9s8g6a990cj2rirg9tuakg63b',22,0,'DIFF_comp',1),('v9s8g6a990cj2rirg9tuakg63b',21,NULL,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',20,1,'HIC',84),('v9s8g6a990cj2rirg9tuakg63b',20,1,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',19,1,'RNA',87),('v9s8g6a990cj2rirg9tuakg63b',19,1,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',18,1,'METH',74),('v9s8g6a990cj2rirg9tuakg63b',18,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',69,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',68,0,'GENOME_ALN',0),('5alk3vuimd2f7e1scl5rugdffp',68,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',5,0,'RNA',NULL),('lobpenhddir2lvc3v7c4f9d7ap',5,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',4,0,'CHIP',NULL),('lobpenhddir2lvc3v7c4f9d7ap',4,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',67,0,'GENOME_ALN',0),('vicngg5si637aas6510o5s24d5',43,0,'DIFF_comp',1),('vicngg5si637aas6510o5s24d5',42,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',41,0,'DIFF_comp',1),('vicngg5si637aas6510o5s24d5',40,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',39,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',38,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',37,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',36,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',35,1,'CHIP',74),('vicngg5si637aas6510o5s24d5',35,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',34,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',33,1,'RNA',90),('vicngg5si637aas6510o5s24d5',33,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',32,1,'HIC',83),('vicngg5si637aas6510o5s24d5',32,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',31,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',30,1,'RNA',89),('vicngg5si637aas6510o5s24d5',30,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',29,1,'METH',72),('vicngg5si637aas6510o5s24d5',29,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',28,1,'HIC',82),('vicngg5si637aas6510o5s24d5',28,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',27,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',26,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',25,1,'HIC',81),('vicngg5si637aas6510o5s24d5',25,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',24,1,'METH',71),('vicngg5si637aas6510o5s24d5',24,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',23,0,'DIFF_comp',1),('vicngg5si637aas6510o5s24d5',22,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',21,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',20,1,'HIC',80),('vicngg5si637aas6510o5s24d5',20,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',19,0,'DIFF_comp',1),('vicngg5si637aas6510o5s24d5',18,NULL,NULL,NULL),('89k7r85rgo418jgb956sqinqk3',7,0,'DIFF_comp',1),('89k7r85rgo418jgb956sqinqk3',6,NULL,NULL,NULL),('89k7r85rgo418jgb956sqinqk3',5,NULL,NULL,NULL),('89k7r85rgo418jgb956sqinqk3',4,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',17,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',16,NULL,NULL,NULL),('89k7r85rgo418jgb956sqinqk3',3,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',15,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',14,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',13,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',12,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',11,1,'METH',70),('vicngg5si637aas6510o5s24d5',11,1,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',30,0,'DIFF_CHIP',14),('n3nug0f56pb29s3v18boufdf6c',29,NULL,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',17,1,'HIC',79),('v9s8g6a990cj2rirg9tuakg63b',17,1,NULL,NULL),('se0o20te902ka4ji3vhnsc0lmr',6,0,'GENOME_ALN',0),('se0o20te902ka4ji3vhnsc0lmr',6,NULL,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',28,NULL,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',27,NULL,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',26,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',10,1,'HIC',78),('vicngg5si637aas6510o5s24d5',10,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',9,NULL,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',16,1,'HIC',77),('v9s8g6a990cj2rirg9tuakg63b',16,1,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',25,1,'RNA',88),('n3nug0f56pb29s3v18boufdf6c',25,1,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',15,1,'HIC',76),('v9s8g6a990cj2rirg9tuakg63b',15,1,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',14,1,'CHIP',73),('v9s8g6a990cj2rirg9tuakg63b',14,1,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',13,1,'RNA',87),('v9s8g6a990cj2rirg9tuakg63b',13,1,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',12,1,'METH',69),('v9s8g6a990cj2rirg9tuakg63b',12,1,NULL,NULL),('vicngg5si637aas6510o5s24d5',8,0,'GENOME_ALN',0),('vicngg5si637aas6510o5s24d5',8,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',7,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',6,NULL,NULL,NULL),('89k7r85rgo418jgb956sqinqk3',2,0,'DIFF_CHIP',14),('89k7r85rgo418jgb956sqinqk3',1,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',5,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',4,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',3,0,'DIFF_CHIP',14),('vicngg5si637aas6510o5s24d5',2,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',1,1,'CHIP',72),('vicngg5si637aas6510o5s24d5',1,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',67,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',2,0,'CHIP',NULL),('jac4g459nek55ae0265bvloaja',2,0,'CHIP',81),('jac4g459nek55ae0265bvloaja',3,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',3,0,'HIC',NULL),('jac4g459nek55ae0265bvloaja',4,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',4,0,'METH',NULL),('n3nug0f56pb29s3v18boufdf6c',42,NULL,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',42,0,'CHIP',NULL),('n3nug0f56pb29s3v18boufdf6c',42,0,'CHIP',78),('5alk3vuimd2f7e1scl5rugdffp',66,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',66,0,'GENOME_ALN',0),('jac4g459nek55ae0265bvloaja',2,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',1,1,'RNA',NULL),('jac4g459nek55ae0265bvloaja',1,1,NULL,NULL),('b6el9atim864mm4cdq8kctafo8',4,0,'GENOME_SYN_BEGIN',119),('b6el9atim864mm4cdq8kctafo8',4,NULL,'GENOME_SYN_BEGIN',119),('b6el9atim864mm4cdq8kctafo8',3,1,'GENOME_SYN_DONE',118),('b6el9atim864mm4cdq8kctafo8',3,1,'GENOME_SYN_DONE',118),('5alk3vuimd2f7e1scl5rugdffp',65,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',64,1,'GENOME_SYN_DONE',117),('5alk3vuimd2f7e1scl5rugdffp',64,1,'GENOME_SYN_DONE',117),('b6el9atim864mm4cdq8kctafo8',2,0,'GENOME_SYN_BEGIN',116),('b6el9atim864mm4cdq8kctafo8',2,NULL,'GENOME_SYN_BEGIN',116),('b6el9atim864mm4cdq8kctafo8',1,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',63,NULL,NULL,NULL),('c4mkrv34q6l394sghpir66bqpn',11,1,'GENOME_SYN_DONE',115),('c4mkrv34q6l394sghpir66bqpn',10,1,'GENOME_SYN_DONE',116),('c4mkrv34q6l394sghpir66bqpn',11,1,'GENOME_SYN_DONE',115),('c4mkrv34q6l394sghpir66bqpn',9,NULL,NULL,NULL),('c4mkrv34q6l394sghpir66bqpn',9,0,'GENOME_ALN',0),('c4mkrv34q6l394sghpir66bqpn',10,1,'GENOME_SYN_DONE',116),('c4mkrv34q6l394sghpir66bqpn',8,1,'GENOME_SYN_DONE',116),('c4mkrv34q6l394sghpir66bqpn',8,1,'GENOME_SYN_DONE',116),('c4mkrv34q6l394sghpir66bqpn',7,NULL,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',10,0,'GENOME_ALN',0),('p6elrndt1l6n9eph3kuvabop7k',10,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',29,0,'DIFF_CHIP',14),('dbhtf4j149h0g8dcio61nfjlj9',28,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',27,0,'DIFF_CHIP',14),('dbhtf4j149h0g8dcio61nfjlj9',26,NULL,NULL,NULL),('c4mkrv34q6l394sghpir66bqpn',6,0,'CHIP',78),('c4mkrv34q6l394sghpir66bqpn',6,0,'CHIP',NULL),('7gq8ierhs0fp2hqds8r68bl9bq',3,1,'HIC',73),('7gq8ierhs0fp2hqds8r68bl9bq',3,1,NULL,NULL),('7gq8ierhs0fp2hqds8r68bl9bq',2,1,'METH',66),('7gq8ierhs0fp2hqds8r68bl9bq',2,1,NULL,NULL),('ci86ndtt7713le17f2reqmj3c5',9,1,'CHIP',83),('ci86ndtt7713le17f2reqmj3c5',9,1,NULL,NULL),('ci86ndtt7713le17f2reqmj3c5',8,0,'CHIP',82),('ci86ndtt7713le17f2reqmj3c5',8,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',25,0,'DIFF_CHIP',14),('dbhtf4j149h0g8dcio61nfjlj9',24,NULL,NULL,NULL),('7gq8ierhs0fp2hqds8r68bl9bq',1,1,'HIC',72),('7gq8ierhs0fp2hqds8r68bl9bq',1,1,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',24,0,'GENOME_ALN',0),('n3nug0f56pb29s3v18boufdf6c',24,NULL,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',23,1,'GENOME_SYN_DONE',115),('n3nug0f56pb29s3v18boufdf6c',23,1,'GENOME_SYN_DONE',115),('dbhtf4j149h0g8dcio61nfjlj9',23,0,'DIFF_CHIP',14),('dbhtf4j149h0g8dcio61nfjlj9',22,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',21,0,'DIFF_Epigenome',1),('dbhtf4j149h0g8dcio61nfjlj9',20,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',19,0,'DIFF_Epigenome',1),('dbhtf4j149h0g8dcio61nfjlj9',18,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',17,0,'DIFF_Epigenome',1),('dbhtf4j149h0g8dcio61nfjlj9',16,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',15,0,'DIFF_Epigenome',1),('dbhtf4j149h0g8dcio61nfjlj9',14,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',13,0,'DIFF_Epigenome',1),('dbhtf4j149h0g8dcio61nfjlj9',12,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',11,0,'DIFF_Epigenome',1),('dbhtf4j149h0g8dcio61nfjlj9',10,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',9,0,'DIFF_Epigenome',1),('dbhtf4j149h0g8dcio61nfjlj9',8,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',7,0,'DIFF_Epigenome',1),('dbhtf4j149h0g8dcio61nfjlj9',6,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',5,0,'DIFF_Epigenome',1),('dbhtf4j149h0g8dcio61nfjlj9',4,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',3,0,'DIFF_Epigenome',1),('dbhtf4j149h0g8dcio61nfjlj9',2,NULL,NULL,NULL),('c4mkrv34q6l394sghpir66bqpn',5,1,NULL,NULL),('c4mkrv34q6l394sghpir66bqpn',5,1,'RNA',NULL),('c4mkrv34q6l394sghpir66bqpn',6,NULL,NULL,NULL),('c4mkrv34q6l394sghpir66bqpn',2,NULL,NULL,NULL),('c4mkrv34q6l394sghpir66bqpn',3,0,'DIFF_CHIP',8),('c4mkrv34q6l394sghpir66bqpn',4,NULL,NULL,NULL),('0ags58tqdi4lco1je4hcnnroh7',5,NULL,NULL,NULL),('0ags58tqdi4lco1je4hcnnroh7',4,1,'HIC',69),('0ags58tqdi4lco1je4hcnnroh7',4,1,NULL,NULL),('test',1,NULL,NULL,NULL),('0ags58tqdi4lco1je4hcnnroh7',3,0,'DIFF_Epigenome',1),('0ags58tqdi4lco1je4hcnnroh7',2,NULL,NULL,NULL),('0ags58tqdi4lco1je4hcnnroh7',1,NULL,NULL,NULL),('c4mkrv34q6l394sghpir66bqpn',1,NULL,NULL,NULL),('lltepu6tcelno27hvff7t8bof1',16,1,NULL,NULL),('lltepu6tcelno27hvff7t8bof1',16,1,'HIC',NULL),('dbhtf4j149h0g8dcio61nfjlj9',1,1,'RNA',94),('dbhtf4j149h0g8dcio61nfjlj9',1,1,NULL,NULL),('lltepu6tcelno27hvff7t8bof1',15,0,'CHIP',81),('lltepu6tcelno27hvff7t8bof1',15,NULL,NULL,NULL),('lltepu6tcelno27hvff7t8bof1',15,0,'CHIP',NULL),('lltepu6tcelno27hvff7t8bof1',14,1,'CHIP',NULL),('lltepu6tcelno27hvff7t8bof1',14,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',2,1,'HIC',NULL),('lobpenhddir2lvc3v7c4f9d7ap',3,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',3,1,'HIC',NULL),('p6elrndt1l6n9eph3kuvabop7k',9,1,'GENOME_SYN_DONE',114),('lobpenhddir2lvc3v7c4f9d7ap',2,1,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',9,1,'GENOME_SYN_DONE',114),('lobpenhddir2lvc3v7c4f9d7ap',1,0,'CHIP',NULL),('lobpenhddir2lvc3v7c4f9d7ap',1,0,'CHIP',78),('lltepu6tcelno27hvff7t8bof1',13,1,'HIC',NULL),('lobpenhddir2lvc3v7c4f9d7ap',1,NULL,NULL,NULL),('lltepu6tcelno27hvff7t8bof1',12,1,NULL,NULL),('lltepu6tcelno27hvff7t8bof1',12,1,'RNA',NULL),('lltepu6tcelno27hvff7t8bof1',13,1,NULL,NULL),('aae7rs9flpa27hmcg1ppkc1ufe',1,1,NULL,NULL),('aae7rs9flpa27hmcg1ppkc1ufe',1,1,'RNA',NULL),('n3nug0f56pb29s3v18boufdf6c',41,1,'CHIP',NULL),('vl9i49vd19dohqlq2olnagc88e',2,1,'RNA',NULL),('n3nug0f56pb29s3v18boufdf6c',41,1,NULL,NULL),('vl9i49vd19dohqlq2olnagc88e',2,1,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',12,NULL,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',12,0,'CHIP',NULL),('p6elrndt1l6n9eph3kuvabop7k',12,0,'CHIP',77),('vl9i49vd19dohqlq2olnagc88e',1,NULL,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',11,1,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',11,1,'CHIP',NULL),('lltepu6tcelno27hvff7t8bof1',11,1,'CHIP',NULL),('lltepu6tcelno27hvff7t8bof1',11,1,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',11,1,'HIC',68),('v9s8g6a990cj2rirg9tuakg63b',11,1,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',22,1,'GENOME_SYN_DONE',131),('n3nug0f56pb29s3v18boufdf6c',22,1,'GENOME_SYN_DONE',131),('n3nug0f56pb29s3v18boufdf6c',21,1,'GENOME_SYN_DONE',130),('n3nug0f56pb29s3v18boufdf6c',21,1,'GENOME_SYN_DONE',130),('n3nug0f56pb29s3v18boufdf6c',20,NULL,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',19,NULL,NULL,NULL),('0ca584bp9vjrga6me283s9ftq8',17,1,'GENOME_SYN_DONE',126),('0ca584bp9vjrga6me283s9ftq8',17,1,'GENOME_SYN_DONE',126),('0ca584bp9vjrga6me283s9ftq8',16,0,'GENOME_SYN_DONE',125),('0ca584bp9vjrga6me283s9ftq8',16,NULL,'GENOME_SYN_DONE',125),('0ca584bp9vjrga6me283s9ftq8',15,1,'GENOME_SYN_BEGIN',57),('0ca584bp9vjrga6me283s9ftq8',15,1,'GENOME_SYN_BEGIN',57),('0ca584bp9vjrga6me283s9ftq8',14,1,'GENOME_SYN_DONE',124),('0ca584bp9vjrga6me283s9ftq8',14,1,'GENOME_SYN_DONE',124),('0ca584bp9vjrga6me283s9ftq8',13,1,'GENOME_SYN_BEGIN',57),('0ca584bp9vjrga6me283s9ftq8',13,1,'GENOME_SYN_BEGIN',57),('0ca584bp9vjrga6me283s9ftq8',12,1,'GENOME_SYN_BEGIN',57),('0ca584bp9vjrga6me283s9ftq8',12,1,'GENOME_SYN_BEGIN',57),('0ca584bp9vjrga6me283s9ftq8',11,1,'GENOME_SYN_DONE',122),('0ca584bp9vjrga6me283s9ftq8',11,1,'GENOME_SYN_DONE',122),('0ca584bp9vjrga6me283s9ftq8',10,0,'GENOME_SYN_DONE',121),('0ca584bp9vjrga6me283s9ftq8',10,NULL,'GENOME_SYN_DONE',121),('0ca584bp9vjrga6me283s9ftq8',9,1,'GENOME_SYN_BEGIN',56),('0ca584bp9vjrga6me283s9ftq8',9,1,'GENOME_SYN_BEGIN',56),('0ca584bp9vjrga6me283s9ftq8',8,1,'GENOME_SYN_DONE',123),('0ca584bp9vjrga6me283s9ftq8',8,1,'GENOME_SYN_DONE',123),('0ca584bp9vjrga6me283s9ftq8',7,1,'GENOME_SYN_DONE',129),('0ca584bp9vjrga6me283s9ftq8',7,1,'GENOME_SYN_DONE',129),('0ca584bp9vjrga6me283s9ftq8',6,1,'GENOME_SYN_DONE',120),('0ca584bp9vjrga6me283s9ftq8',6,1,'GENOME_SYN_DONE',120),('0ca584bp9vjrga6me283s9ftq8',5,1,'CHIP',81),('0ca584bp9vjrga6me283s9ftq8',5,1,NULL,NULL),('0ca584bp9vjrga6me283s9ftq8',4,1,'HIC',67),('0ca584bp9vjrga6me283s9ftq8',4,1,NULL,NULL),('0ca584bp9vjrga6me283s9ftq8',3,1,'RNA',93),('0ca584bp9vjrga6me283s9ftq8',3,1,NULL,NULL),('79m9br7e3fh7fnlu9ngq6mu586',1,0,'GENOME_SYN_DONE',128),('79m9br7e3fh7fnlu9ngq6mu586',1,NULL,'GENOME_SYN_DONE',128),('0ca584bp9vjrga6me283s9ftq8',2,0,'GENOME_SYN_DONE',127),('0ca584bp9vjrga6me283s9ftq8',2,NULL,'GENOME_SYN_DONE',127),('4mk9lj0tf9onbbdoaad2613flp',1,1,'HIC',66),('4mk9lj0tf9onbbdoaad2613flp',1,1,NULL,NULL),('0ca584bp9vjrga6me283s9ftq8',1,0,'GENOME_SYN_DONE',119),('0ca584bp9vjrga6me283s9ftq8',1,NULL,'GENOME_SYN_DONE',119),('vomh9bfqh9q4258ktbpgn1oosr',9,0,'DIFF_CHIP',14),('vomh9bfqh9q4258ktbpgn1oosr',8,NULL,NULL,NULL),('vomh9bfqh9q4258ktbpgn1oosr',7,0,'DIFF_CHIP',14),('vomh9bfqh9q4258ktbpgn1oosr',6,NULL,NULL,NULL),('vomh9bfqh9q4258ktbpgn1oosr',5,0,'DIFF_CHIP',14),('vomh9bfqh9q4258ktbpgn1oosr',4,NULL,NULL,NULL),('vomh9bfqh9q4258ktbpgn1oosr',3,0,'DIFF_CHIP',14),('vomh9bfqh9q4258ktbpgn1oosr',2,NULL,NULL,NULL),('vomh9bfqh9q4258ktbpgn1oosr',1,NULL,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',18,0,'DIFF_RNA',1),('n3nug0f56pb29s3v18boufdf6c',17,NULL,NULL,NULL),('ci86ndtt7713le17f2reqmj3c5',7,0,'GENOME_ALN',0),('ci86ndtt7713le17f2reqmj3c5',7,NULL,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',10,0,'METH',65),('v9s8g6a990cj2rirg9tuakg63b',10,NULL,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',9,1,'CHIP',80),('v9s8g6a990cj2rirg9tuakg63b',9,1,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',8,1,'HIC',65),('v9s8g6a990cj2rirg9tuakg63b',8,1,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',7,1,'METH',64),('v9s8g6a990cj2rirg9tuakg63b',7,1,NULL,NULL),('b7a8f4ednv4qh6m20403c4l4on',9,0,'DIFF_CHIP',14),('b7a8f4ednv4qh6m20403c4l4on',8,NULL,NULL,NULL),('b7a8f4ednv4qh6m20403c4l4on',7,0,'DIFF_CHIP',13),('b7a8f4ednv4qh6m20403c4l4on',6,NULL,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',7,1,'GENOME_SYN_DONE',115),('p6elrndt1l6n9eph3kuvabop7k',7,1,'GENOME_SYN_DONE',115),('b7a8f4ednv4qh6m20403c4l4on',5,1,'RNA',91),('b7a8f4ednv4qh6m20403c4l4on',5,1,NULL,NULL),('b7a8f4ednv4qh6m20403c4l4on',4,1,'HIC',58),('b7a8f4ednv4qh6m20403c4l4on',4,1,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',6,0,'GENOME_SYN_DONE',115),('p6elrndt1l6n9eph3kuvabop7k',6,NULL,'GENOME_SYN_DONE',115),('b7a8f4ednv4qh6m20403c4l4on',3,1,'CHIP',73),('b7a8f4ednv4qh6m20403c4l4on',3,1,NULL,NULL),('b7a8f4ednv4qh6m20403c4l4on',2,1,'METH',61),('b7a8f4ednv4qh6m20403c4l4on',2,1,NULL,NULL),('b7a8f4ednv4qh6m20403c4l4on',1,0,'GENOME_SYN_DONE',114),('b7a8f4ednv4qh6m20403c4l4on',1,NULL,'GENOME_SYN_DONE',114),('n3nug0f56pb29s3v18boufdf6c',15,NULL,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',14,NULL,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',5,NULL,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',4,NULL,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',13,NULL,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',12,1,'RNA',90),('n3nug0f56pb29s3v18boufdf6c',11,1,'RNA',89),('n3nug0f56pb29s3v18boufdf6c',10,1,'RNA',88),('n3nug0f56pb29s3v18boufdf6c',9,1,'RNA',87),('se0o20te902ka4ji3vhnsc0lmr',2,NULL,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',8,NULL,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',7,1,'CHIP',72),('n3nug0f56pb29s3v18boufdf6c',6,1,'CHIP',71),('b7a8f4ednv4qh6m20403c4l4on',11,0,'DIFF_METH',1),('b7a8f4ednv4qh6m20403c4l4on',12,NULL,NULL,NULL),('b7a8f4ednv4qh6m20403c4l4on',13,0,'DIFF_RNA',1),('b7a8f4ednv4qh6m20403c4l4on',14,NULL,NULL,NULL),('b7a8f4ednv4qh6m20403c4l4on',15,0,'DIFF_CHIP',14),('b7a8f4ednv4qh6m20403c4l4on',16,NULL,NULL,NULL),('b7a8f4ednv4qh6m20403c4l4on',17,0,'DIFF_HIC',2),('mgvrj9udqp5t5n7vvaqh63897j',1,1,NULL,NULL),('mgvrj9udqp5t5n7vvaqh63897j',1,1,'CHIP',74),('test_fin',1,1,'GENOME_SYN_BEGIN',113),('p6elrndt1l6n9eph3kuvabop7k',8,1,'GENOME_SYN_DONE',116),('p6elrndt1l6n9eph3kuvabop7k',8,1,'GENOME_SYN_DONE',116),('v9s8g6a990cj2rirg9tuakg63b',1,1,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',1,1,'HIC',59),('ci86ndtt7713le17f2reqmj3c5',1,1,NULL,NULL),('ci86ndtt7713le17f2reqmj3c5',1,1,'HIC',60),('n3nug0f56pb29s3v18boufdf6c',5,NULL,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',1,NULL,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',2,NULL,NULL,NULL),('se0o20te902ka4ji3vhnsc0lmr',1,NULL,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',3,NULL,NULL,NULL),('se0o20te902ka4ji3vhnsc0lmr',5,1,'HIC',64),('se0o20te902ka4ji3vhnsc0lmr',5,1,NULL,NULL),('se0o20te902ka4ji3vhnsc0lmr',4,0,'CHIP',79),('se0o20te902ka4ji3vhnsc0lmr',4,NULL,NULL,NULL),('ci86ndtt7713le17f2reqmj3c5',6,1,'GENOME_SYN_DONE',117),('ci86ndtt7713le17f2reqmj3c5',6,1,'GENOME_SYN_DONE',117),('v9s8g6a990cj2rirg9tuakg63b',6,1,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',6,1,'HIC',63),('v9s8g6a990cj2rirg9tuakg63b',5,1,'METH',63),('v9s8g6a990cj2rirg9tuakg63b',5,1,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',16,0,'GENOME_SYN_DONE',118),('n3nug0f56pb29s3v18boufdf6c',16,NULL,'GENOME_SYN_DONE',118),('n3nug0f56pb29s3v18boufdf6c',4,NULL,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',3,1,'RNA',86),('n3nug0f56pb29s3v18boufdf6c',2,NULL,'METH',60),('n3nug0f56pb29s3v18boufdf6c',1,NULL,NULL,NULL),('ci86ndtt7713le17f2reqmj3c5',5,1,'CHIP',78),('ci86ndtt7713le17f2reqmj3c5',5,1,NULL,NULL),('ci86ndtt7713le17f2reqmj3c5',4,1,'CHIP',77),('ci86ndtt7713le17f2reqmj3c5',4,1,NULL,NULL),('se0o20te902ka4ji3vhnsc0lmr',3,0,'METH',62),('se0o20te902ka4ji3vhnsc0lmr',3,NULL,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',4,1,'CHIP',76),('v9s8g6a990cj2rirg9tuakg63b',4,1,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',3,1,'CHIP',75),('v9s8g6a990cj2rirg9tuakg63b',3,1,NULL,NULL),('v9s8g6a990cj2rirg9tuakg63b',2,1,'RNA',92),('v9s8g6a990cj2rirg9tuakg63b',2,1,NULL,NULL),('ci86ndtt7713le17f2reqmj3c5',3,1,'HIC',62),('ci86ndtt7713le17f2reqmj3c5',3,1,NULL,NULL),('ci86ndtt7713le17f2reqmj3c5',2,1,'HIC',61),('ci86ndtt7713le17f2reqmj3c5',2,1,NULL,NULL),('b7a8f4ednv4qh6m20403c4l4on',10,NULL,NULL,NULL),('bw',10000,1,'RNA',NULL),('bw',10000,1,'RNA',NULL),('bw',10000,1,'RNA',NULL),('bw',10000,1,'RNA',NULL),('bw',10000,1,'RNA',NULL),('bw',10000,1,'RNA',NULL),('bw',10000,1,'RNA',NULL),('bw',10000,0,'RNA',NULL),('bw',10000,0,'RNA',NULL),('bw',10000,0,'RNA',NULL),('lltepu6tcelno27hvff7t8bof1',10,1,'RNA',NULL),('lltepu6tcelno27hvff7t8bof1',10,1,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',40,1,'RNA',NULL),('n3nug0f56pb29s3v18boufdf6c',40,1,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',39,1,'METH',NULL),('n3nug0f56pb29s3v18boufdf6c',39,1,NULL,NULL),('lltepu6tcelno27hvff7t8bof1',9,1,NULL,NULL),('lltepu6tcelno27hvff7t8bof1',9,1,'HIC',NULL),('n3nug0f56pb29s3v18boufdf6c',38,1,'HIC',NULL),('n3nug0f56pb29s3v18boufdf6c',38,1,NULL,NULL),('89k7r85rgo418jgb956sqinqk3',13,0,'DIFF_CHIP',8),('89k7r85rgo418jgb956sqinqk3',12,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',52,NULL,'GENOME_SYN_DONE',115),('vicngg5si637aas6510o5s24d5',52,0,'GENOME_SYN_DONE',115),('vicngg5si637aas6510o5s24d5',53,NULL,NULL,NULL),('vicngg5si637aas6510o5s24d5',53,0,'GENOME_ALN',0),('dbhtf4j149h0g8dcio61nfjlj9',45,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',46,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',47,NULL,NULL,NULL),('dbhtf4j149h0g8dcio61nfjlj9',48,0,'DIFF_CHIP',6),('5alk3vuimd2f7e1scl5rugdffp',62,0,'DIFF_CHIP',7),('5alk3vuimd2f7e1scl5rugdffp',61,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',60,0,'DIFF_CHIP',7),('5alk3vuimd2f7e1scl5rugdffp',59,NULL,NULL,NULL),('89k7r85rgo418jgb956sqinqk3',11,0,'DIFF_CHIP',10),('89k7r85rgo418jgb956sqinqk3',8,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',58,0,'DIFF_CHIP',9),('5alk3vuimd2f7e1scl5rugdffp',57,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',56,0,'DIFF_CHIP',8),('89k7r85rgo418jgb956sqinqk3',10,NULL,NULL,NULL),('89k7r85rgo418jgb956sqinqk3',9,0,'DIFF_CHIP',10),('lltepu6tcelno27hvff7t8bof1',1,NULL,NULL,NULL),('lltepu6tcelno27hvff7t8bof1',2,NULL,NULL,NULL),('lltepu6tcelno27hvff7t8bof1',3,NULL,NULL,NULL),('lltepu6tcelno27hvff7t8bof1',4,NULL,NULL,NULL),('lltepu6tcelno27hvff7t8bof1',5,NULL,NULL,NULL),('lltepu6tcelno27hvff7t8bof1',6,NULL,NULL,NULL),('lltepu6tcelno27hvff7t8bof1',7,0,'DIFF_CHIP',7),('n3nug0f56pb29s3v18boufdf6c',36,NULL,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',36,0,'RNA',NULL),('n3nug0f56pb29s3v18boufdf6c',37,1,NULL,NULL),('n3nug0f56pb29s3v18boufdf6c',37,1,'RNA',NULL),('lltepu6tcelno27hvff7t8bof1',8,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',55,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',54,0,'DIFF_CHIP',7),('5alk3vuimd2f7e1scl5rugdffp',53,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',52,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',51,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',50,0,'init',0),('mgvrj9udqp5t5n7vvaqh63897j',7,1,NULL,NULL),('mgvrj9udqp5t5n7vvaqh63897j',7,1,'RNA',NULL),('5alk3vuimd2f7e1scl5rugdffp',78,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',78,1,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',79,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',79,1,'METH',NULL),('jac4g459nek55ae0265bvloaja',9,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',9,0,'RNA',NULL),('lobpenhddir2lvc3v7c4f9d7ap',11,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',11,1,'CHIP',NULL),('lobpenhddir2lvc3v7c4f9d7ap',12,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',12,0,'HIC',NULL),('lobpenhddir2lvc3v7c4f9d7ap',13,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',13,0,'HIC',NULL),('lobpenhddir2lvc3v7c4f9d7ap',14,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',14,0,'HIC',NULL),('lobpenhddir2lvc3v7c4f9d7ap',15,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',15,1,'METH',NULL),('lobpenhddir2lvc3v7c4f9d7ap',16,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',16,1,'METH',NULL),('lobpenhddir2lvc3v7c4f9d7ap',17,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',17,1,'RNA',NULL),('lobpenhddir2lvc3v7c4f9d7ap',18,1,'GENOME_SYN_DONE',121),('lobpenhddir2lvc3v7c4f9d7ap',18,1,'GENOME_SYN_DONE',121),('lobpenhddir2lvc3v7c4f9d7ap',19,1,'GENOME_SYN_DONE',122),('lobpenhddir2lvc3v7c4f9d7ap',19,1,'GENOME_SYN_DONE',122),('jac4g459nek55ae0265bvloaja',10,1,NULL,NULL),('jac4g459nek55ae0265bvloaja',10,1,'RNA',NULL),('lobpenhddir2lvc3v7c4f9d7ap',20,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',20,1,'CHIP',NULL),('lobpenhddir2lvc3v7c4f9d7ap',21,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',21,1,'HIC',NULL),('lobpenhddir2lvc3v7c4f9d7ap',22,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',23,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',24,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',25,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',25,0,'HIC',NULL),('lobpenhddir2lvc3v7c4f9d7ap',26,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',26,1,'METH',NULL),('lobpenhddir2lvc3v7c4f9d7ap',27,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',27,1,'METH',NULL),('lobpenhddir2lvc3v7c4f9d7ap',28,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',28,1,'METH',NULL),('lobpenhddir2lvc3v7c4f9d7ap',29,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',29,1,'METH',NULL),('lobpenhddir2lvc3v7c4f9d7ap',30,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',30,1,'RNA',NULL),('lobpenhddir2lvc3v7c4f9d7ap',31,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',31,1,'RNA',NULL),('lobpenhddir2lvc3v7c4f9d7ap',32,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',32,1,'RNA',NULL),('lobpenhddir2lvc3v7c4f9d7ap',33,1,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',33,1,'RNA',NULL),('lobpenhddir2lvc3v7c4f9d7ap',34,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',35,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',11,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',11,0,'HIC',NULL),('9kurirttu61g0evbuapt63qd3a',1,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',1,0,'RNA',NULL),('jac4g459nek55ae0265bvloaja',12,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',13,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',14,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',15,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',16,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',2,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',3,1,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',3,1,'RNA',NULL),('lobpenhddir2lvc3v7c4f9d7ap',36,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',4,1,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',4,1,'RNA',NULL),('lobpenhddir2lvc3v7c4f9d7ap',37,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',38,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',39,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',40,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',41,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',42,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',43,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',44,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',5,1,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',5,1,'RNA',NULL),('lobpenhddir2lvc3v7c4f9d7ap',45,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',46,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',47,NULL,NULL,NULL),('lobpenhddir2lvc3v7c4f9d7ap',48,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',17,1,'GENOME_SYN_DONE',123),('jac4g459nek55ae0265bvloaja',17,1,'GENOME_SYN_DONE',123),('jac4g459nek55ae0265bvloaja',18,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',19,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',20,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',21,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',22,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',23,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',24,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',25,NULL,NULL,NULL),('jac4g459nek55ae0265bvloaja',26,NULL,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',13,1,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',13,1,'METH',NULL),('p6elrndt1l6n9eph3kuvabop7k',14,1,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',14,1,'RNA',NULL),('p6elrndt1l6n9eph3kuvabop7k',15,1,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',15,1,'RNA',NULL),('p6elrndt1l6n9eph3kuvabop7k',16,1,NULL,NULL),('p6elrndt1l6n9eph3kuvabop7k',16,1,'CHIP',NULL),('p6elrndt1l6n9eph3kuvabop7k',14,1,'METH',NULL),('p6elrndt1l6n9eph3kuvabop7k',200,1,'METH',NULL),('p6elrndt1l6n9eph3kuvabop7k',200,1,'METH',71),('p6elrndt1l6n9eph3kuvabop7k',200,1,'METH',71),('p6elrndt1l6n9eph3kuvabop7k',200,1,'METH',72),('p6elrndt1l6n9eph3kuvabop7k',200,1,'METH',73),('p6elrndt1l6n9eph3kuvabop7k',200,1,'METH',73),('p6elrndt1l6n9eph3kuvabop7k',200,0,'METH',74),('5alk3vuimd2f7e1scl5rugdffp',80,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',80,1,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',81,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',81,1,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',82,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',82,1,'METH',71),('9kurirttu61g0evbuapt63qd3a',6,1,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',6,1,'RNA',NULL),('5alk3vuimd2f7e1scl5rugdffp',83,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',83,0,'CHIP',NULL),('9kurirttu61g0evbuapt63qd3a',7,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',7,0,'RNA',NULL),('5alk3vuimd2f7e1scl5rugdffp',84,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',84,0,'METH',63),('9kurirttu61g0evbuapt63qd3a',8,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',8,0,'RNA',NULL),('9kurirttu61g0evbuapt63qd3a',9,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',9,0,'RNA',NULL),('9kurirttu61g0evbuapt63qd3a',10,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',10,0,'RNA',NULL),('5alk3vuimd2f7e1scl5rugdffp',85,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',85,1,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',86,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',86,0,'HIC',NULL),('5alk3vuimd2f7e1scl5rugdffp',87,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',87,0,'METH',63),('9kurirttu61g0evbuapt63qd3a',11,1,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',11,1,'RNA',NULL),('9kurirttu61g0evbuapt63qd3a',12,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',12,0,'RNA',NULL),('9kurirttu61g0evbuapt63qd3a',13,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',13,0,'HIC',NULL),('5alk3vuimd2f7e1scl5rugdffp',88,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',88,1,'METH',63),('5alk3vuimd2f7e1scl5rugdffp',89,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',89,0,'HIC',NULL),('9kurirttu61g0evbuapt63qd3a',14,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',14,0,'GENOME_ALN',0),('5alk3vuimd2f7e1scl5rugdffp',90,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',90,1,'METH',64),('9kurirttu61g0evbuapt63qd3a',15,NULL,'GENOME_SYN_BEGIN',124),('9kurirttu61g0evbuapt63qd3a',15,0,'GENOME_SYN_BEGIN',124),('5alk3vuimd2f7e1scl5rugdffp',91,NULL,'GENOME_SYN_BEGIN',125),('5alk3vuimd2f7e1scl5rugdffp',91,0,'GENOME_SYN_BEGIN',125),('5alk3vuimd2f7e1scl5rugdffp',92,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',93,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',94,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',95,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',96,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',96,1,'HIC',NULL),('5alk3vuimd2f7e1scl5rugdffp',97,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',97,1,'HIC',NULL),('5alk3vuimd2f7e1scl5rugdffp',98,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',98,1,'HIC',NULL),('5alk3vuimd2f7e1scl5rugdffp',99,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',100,0,'DIFF_HIC',1),('5alk3vuimd2f7e1scl5rugdffp',101,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',101,1,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',102,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',102,1,'METH',65),('5alk3vuimd2f7e1scl5rugdffp',103,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',104,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',105,0,'DIFF_HIC',1),('5alk3vuimd2f7e1scl5rugdffp',106,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',107,0,'DIFF_HIC',1),('5alk3vuimd2f7e1scl5rugdffp',108,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',109,0,'DIFF_HIC',1),('5alk3vuimd2f7e1scl5rugdffp',110,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',111,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',112,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',113,0,'DIFF_HIC',1),('5alk3vuimd2f7e1scl5rugdffp',114,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',115,0,'DIFF_HIC',1),('5alk3vuimd2f7e1scl5rugdffp',116,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',117,0,'DIFF_HIC',1),('5alk3vuimd2f7e1scl5rugdffp',118,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',119,0,'DIFF_HIC',1),('9kurirttu61g0evbuapt63qd3a',16,1,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',16,1,'HIC',NULL),('9kurirttu61g0evbuapt63qd3a',17,1,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',17,1,'CHIP',NULL),('9kurirttu61g0evbuapt63qd3a',18,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',18,0,'METH',66),('9kurirttu61g0evbuapt63qd3a',19,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',20,0,'DIFF_CHIP',9),('9kurirttu61g0evbuapt63qd3a',21,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',22,0,'DIFF_CHIP',9),('9kurirttu61g0evbuapt63qd3a',23,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',24,0,'DIFF_HIC',1),('9kurirttu61g0evbuapt63qd3a',25,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',26,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',27,1,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',27,1,'RNA',NULL),('9kurirttu61g0evbuapt63qd3a',28,1,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',28,1,'CHIP',NULL),('9kurirttu61g0evbuapt63qd3a',29,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',29,0,'HIC',NULL),('5alk3vuimd2f7e1scl5rugdffp',120,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',120,1,'CHIP',NULL),('aae7rs9flpa27hmcg1ppkc1ufe',2,NULL,NULL,NULL),('aae7rs9flpa27hmcg1ppkc1ufe',2,0,'GENOME_ALN',0),('5alk3vuimd2f7e1scl5rugdffp',121,NULL,'GENOME_SYN_BEGIN',126),('5alk3vuimd2f7e1scl5rugdffp',121,0,'GENOME_SYN_BEGIN',126),('5alk3vuimd2f7e1scl5rugdffp',122,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',122,0,'GENOME_ALN',0),('5smj6ee1otthkdmrhom616dedn',1,NULL,NULL,NULL),('5smj6ee1otthkdmrhom616dedn',1,0,'RNA',NULL),('5smj6ee1otthkdmrhom616dedn',2,1,NULL,NULL),('5smj6ee1otthkdmrhom616dedn',2,1,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',123,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',124,0,'DIFF_RNA',1),('5smj6ee1otthkdmrhom616dedn',3,NULL,NULL,NULL),('5smj6ee1otthkdmrhom616dedn',3,0,'CHIP',NULL),('5smj6ee1otthkdmrhom616dedn',3,0,'CHIP',103),('5smj6ee1otthkdmrhom616dedn',4,1,NULL,NULL),('5smj6ee1otthkdmrhom616dedn',4,1,'RNA',NULL),('5smj6ee1otthkdmrhom616dedn',5,1,NULL,NULL),('5smj6ee1otthkdmrhom616dedn',5,1,'RNA',NULL),('5alk3vuimd2f7e1scl5rugdffp',125,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',126,0,'DIFF_RNA',1),('5alk3vuimd2f7e1scl5rugdffp',127,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',128,0,'DIFF_HIC',1),('5alk3vuimd2f7e1scl5rugdffp',129,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',130,0,'DIFF_CHIP',10),('cgk3vrjp8kc3utk3t316bjoul6',1,NULL,NULL,NULL),('cgk3vrjp8kc3utk3t316bjoul6',2,NULL,NULL,NULL),('cgk3vrjp8kc3utk3t316bjoul6',2,0,'CHIP',NULL),('9m0hjvfppq8i7igcilp6emibbr',1,NULL,NULL,NULL),('9m0hjvfppq8i7igcilp6emibbr',1,0,'GENOME_ALN',0),('5alk3vuimd2f7e1scl5rugdffp',131,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',131,1,'METH',67),('5alk3vuimd2f7e1scl5rugdffp',132,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',133,0,'DIFF_HIC',1),('5alk3vuimd2f7e1scl5rugdffp',134,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',135,0,'DIFF_HIC',1),('5alk3vuimd2f7e1scl5rugdffp',136,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',137,0,'DIFF_HIC',1),('5alk3vuimd2f7e1scl5rugdffp',138,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',139,0,'DIFF_HIC',1),('5alk3vuimd2f7e1scl5rugdffp',140,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',141,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',142,0,'DIFF_HIC',1),('5alk3vuimd2f7e1scl5rugdffp',143,1,'GENOME_SYN_DONE',127),('5alk3vuimd2f7e1scl5rugdffp',143,1,'GENOME_SYN_DONE',127),('5alk3vuimd2f7e1scl5rugdffp',144,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',144,1,'METH',68),('cgk3vrjp8kc3utk3t316bjoul6',3,NULL,NULL,NULL),('cgk3vrjp8kc3utk3t316bjoul6',3,0,'RNA',NULL),('5alk3vuimd2f7e1scl5rugdffp',145,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',146,0,'DIFF_HIC',1),('5alk3vuimd2f7e1scl5rugdffp',147,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',148,0,'DIFF_HIC',1),('9m0hjvfppq8i7igcilp6emibbr',2,NULL,NULL,NULL),('9m0hjvfppq8i7igcilp6emibbr',2,0,'GENOME_ALN',0),('9m0hjvfppq8i7igcilp6emibbr',3,NULL,NULL,NULL),('9m0hjvfppq8i7igcilp6emibbr',3,0,'GENOME_ALN',0),('9kurirttu61g0evbuapt63qd3a',30,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',31,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',149,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',150,0,'DIFF_CHIP',11),('9m0hjvfppq8i7igcilp6emibbr',4,1,NULL,NULL),('9m0hjvfppq8i7igcilp6emibbr',4,1,'HIC',NULL),('9m0hjvfppq8i7igcilp6emibbr',5,NULL,NULL,NULL),('9m0hjvfppq8i7igcilp6emibbr',5,0,'METH',69),('9m0hjvfppq8i7igcilp6emibbr',6,1,NULL,NULL),('9m0hjvfppq8i7igcilp6emibbr',6,1,'HIC',NULL),('5alk3vuimd2f7e1scl5rugdffp',151,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',152,0,'DIFF_METH',1),('5alk3vuimd2f7e1scl5rugdffp',153,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',154,0,'DIFF_CHIP',11),('5alk3vuimd2f7e1scl5rugdffp',155,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',156,0,'DIFF_HIC',2),('5alk3vuimd2f7e1scl5rugdffp',157,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',158,0,'DIFF_RNA',2),('cgk3vrjp8kc3utk3t316bjoul6',4,NULL,NULL,NULL),('cgk3vrjp8kc3utk3t316bjoul6',4,0,'GENOME_ALN',0),('9kurirttu61g0evbuapt63qd3a',32,NULL,NULL,NULL),('9kurirttu61g0evbuapt63qd3a',32,0,'GENOME_ALN',0),('5alk3vuimd2f7e1scl5rugdffp',159,1,'GENOME_SYN_DONE',130),('5alk3vuimd2f7e1scl5rugdffp',159,1,'GENOME_SYN_DONE',130),('5alk3vuimd2f7e1scl5rugdffp',160,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',160,0,'METH',70),('5alk3vuimd2f7e1scl5rugdffp',161,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',161,0,'METH',71),('5alk3vuimd2f7e1scl5rugdffp',162,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',163,0,'DIFF_METH',1),('5alk3vuimd2f7e1scl5rugdffp',164,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',164,0,'METH',72),('5alk3vuimd2f7e1scl5rugdffp',165,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',165,0,'METH',73),('5alk3vuimd2f7e1scl5rugdffp',166,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',167,0,'DIFF_METH',1),('5alk3vuimd2f7e1scl5rugdffp',168,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',169,0,'DIFF_METH',1),('5alk3vuimd2f7e1scl5rugdffp',170,1,'GENOME_SYN_DONE',128),('5alk3vuimd2f7e1scl5rugdffp',170,1,'GENOME_SYN_DONE',128),('5alk3vuimd2f7e1scl5rugdffp',171,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',172,0,'DIFF_METH',2),('5alk3vuimd2f7e1scl5rugdffp',173,1,'GENOME_SYN_DONE',129),('5alk3vuimd2f7e1scl5rugdffp',173,1,'GENOME_SYN_DONE',129),('5alk3vuimd2f7e1scl5rugdffp',174,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',174,1,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',175,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',175,1,'HIC',NULL),('5alk3vuimd2f7e1scl5rugdffp',176,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',176,1,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',177,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',178,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',179,0,'DIFF_CHIP',12),('5alk3vuimd2f7e1scl5rugdffp',180,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',181,0,'DIFF_HIC',3),('5alk3vuimd2f7e1scl5rugdffp',182,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',182,1,'RNA',NULL),('5alk3vuimd2f7e1scl5rugdffp',183,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',183,0,'HIC',NULL),('5alk3vuimd2f7e1scl5rugdffp',184,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',185,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',186,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',187,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',187,1,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',188,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',188,1,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',189,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',189,0,'HIC',NULL),('5alk3vuimd2f7e1scl5rugdffp',190,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',190,1,'CHIP',NULL),('5alk3vuimd2f7e1scl5rugdffp',191,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',192,0,'DIFF_CHIP',13),('5alk3vuimd2f7e1scl5rugdffp',193,1,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',193,1,'HIC',NULL),('aae7rs9flpa27hmcg1ppkc1ufe',3,NULL,NULL,NULL),('aae7rs9flpa27hmcg1ppkc1ufe',4,0,'DIFF_CHIP',14),('5alk3vuimd2f7e1scl5rugdffp',194,NULL,NULL,NULL),('5alk3vuimd2f7e1scl5rugdffp',194,0,'METH',71),('5alk3vuimd2f7e1scl5rugdffp',195,NULL,'GENOME_SYN_BEGIN',132),('5alk3vuimd2f7e1scl5rugdffp',195,0,'GENOME_SYN_BEGIN',132),('5alk3vuimd2f7e1scl5rugdffp',196,1,'GENOME_SYN_DONE',131),('5alk3vuimd2f7e1scl5rugdffp',196,1,'GENOME_SYN_DONE',131),('5alk3vuimd2f7e1scl5rugdffp',197,1,'GENOME_SYN_DONE',133),('5alk3vuimd2f7e1scl5rugdffp',197,1,'GENOME_SYN_DONE',133),('g87nq7u5koh4ksue6fodamgseu',1,1,'GENOME_SYN_DONE',134),('g87nq7u5koh4ksue6fodamgseu',1,1,'GENOME_SYN_DONE',134),('g87nq7u5koh4ksue6fodamgseu',2,NULL,NULL,NULL),('g87nq7u5koh4ksue6fodamgseu',3,NULL,NULL,NULL),('g87nq7u5koh4ksue6fodamgseu',4,0,'DIFF_CHIP',15),('ib276n1af4i86kc9rqi50boeu2',1,NULL,NULL,NULL),('ib276n1af4i86kc9rqi50boeu2',1,0,'GENOME_ALN',0),('lo564ubm06fi6dghrs5gl5ouc5',1,NULL,NULL,NULL),('lo564ubm06fi6dghrs5gl5ouc5',1,0,'METH',71);
/*!40000 ALTER TABLE `session_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `species_set`
--

DROP TABLE IF EXISTS `species_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `species_set` (
  `species_set_id` int DEFAULT NULL,
  `assembly_id` int DEFAULT NULL,
  KEY `species_set_id` (`species_set_id`),
  KEY `assembly_id` (`assembly_id`),
  CONSTRAINT `species_set_ibfk_1` FOREIGN KEY (`species_set_id`) REFERENCES `species_set_header` (`species_set_id`),
  CONSTRAINT `species_set_ibfk_2` FOREIGN KEY (`assembly_id`) REFERENCES `assembly` (`assembly_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `species_set`
--

LOCK TABLES `species_set` WRITE;
/*!40000 ALTER TABLE `species_set` DISABLE KEYS */;
INSERT INTO `species_set` VALUES (1,29),(2,33),(3,43),(4,37),(5,20),(6,31),(7,27),(8,28),(9,19),(10,23),(11,22),(12,3),(13,40),(14,15),(15,42),(16,24),(17,33),(17,43),(18,33),(18,19),(19,43),(19,19),(20,37),(20,15),(21,20),(21,33),(22,20),(22,28),(23,31),(23,39),(24,23),(24,33),(25,23),(25,19),(26,23),(26,3),(27,22),(27,33),(28,22),(28,19),(29,22),(29,23),(30,22),(30,3),(31,3),(31,33),(32,3),(32,43),(33,3),(33,19),(34,40),(34,19),(35,15),(35,3),(36,15),(36,24),(37,33),(37,19),(37,43),(38,37),(38,15),(38,24),(39,31),(39,39),(39,38),(40,23),(40,19),(40,33),(41,23),(41,19),(41,3),(42,23),(42,3),(42,33),(43,22),(43,23),(43,33),(44,22),(44,23),(44,19),(45,22),(45,23),(45,3),(46,3),(46,33),(46,43),(47,3),(47,33),(47,19),(48,3),(48,43),(48,19),(49,23),(49,3),(49,33),(49,19),(50,22),(50,23),(50,33),(50,19),(51,22),(51,23),(51,33),(51,3),(52,22),(52,23),(52,19),(52,3),(53,3),(53,33),(53,43),(53,19),(54,22),(54,23),(54,19),(54,3),(54,33),(55,30),(56,16),(57,21),(58,39),(59,38),(60,11),(61,17),(62,8),(63,41),(64,3),(64,20),(196,35),(198,7),(53,3),(65,3),(65,20),(65,22),(199,20),(200,20),(200,21),(204,5),(205,11),(205,31),(206,18),(212,2),(216,2),(216,8),(217,14),(218,36),(219,4),(220,12),(222,44),(244,8),(244,28),(246,49),(247,12),(247,39),(248,8),(248,11),(249,11),(249,12),(250,16),(250,29),(251,20),(251,21),(251,28),(251,33),(252,26),(253,12),(253,26),(254,4),(254,8),(255,4),(255,11),(256,38),(256,39),(257,31),(257,38),(259,36),(259,37),(260,38),(260,44),(261,9),(263,15),(263,36),(264,32),(265,31),(265,39),(265,44),(266,24),(266,26),(267,24),(267,44),(268,5),(268,44),(269,25);
/*!40000 ALTER TABLE `species_set` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `species_set_header`
--

DROP TABLE IF EXISTS `species_set_header`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `species_set_header` (
  `species_set_id` int NOT NULL AUTO_INCREMENT,
  `common_ancestor_taxid` int DEFAULT NULL,
  `size` int DEFAULT NULL,
  PRIMARY KEY (`species_set_id`),
  KEY `common_ancestor_taxid` (`common_ancestor_taxid`),
  CONSTRAINT `species_set_header_ibfk_1` FOREIGN KEY (`common_ancestor_taxid`) REFERENCES `taxon_id` (`taxon_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=270 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `species_set_header`
--

LOCK TABLES `species_set_header` WRITE;
/*!40000 ALTER TABLE `species_set_header` DISABLE KEYS */;
INSERT INTO `species_set_header` VALUES (1,NULL,1),(2,NULL,1),(3,NULL,1),(4,NULL,1),(5,NULL,1),(6,NULL,1),(7,NULL,1),(8,NULL,1),(9,NULL,1),(10,NULL,1),(11,NULL,1),(12,NULL,1),(13,NULL,1),(14,NULL,1),(15,NULL,1),(16,NULL,1),(17,NULL,2),(18,NULL,2),(19,NULL,2),(20,NULL,2),(21,NULL,2),(22,NULL,2),(23,NULL,2),(24,NULL,2),(25,NULL,2),(26,NULL,2),(27,NULL,2),(28,NULL,2),(29,NULL,2),(30,NULL,2),(31,NULL,2),(32,NULL,2),(33,NULL,2),(34,NULL,2),(35,NULL,2),(36,NULL,2),(37,NULL,3),(38,NULL,3),(39,NULL,3),(40,NULL,3),(41,NULL,3),(42,NULL,3),(43,NULL,3),(44,NULL,3),(45,NULL,3),(46,NULL,3),(47,NULL,3),(48,NULL,3),(49,NULL,4),(50,NULL,4),(51,NULL,4),(52,NULL,4),(53,NULL,4),(54,NULL,5),(55,NULL,1),(56,NULL,1),(57,NULL,1),(58,NULL,1),(59,NULL,1),(60,NULL,1),(61,NULL,1),(62,NULL,1),(63,NULL,1),(64,NULL,2),(65,NULL,3),(192,NULL,1),(193,NULL,1),(194,NULL,1),(195,NULL,2),(196,NULL,1),(197,NULL,1),(198,NULL,1),(199,NULL,1),(200,NULL,2),(201,NULL,0),(202,NULL,0),(203,NULL,0),(204,NULL,1),(205,NULL,2),(206,NULL,1),(207,NULL,0),(208,NULL,0),(209,NULL,0),(210,NULL,0),(211,NULL,0),(212,NULL,1),(213,NULL,0),(214,NULL,0),(215,NULL,0),(216,NULL,2),(217,NULL,1),(218,NULL,1),(219,NULL,1),(220,NULL,1),(221,NULL,0),(222,NULL,1),(223,NULL,0),(224,NULL,0),(225,NULL,0),(226,NULL,0),(227,NULL,0),(228,NULL,0),(229,NULL,0),(230,NULL,0),(231,NULL,0),(232,NULL,0),(233,NULL,0),(234,NULL,0),(235,NULL,0),(236,NULL,0),(237,NULL,0),(238,NULL,0),(239,NULL,0),(240,NULL,0),(241,NULL,0),(242,NULL,0),(244,NULL,2),(246,NULL,1),(247,NULL,2),(248,NULL,2),(249,NULL,2),(250,NULL,2),(251,NULL,4),(252,NULL,1),(253,NULL,2),(254,NULL,2),(255,NULL,2),(256,NULL,2),(257,NULL,2),(259,NULL,2),(260,NULL,2),(261,NULL,1),(263,NULL,2),(264,NULL,1),(265,NULL,3),(266,NULL,2),(267,NULL,2),(268,NULL,2),(269,NULL,1);
/*!40000 ALTER TABLE `species_set_header` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `species_tax_info`
--

DROP TABLE IF EXISTS `species_tax_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `species_tax_info` (
  `tax_id` int NOT NULL,
  `tax_species` int DEFAULT NULL,
  `tax_genus` int DEFAULT NULL,
  `tax_family` int DEFAULT NULL,
  `tax_order` int DEFAULT NULL,
  `tax_class` int DEFAULT NULL,
  `tax_phylum` int DEFAULT NULL,
  `tax_kingdom` int DEFAULT NULL,
  KEY `species_tax_info_ibfk_1` (`tax_species`),
  KEY `species_tax_info_ibfk_2` (`tax_genus`),
  KEY `species_tax_info_ibfk_3` (`tax_family`),
  KEY `species_tax_info_ibfk_4` (`tax_order`),
  KEY `species_tax_info_ibfk_5` (`tax_class`),
  KEY `species_tax_info_ibfk_6` (`tax_phylum`),
  CONSTRAINT `species_tax_info_ibfk_1` FOREIGN KEY (`tax_species`) REFERENCES `taxon_id` (`taxon_id`) ON UPDATE CASCADE,
  CONSTRAINT `species_tax_info_ibfk_2` FOREIGN KEY (`tax_genus`) REFERENCES `taxon_id` (`taxon_id`) ON UPDATE CASCADE,
  CONSTRAINT `species_tax_info_ibfk_3` FOREIGN KEY (`tax_family`) REFERENCES `taxon_id` (`taxon_id`) ON UPDATE CASCADE,
  CONSTRAINT `species_tax_info_ibfk_4` FOREIGN KEY (`tax_order`) REFERENCES `taxon_id` (`taxon_id`) ON UPDATE CASCADE,
  CONSTRAINT `species_tax_info_ibfk_5` FOREIGN KEY (`tax_class`) REFERENCES `taxon_id` (`taxon_id`) ON UPDATE CASCADE,
  CONSTRAINT `species_tax_info_ibfk_6` FOREIGN KEY (`tax_phylum`) REFERENCES `taxon_id` (`taxon_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `species_tax_info`
--

LOCK TABLES `species_tax_info` WRITE;
/*!40000 ALTER TABLE `species_tax_info` DISABLE KEYS */;
INSERT INTO `species_tax_info` VALUES (3694,3694,3689,3688,3646,3398,35493,33090),(3702,3702,3701,3700,3699,3398,35493,33090),(3847,3847,3846,3803,72025,3398,35493,33090),(39947,4530,4527,4479,38820,3398,35493,33090),(6238,6238,6237,6243,6236,119089,6231,33208),(180454,7165,7164,7157,7147,50557,6656,33208),(7227,7227,7215,7214,7147,50557,6656,33208),(7237,7237,7215,7214,7147,50557,6656,33208),(7240,7240,7215,7214,7147,50557,6656,33208),(7245,7245,7215,7214,7147,50557,6656,33208),(7955,7955,7954,2743709,7952,186623,7711,33208),(8022,8022,8016,8015,8006,186623,7711,33208),(8355,8355,8353,8352,8342,8292,7711,33208),(8364,8364,8353,8352,8342,8292,7711,33208),(9031,9031,9030,9005,8976,8782,7711,33208),(9103,9103,9102,9005,8976,8782,7711,33208),(9258,9258,9257,9256,9255,40674,7711,33208),(9483,9483,9481,9498,9443,40674,7711,33208),(9541,9541,9539,9527,9443,40674,7711,33208),(9544,9544,9539,9527,9443,40674,7711,33208),(9555,9555,9554,9527,9443,40674,7711,33208),(9595,9593,9592,9604,9443,40674,7711,33208),(9597,9597,9596,9604,9443,40674,7711,33208),(9598,9598,9596,9604,9443,40674,7711,33208),(9601,9601,9599,9604,9443,40674,7711,33208),(9606,9606,9605,9604,9443,40674,7711,33208),(9615,9612,9611,9608,33554,40674,7711,33208),(9685,9685,9682,9681,33554,40674,7711,33208),(9796,9796,9789,9788,9787,40674,7711,33208),(9913,9913,9903,9895,91561,40674,7711,33208),(9940,9940,9935,9895,91561,40674,7711,33208),(10090,10090,10088,10066,9989,40674,7711,33208),(10116,10116,10114,10066,9989,40674,7711,33208),(13616,13616,13615,9265,38605,40674,7711,33208),(30522,30522,9903,9895,91561,40674,7711,33208),(31033,31033,31032,31031,31022,186623,7711,33208),(81972,59689,3701,3700,3699,3398,35493,33090),(59729,59729,59728,37611,9126,8782,7711,33208),(61853,61853,325165,9577,9443,40674,7711,33208),(64176,64176,42163,8522,8509,8504,7711,33208),(481459,69293,69292,69291,8111,186623,7711,33208),(88036,88036,3246,3245,3244,1521260,35493,33090);
/*!40000 ALTER TABLE `species_tax_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `synteny`
--

DROP TABLE IF EXISTS `synteny`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `synteny` (
  `synteny_id` int NOT NULL DEFAULT '0',
  `reference_assembly` int DEFAULT NULL,
  `target_species_set` int DEFAULT NULL,
  `resolution` char(20) DEFAULT NULL,
  `path` text,
  `status` int DEFAULT NULL,
  `program` text,
  `alignment_program` text,
  PRIMARY KEY (`synteny_id`),
  KEY `reference_assembly` (`reference_assembly`),
  KEY `target_species_set` (`target_species_set`),
  CONSTRAINT `synteny_ibfk_1` FOREIGN KEY (`reference_assembly`) REFERENCES `assembly` (`assembly_id`),
  CONSTRAINT `synteny_ibfk_2` FOREIGN KEY (`target_species_set`) REFERENCES `species_set_header` (`species_set_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `synteny`
--

LOCK TABLES `synteny` WRITE;
/*!40000 ALTER TABLE `synteny` DISABLE KEYS */;
INSERT INTO `synteny` VALUES (1,36,12,'100k','SYNTENY/inferCars/1/',1,'makeblocks','LASTZ'),(2,36,14,'1k','SYNTENY/inferCars/2/',1,'makeblocks','LASTZ'),(7,36,38,'1k','SYNTENY/inferCars/7/',1,'makeblocks','LASTZ'),(9,9,15,'100k','SYNTENY/inferCars/9/',1,'makeblocks','LASTZ'),(10,18,13,'100k','SYNTENY/inferCars/10/',1,'makeblocks','LASTZ'),(11,18,9,'100k','SYNTENY/inferCars/11/',1,'makeblocks','LASTZ'),(12,18,34,'100k','SYNTENY/inferCars/12/',1,'makeblocks','LASTZ'),(13,18,3,'100k','SYNTENY/inferCars/13/',1,'makeblocks','LASTZ'),(14,18,19,'100k','SYNTENY/inferCars/14/',1,'makeblocks','LASTZ'),(15,18,2,'100k','SYNTENY/inferCars/15/',1,'makeblocks','LASTZ'),(16,18,18,'100k','SYNTENY/inferCars/16/',1,'makeblocks','LASTZ'),(17,18,17,'100k','SYNTENY/inferCars/17/',1,'makeblocks','LASTZ'),(18,18,37,'100k','SYNTENY/inferCars/18/',1,'makeblocks','LASTZ'),(20,18,32,'100k','SYNTENY/inferCars/20/',1,'makeblocks','LASTZ'),(21,18,33,'100k','SYNTENY/inferCars/21/',1,'makeblocks','LASTZ'),(22,18,31,'100k','SYNTENY/inferCars/22/',1,'makeblocks','LASTZ'),(23,18,46,'100k','SYNTENY/inferCars/23/',1,'makeblocks','LASTZ'),(24,18,47,'100k','SYNTENY/inferCars/24/',1,'makeblocks','LASTZ'),(25,18,48,'100k','SYNTENY/inferCars/25/',1,'makeblocks','LASTZ'),(26,18,53,'100k','SYNTENY/inferCars/26/',1,'makeblocks','LASTZ'),(28,18,25,'100k','SYNTENY/inferCars/28/',1,'makeblocks','LASTZ'),(29,18,24,'100k','SYNTENY/inferCars/29/',1,'makeblocks','LASTZ'),(30,18,26,'100k','SYNTENY/inferCars/30/',1,'makeblocks','LASTZ'),(31,18,40,'100k','SYNTENY/inferCars/31/',1,'makeblocks','LASTZ'),(33,18,42,'100k','SYNTENY/inferCars/33/',1,'makeblocks','LASTZ'),(34,18,49,'100k','SYNTENY/inferCars/34/',1,'makeblocks','LASTZ'),(36,18,29,'100k','SYNTENY/inferCars/36/',1,'makeblocks','LASTZ'),(37,18,27,'100k','SYNTENY/inferCars/37/',1,'makeblocks','LASTZ'),(38,18,28,'100k','SYNTENY/inferCars/38/',1,'makeblocks','LASTZ'),(39,18,30,'100k','SYNTENY/inferCars/39/',1,'makeblocks','LASTZ'),(40,18,43,'100k','SYNTENY/inferCars/40/',1,'makeblocks','LASTZ'),(41,18,44,'100k','SYNTENY/inferCars/41/',1,'makeblocks','LASTZ'),(42,18,45,'100k','SYNTENY/inferCars/42/',1,'makeblocks','LASTZ'),(43,18,50,'100k','SYNTENY/inferCars/43/',1,'makeblocks','LASTZ'),(44,18,51,'100k','SYNTENY/inferCars/44/',1,'makeblocks','LASTZ'),(45,18,52,'100k','SYNTENY/inferCars/45/',1,'makeblocks','LASTZ'),(46,18,54,'100k','SYNTENY/inferCars/46/',1,'makeblocks','LASTZ'),(47,2,12,'100k','SYNTENY/inferCars/47/',1,'makeblocks','LASTZ'),(48,2,5,'100k','SYNTENY/inferCars/48/',1,'makeblocks','LASTZ'),(49,2,21,'100k','SYNTENY/inferCars/49/',1,'makeblocks','LASTZ'),(50,2,2,'150k','SYNTENY/inferCars/50/',1,'makeblocks','LASTZ'),(51,2,8,'100k','SYNTENY/inferCars/51/',1,'makeblocks','LASTZ'),(52,2,22,'300k','SYNTENY/inferCars/52/',1,'makeblocks','LASTZ'),(53,2,7,'100k','SYNTENY/inferCars/53/',1,'makeblocks','LASTZ'),(54,2,1,'150k','SYNTENY/inferCars/54/',1,'makeblocks','LASTZ'),(58,36,12,'100k','SYNTENY/inferCars/58/',1,'makeblocks','LASTZ'),(59,36,14,'100k','SYNTENY/inferCars/59/',1,'makeblocks','LASTZ'),(60,36,16,'100k','SYNTENY/inferCars/60/',1,'makeblocks','LASTZ'),(61,36,4,'100k','SYNTENY/inferCars/61/',1,'makeblocks','LASTZ'),(62,36,20,'100k','SYNTENY/inferCars/62/',1,'makeblocks','LASTZ'),(63,36,36,'100k','SYNTENY/inferCars/63/',1,'makeblocks','LASTZ'),(64,36,38,'100k','SYNTENY/inferCars/64/',1,'makeblocks','LASTZ'),(65,36,35,'100k','SYNTENY/inferCars/65/',1,'makeblocks','LASTZ'),(66,9,15,'100k','SYNTENY/inferCars/66/',1,'makeblocks','LASTZ'),(67,36,12,'150k','SYNTENY/inferCars/67/',1,'makeblocks','LASTZ'),(68,36,14,'150k','SYNTENY/inferCars/68/',1,'makeblocks','LASTZ'),(69,36,16,'150k','SYNTENY/inferCars/69/',1,'makeblocks','LASTZ'),(70,36,4,'150k','SYNTENY/inferCars/70/',1,'makeblocks','LASTZ'),(71,36,20,'150k','SYNTENY/inferCars/71/',1,'makeblocks','LASTZ'),(72,36,36,'150k','SYNTENY/inferCars/72/',1,'makeblocks','LASTZ'),(73,36,38,'150k','SYNTENY/inferCars/73/',1,'makeblocks','LASTZ'),(74,36,35,'150k','SYNTENY/inferCars/74/',1,'makeblocks','LASTZ'),(75,9,15,'150k','SYNTENY/inferCars/75/',1,'makeblocks','LASTZ'),(76,36,12,'300k','SYNTENY/inferCars/76/',1,'makeblocks','LASTZ'),(77,36,14,'300k','SYNTENY/inferCars/77/',1,'makeblocks','LASTZ'),(78,36,16,'300k','SYNTENY/inferCars/78/',1,'makeblocks','LASTZ'),(79,36,4,'300k','SYNTENY/inferCars/79/',1,'makeblocks','LASTZ'),(80,36,20,'300k','SYNTENY/inferCars/80/',1,'makeblocks','LASTZ'),(81,36,36,'300k','SYNTENY/inferCars/81/',1,'makeblocks','LASTZ'),(82,36,38,'300k','SYNTENY/inferCars/82/',1,'makeblocks','LASTZ'),(83,36,35,'300k','SYNTENY/inferCars/83/',1,'makeblocks','LASTZ'),(84,9,15,'300k','SYNTENY/inferCars/84/',1,'makeblocks','LASTZ'),(89,18,10,'100k','SYNTENY/inferCars/89/',1,'makeblocks','LASTZ'),(90,18,11,'100k','SYNTENY/inferCars/90/',1,'makeblocks','LASTZ'),(91,18,12,'100k','SYNTENY/inferCars/91/',1,'makeblocks','LASTZ'),(95,18,10,'150k','SYNTENY/inferCars/95/',1,'makeblocks','LASTZ'),(96,18,11,'150k','SYNTENY/inferCars/96/',1,'makeblocks','LASTZ'),(97,18,12,'150k','SYNTENY/inferCars/97/',1,'makeblocks','LASTZ'),(101,18,10,'300k','SYNTENY/inferCars/101/',1,'makeblocks','LASTZ'),(102,18,11,'300k','SYNTENY/inferCars/102/',1,'makeblocks','LASTZ'),(103,18,12,'300k','SYNTENY/inferCars/103/',1,'makeblocks','LASTZ'),(107,2,64,'100k','SYNTENY/inferCars/107/',1,'makeblocks','LASTZ'),(108,2,65,'100k','SYNTENY/inferCars/108/',1,'makeblocks','LASTZ'),(109,4,200,'10','SYNTENY/inferCars/109/',1,'makeblocks','LASTZ'),(110,47,246,'10k','SYNTENY/inferCars/110/',1,'makeblocks','LASTZ'),(113,12,59,'10','SYNTENY/inferCars/113/',1,'makeblocks','LASTZ'),(114,11,62,'100k','SYNTENY/inferCars/114/',1,'makeblocks','LASTZ'),(115,5,16,'1000k','SYNTENY/inferCars/115/',1,'makeblocks','LASTZ'),(117,11,3,'1000k','SYNTENY/inferCars/117/',1,'makeblocks','LASTZ'),(118,5,222,'100k','SYNTENY/inferCars/118/',1,'makeblocks','LASTZ'),(122,2,263,'10k','SYNTENY/inferCars/122/',1,'makeblocks','LASTZ'),(126,24,59,'100k',NULL,0,'makeblocks','LASTZ'),(127,9,15,'1000k','SYNTENY/inferCars/127/',1,'makeblocks','LASTZ'),(128,12,256,'1k','SYNTENY/inferCars/128/',1,'makeblocks','LASTZ'),(129,12,265,'1k','SYNTENY/inferCars/129/',1,'makeblocks','LASTZ'),(130,9,266,'100k','SYNTENY/inferCars/130/',1,'makeblocks','LASTZ'),(131,5,267,'1k','SYNTENY/inferCars/131/',1,'makeblocks','LASTZ'),(132,12,268,'100k',NULL,0,'makeblocks','LASTZ'),(133,12,268,'2k','SYNTENY/inferCars/133/',1,'makeblocks','LASTZ'),(134,43,269,'100k','SYNTENY/inferCars/134/',1,'makeblocks','LASTZ');
/*!40000 ALTER TABLE `synteny` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taxon_id`
--

DROP TABLE IF EXISTS `taxon_id`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `taxon_id` (
  `taxon_id` int NOT NULL DEFAULT '0',
  `name` text,
  `common_name` text,
  `rank` char(30) DEFAULT NULL,
  PRIMARY KEY (`taxon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taxon_id`
--

LOCK TABLES `taxon_id` WRITE;
/*!40000 ALTER TABLE `taxon_id` DISABLE KEYS */;
INSERT INTO `taxon_id` VALUES (543,'Enterobacteriaceae','Enterobacteriaceae','family'),(561,'Escherichia','Escherichia','genus'),(562,'Escherichia coli','E. coli','species'),(1224,'Proteobacteria','purple_photosynthetic_bacteria','phylum'),(1236,'Gammaproteobacteria','Gammaproteobacteria','class'),(1239,'Firmicutes','low_G+C_Gram-positive_bacteria','phylum'),(1385,'Bacillales','Bacillales','order'),(1386,'Bacillus','Bacillus_rRNA_group_1','genus'),(3055,'Chlamydomonas_reinhardtii','green_algae','species'),(3218,'Physcomitrium_patens','mosses','species'),(3244,'Selaginellales','spike_mosses','order'),(3245,'Selaginellaceae','spike_mosses','family'),(3246,'Selaginella','Selaginella','genus'),(3398,'Magnoliopsida','flowering_plants','class'),(3646,'Malpighiales','Malpighiales','order'),(3659,'Cucumis_sativus','cucember','species'),(3688,'Salicaceae','willow_family','family'),(3689,'Populus','poplars','genus'),(3694,'Populus_trichocarpa','black_cottonwood','species'),(3699,'Brassicales','Brassicales','order'),(3700,'Brassicaceae','mustard_family','family'),(3701,'Arabidopsis','Arabidopsis','genus'),(3702,'Arabidopsis_thaliana','thale_cress','species'),(3803,'Fabaceae','pea_family','family'),(3846,'Glycine','Glycine','genus'),(3847,'Glycine_max','soybean','species'),(4157,'Fungi','fungi','kingdom'),(4479,'Poaceae','grass_family','family'),(4527,'Oryza','Oryza','genus'),(4530,'Oryza_sativa','Asian_cultivated_rice','species'),(4896,'Schizosaccharomyces pombe','Schizosaccharomyces pombe','species'),(4932,'Saccharomyces cerevisiae','brewer\'s_yeast','species'),(5478,'Nakaseomyces_glabratus','budding_yeasts','species'),(6231,'Nematoda','roundworms','phylum'),(6236,'Rhabditida','Rhabditida','order'),(6237,'Caenorhabditis','Caenorhabditis','genus'),(6238,'Caenorhabditis_briggsae','Caenorhabditis_briggsae','species'),(6243,'Rhabditidae','Rhabditidae','family'),(6656,'Arthropoda','arthropods','phylum'),(7070,'Tribolium_castaneum','Red_flour_beetle','species'),(7147,'Diptera','flies','order'),(7157,'Culicidae','mosquitos','family'),(7164,'Anopheles','Anopheles','genus'),(7165,'Anopheles_gambiae','African_malaria_mosquito','species'),(7214,'Drosophilidae','pomace_flies','family'),(7215,'Drosophila','fruit_flies','genus'),(7227,'Drosophila_melanogaster','fruit_fly','species'),(7237,'Drosophila_pseudoobscura','Drosophila_pseudoobscura','species'),(7240,'Drosophila_simulans','Drosophila_simulans','species'),(7245,'Drosophila_yakuba','Drosophila_yakuba','species'),(7711,'Chordata','chordates','phylum'),(7739,'Branchiostoma_floridae','florida_lancelet','species'),(7952,'Cypriniformes','carps_and_others','order'),(7954,'Danio','Danio','genus'),(7955,'Danio_rerio','zebrafish','species'),(8006,'Salmoniformes','salmons_and_trouts','order'),(8015,'Salmonidae','salmonids','family'),(8016,'Oncorhynchus','Oncorhynchus','genus'),(8022,'Oncorhynchus_mykiss','rainbow_trout','species'),(8111,'Perciformes','perches_and_others','order'),(8292,'Amphibia','amphibians','class'),(8342,'Anura','frogs_and_toads','order'),(8352,'Pipidae','tongueless_frogs','family'),(8353,'Xenopus','Xenopus','genus'),(8355,'Xenopus_laevis','African_clawed_frog','species'),(8364,'Xenopus_tropicalis','western clawed frog','species'),(8504,'Lepidosauria','lepidosaurs','class'),(8509,'Squamata','squamates','order'),(8522,'Lacertidae','Lacertidae','family'),(8782,'Aves','birds','class'),(8976,'Galliformes','landfowls','order'),(8996,'Numida_meleagris','helmeted_guineafowl','species'),(9005,'Phasianidae','turkeys','family'),(9030,'Gallus','Gallus','genus'),(9031,'Gallus_gallus','chicken','species'),(9102,'Meleagris','Meleagris','genus'),(9103,'Meleagris_gallopavo','turkey','species'),(9126,'Passeriformes','song_birds','order'),(9255,'Monotremata','egg-laying_mammals','order'),(9256,'Ornithorhynchidae','Ornithorhynchidae','family'),(9257,'Ornithorhynchus','Ornithorhynchus','genus'),(9258,'Ornithorhynchus_anatinus','platypus','species'),(9265,'Didelphidae','opossums','family'),(9443,'Primates','Primates','order'),(9481,'Callithrix','Callithrix','genus'),(9483,'Callithrix_jacchus','white-tufted-ear_marmoset','species'),(9498,'Cebidae','Cebidae','family'),(9527,'Cercopithecidae','Old_World_monkeys','family'),(9539,'Macaca','macaques','genus'),(9541,'Macaca_fascicularis','crab-eating_macaque','species'),(9544,'Macaca_mulatta','Rhesus_monkey','species'),(9554,'Papio','baboons','genus'),(9555,'Papio_anubis','olive_baboon','species'),(9577,'Hylobatidae','gibbons','family'),(9592,'Gorilla','Gorilla','genus'),(9593,'Gorilla_gorilla','western_gorilla','species'),(9595,'Gorilla_gorilla_gorilla','western lowland gorilla',NULL),(9596,'Pan','chimpanzees','genus'),(9597,'Pan_paniscus','pygmy_chimpanzee','species'),(9598,'Pan_troglodytes','chimpanzee','species'),(9599,'Pongo','Pongo','genus'),(9601,'Pongo_abelii','Sumatran_orangutan','species'),(9604,'Hominidae','great_apes','family'),(9605,'Homo','humans','genus'),(9606,'Homo_sapiens','human','species'),(9608,'Canidae','dog,_coyote,_wolf,_fox','family'),(9611,'Canis','Canis','genus'),(9612,'Canis_lupus','gray_wolf','species'),(9681,'Felidae','cat_family','family'),(9682,'Felis','Felis','genus'),(9685,'Felis_catus','domestic_cat','species'),(9787,'Perissodactyla','odd-toed_ungulates','order'),(9788,'Equidae','horses','family'),(9789,'Equus','Equus','genus'),(9796,'Equus_caballus','horse','species'),(9895,'Bovidae','Bovidae','family'),(9903,'Bos','oxen,_cattle','genus'),(9913,'Bos_taurus','cattle','species'),(9935,'Ovis','Ovis','genus'),(9940,'Ovis_aries','sheep','species'),(9986,'Oryctolagus_cuniculus','rabbit','species'),(9989,'Rodentia','rodent','order'),(10066,'Muridae','Muridae','family'),(10088,'Mus','mouse','genus'),(10090,'Mus_musculus','house_mouse','species'),(10114,'Rattus','rats','genus'),(10116,'Rattus_norvegicus','Norway_rat','species'),(12480,'African green monkey polyomavirus','African green monkey polyomavirus','species'),(13615,'Monodelphis','short-tailed_opossums','genus'),(13616,'Monodelphis_domestica','gray_short-tailed_opossum','species'),(15368,'Brachypodium_distachyon','stiff_brome','species'),(28377,'Anolis_carolinensis','green_anole','species'),(30522,'Bos_indicus_x_Bos_taurus','hybrid_cattle','species'),(31022,'Tetraodontiformes','pufferfishes_and_others','order'),(31031,'Tetraodontidae','puffers','family'),(31032,'Takifugu','Takifugu','genus'),(31033,'Takifugu_rubripes','torafugu','species'),(33090,'Viridiplantae','plant','kingdom'),(33208,'Metazoa','animal','kingdom'),(33554,'Carnivora','carnivores','order'),(35493,'Streptophyta','Streptophyta','phylum'),(37611,'Estrildidae','Estrildidae','family'),(38605,'Didelphimorphia','Didelphimorphia','order'),(38820,'Poales','Poales','order'),(40674,'Mammalia','mammals','class'),(42163,'Podarcis','Podarcis','genus'),(42254,'Sorex araneus','Eurasian shrew','species'),(50557,'Insecta','true_insects','class'),(59689,'Arabidopsis lyrata','lyrate rockcress','species'),(59728,'Taeniopygia','Taeniopygia','genus'),(59729,'Taeniopygia_guttata','zebra_finch','species'),(61853,'Nomascus_leucogenys','northern_white-cheeked_gibbon','species'),(64176,'Podarcis_muralis','Common_wall_lizard','species'),(69291,'Gasterosteidae','sticklebacks_&_tubesnouts','family'),(69292,'Gasterosteus','Gasterosteus','genus'),(69293,'Gasterosteus_aculeatus','three-spined_stickleback','species'),(72025,'Fabales','Fabales','order'),(79684,'Microtus_ochrogaster','prairie_vole','species'),(88036,'Selaginella_moellendorffii','Selaginella_moellendorffii','species'),(91061,'Bacilli','Bacilli','class'),(91347,'Enterobacterales','Enterobacterales','order'),(91561,'Artiodactyla','even-toed ungulates','order'),(101020,'Fragaria_vesca_subsp._Vesca','wild_strawberry','subspecies'),(106582,'Maylandia_zebra','zebra_mbuna','species'),(119089,'Chromadorea','Chromadorea','class'),(151341,'Polyomaviridae','Polyomaviridae','family'),(186623,'Actinopteri','Actinopteri','class'),(186817,'Bacillaceae','Bacillaceae','family'),(325165,'Nomascus','Nomascus','genus'),(330879,'Aspergillus_fumigatus','ascomycete_fungi','species'),(1169664,'Escherichia-coli-AD30','E. coli',NULL),(1243664,'Bacillus massiliogorillae','Bacillus massiliogorillae','species'),(1336600,'Felis-catus-papillomavirus-3','Felis-catus-papillomavirus-3',NULL),(1521260,'Lycopodiopsida','clubmosses','class'),(2732415,'Cossaviricota','Cossaviricota','phylum'),(2732421,'Papovaviricetes','Papovaviricetes','class'),(2732532,'Sepolyvirales','Sepolyvirales','order'),(2743709,'Danionidae','Danionidae','family');
/*!40000 ALTER TABLE `taxon_id` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-12-11 13:31:44
