/*
File: External_Data_Imports_Mstore.sql
Author: Michael Romero
Created: June 2023

Description: This script creates a demonstration of external data insert techniques.
There are many ETL tools available that accomplish such as SSIS, but I wanted to show the techniques based on T-SQL. 

Note: Omitting transaction declaration as this is simple demonstration.

Prerequisite: 
1.Execute script CreatingDatabase_Mstore.sql
2.Also create a local folder to hold the external data files and rename the path to the folder in the BULK INSERT and OPENROWSET command parameters. 
3.Download from Mstore repository: MStore_New_Product.csv; MStore_New_ProductCategory.csv; MStore_New_ProductCategory.fmt
4.Place csv and fmt files in your local folder from Prerequisite 2.

*/



/* Point to Mstore database */
USE Mstore;
GO


/****** Display Original tables values for reference ******/
SELECT * FROM PRODUCTION.Product;
SELECT * FROM PRODUCTION.ProductCategory;
GO


/****** Senario 1: Using BULK INSERT and Staging table ******/


--Create Staging table
DROP TABLE IF EXISTS PRODUCTION.Staging_Product;

CREATE TABLE PRODUCTION.Staging_Product
(
	ProductName varchar(255) NOT NULL,
	CategoryId int NOT NULL,
	UnitPrice decimal(10, 2) NOT NULL
 )


--Rename for C:\TempData\ to your local folder hold the csv file.
--Do BULK INSERT of data from csv file.
BULK INSERT PRODUCTION.Staging_Product
	FROM 'C:\TempData\MStore_New_Product.csv'
		WITH
		(
			FORMAT = 'CSV',
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR='\n'
		);


--Load data from Staging table that do not already exist in PRODUCTION.Product table.
INSERT INTO PRODUCTION.Product
	SELECT S.* 
		FROM 
			PRODUCTION.Staging_Product S
				LEFT JOIN
			PRODUCTION.Product P
				ON S.ProductName = P.ProductName
		WHERE 
			P.ProductName IS NULL;

--Display New table values for reference 
SELECT * FROM PRODUCTION.Product;


GO






/****** Scenario 2: Using OPENROWSET BULK and Format file and staging table ******/


--Create staging table
DROP TABLE IF EXISTS PRODUCTION.Staging_ProductCategory;

CREATE TABLE PRODUCTION.Staging_ProductCategory
(
	CategoryName varchar(255) NOT NULL
)


--Rename folder C:\TempData\ to your local folder holding the csv and fmt files.
--Do insert of data from csv file using fmt file.
INSERT INTO PRODUCTION.Staging_ProductCategory
	SELECT NewCategory.CategoryName
		FROM OPENROWSET
		(
			BULK N'C:\TempData\MStore_New_ProductCategory.csv',
			FORMATFILE = N'C:\TempData\Mstore_New_ProductCategory.fmt',
			FIRSTROW=2,
			FORMAT='CSV'
		) AS NewCategory;

--Load data from Staging table that do not already exist in PRODUCTION.ProductCategory table.
INSERT INTO PRODUCTION.ProductCategory
	SELECT S.* 
		FROM 
			PRODUCTION.Staging_ProductCategory S
				LEFT JOIN
			PRODUCTION.ProductCategory C
				ON S.CategoryName = C.CategoryName
		WHERE 
			C.CategoryName IS NULL;

--Display New table values for reference 
SELECT * FROM PRODUCTION.ProductCategory;

