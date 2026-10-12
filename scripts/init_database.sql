/*
===========================================================
Create Database And Schema
===========================================================
script purpose:
	this script creates a dataase called DataWearhouse and after chacking if it exist it drops and recreate it.
	additionaly thos script create three schema Bronze, Silver and Gold .
WARNING:
	Running thos scripit will drop the entire DataWearhouse database if exists
	procced with caution and ensure ou have a backup fill
*/

USE MASTER;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE  name = 'DataWearhouse')
BEGIN
	ALTER DATABASE DataWearhouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWearhouse;
END;

CREATE DATABASE DataWearhouse;
USE DataWearhouse;

CREATE SCHEMA Bronze;
GO
CREATE SCHEMA Silver;
GO
CREATE SCHEMA Gold;
