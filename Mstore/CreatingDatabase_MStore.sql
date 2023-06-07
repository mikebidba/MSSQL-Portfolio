/*
File: CreatingDatabase_Mstore.sql
Author: Michael Romero
Created: June 2023
Description: This script creates a small database that can be used to demo MS SQL Server DDL and DML features.  
*/


/*
Create a database at default MS Server installed location on your computer
By using the following SQL Command:
*/

USE Master
GO

DROP DATABASE IF EXISTS Mstore;
GO 

CREATE DATABASE Mstore
GO


/*  Verifying Database has been created */
SELECT Name [DatabaseName]
	FROM Master.sys.databases
	WHERE Name = 'Mstore';


/* Make sure all further script execute on Mstore database  */
USE [Mstore]
GO

/*  Create store schemas 
 which is a list of logical structures of data
 that can be grouped into logical groups */
CREATE SCHEMA HR
GO
CREATE SCHEMA PRODUCTION
GO
CREATE SCHEMA SALES
GO


/* Verify and Display schemas */
SELECT CATALOG_NAME AS [Database_Name], SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA
where SCHEMA_NAME in ('HR','PRODUCTION','SALES')




/*	Create MStore tables - each with a Primary clustered index */
CREATE TABLE PRODUCTION.Product
(
	ProductId INT IDENTITY(1,1) NOT NULL,
	ProductName VARCHAR(255) NOT NULL,
	CategoryId INT NOT NULL,
	UnitPrice DECIMAL(10, 2) NOT NULL,
	CONSTRAINT PK_Product_ProductId PRIMARY KEY CLUSTERED (ProductId)
)
GO


CREATE TABLE PRODUCTION.ProductCategory
(
	CategoryId INT IDENTITY(1,1) NOT NULL,
	CategoryName VARCHAR(255) NOT NULL,
	CONSTRAINT PK_ProductCategory_CategoryId PRIMARY KEY CLUSTERED (CategoryId)
)
GO


CREATE TABLE SALES.Orders
(
	OrderId INT IDENTITY(1,1) NOT NULL,
	CustomerId INT NULL,
	ProductId INT NULL,
	UnitsSold	INT NULL,
	OrderDate DATE NOT NULL CONSTRAINT DF_Orders_OrderDate_GETDATE DEFAULT GETDATE(),
	SalesPersonId int NOT NULL,
	CONSTRAINT PK_Orders_OrderId PRIMARY KEY CLUSTERED (OrderId)
)
GO


CREATE TABLE SALES.Customer
(
	CustomerId INT IDENTITY(1,1) NOT NULL,
	FirstName NVARCHAR(20) NULL,
	LastName NVARCHAR(20) NULL,
	City NVARCHAR(100) NULL,
	[State] NVARCHAR(100) NULL,
	CONSTRAINT PK_Customer_CustomerId PRIMARY KEY CLUSTERED (CustomerId)
)
GO


CREATE TABLE HR.Employee
(
	EmployeeId INT IDENTITY(1,1) NOT NULL,
	FirstName NVARCHAR(20) NULL,
	LastName NVARCHAR(20) NULL,
	DepartmentId INT NULL,
	ManagerId INT NULL,
	Salary	DECIMAL (10,2) NULL,
	HiredDate	DATE,
	CONSTRAINT PK_Employee_EmployeeId PRIMARY KEY CLUSTERED (EmployeeId)
)
GO


CREATE TABLE HR.Department
(
	DepartmentId INT IDENTITY(1,1) NOT NULL,
	DepartmentName NVARCHAR(20) NULL,
	CONSTRAINT PK_Department_DepartmentId PRIMARY KEY CLUSTERED (DepartmentId)
)
GO


/* Verify and Display All Tables in Mstore */
SELECT  *
FROM  INFORMATION_SCHEMA.TABLES;
GO


/* Insert sample data into tables
Turning ON IDENTITY_INSERT to allow Primary Key insertion into table
providing referential key alignment in initial data load */

SET IDENTITY_INSERT [HR].[Department] ON 
GO
INSERT [HR].[Department] ([DepartmentId], [DepartmentName]) VALUES (1, N'Groceries')
GO
INSERT [HR].[Department] ([DepartmentId], [DepartmentName]) VALUES (2, N'Electronics')
GO
INSERT [HR].[Department] ([DepartmentId], [DepartmentName]) VALUES (3, N'Automotive')
GO
SET IDENTITY_INSERT [HR].[Department] OFF
GO

SET IDENTITY_INSERT [HR].[Employee] ON 
GO
INSERT [HR].[Employee] ([EmployeeId], [FirstName], [LastName], [DepartmentId], [ManagerId], [Salary], [HiredDate]) VALUES (1, N'Jasmin', N'Green', 1, 0, 90000.00, N'2018-01-01')
GO
INSERT [HR].[Employee] ([EmployeeId], [FirstName], [LastName], [DepartmentId], [ManagerId], [Salary], [HiredDate]) VALUES (2, N'Jim', N'Vernola', 2, 0, 95000.00, N'2019-05-24')
GO
INSERT [HR].[Employee] ([EmployeeId], [FirstName], [LastName], [DepartmentId], [ManagerId], [Salary], [HiredDate]) VALUES (3, N'Katie', N'Higgs', 3, 0, 85000.00, N'2020-06-18')
GO
INSERT [HR].[Employee] ([EmployeeId], [FirstName], [LastName], [DepartmentId], [ManagerId], [Salary], [HiredDate]) VALUES (4, N'Sam', N'Kitt', 3, 3, 75000.00, N'2021-04-02')
GO
INSERT [HR].[Employee] ([EmployeeId], [FirstName], [LastName], [DepartmentId], [ManagerId], [Salary], [HiredDate]) VALUES (5, N'Hana', N'Sato', 1, 1, 73000.00, N'2021-05-05')
GO
INSERT [HR].[Employee] ([EmployeeId], [FirstName], [LastName], [DepartmentId], [ManagerId], [Salary], [HiredDate]) VALUES (6, N'Beth', N'Castillo', 1, 1, 76000.00, N'2021-07-24')
GO
INSERT [HR].[Employee] ([EmployeeId], [FirstName], [LastName], [DepartmentId], [ManagerId],[Salary], [HiredDate]) VALUES (7, N'Jacob', N'Perez', 1, 1, 70000.00, N'2021-11-01')
GO
INSERT [HR].[Employee] ([EmployeeId], [FirstName], [LastName], [DepartmentId], [ManagerId], [Salary], [HiredDate]) VALUES (8, N'Jean', N'Gray', 2, 2, 70000.00, N'2022-02-15')
GO
INSERT [HR].[Employee] ([EmployeeId], [FirstName], [LastName], [DepartmentId], [ManagerId], [Salary], [HiredDate]) VALUES (9, N'Kerry', N'Jameson', 3, 3, 68000.00, N'2022-04-10')
GO
SET IDENTITY_INSERT [HR].[Employee] OFF
GO

SET IDENTITY_INSERT [PRODUCTION].[Product] ON 
GO
INSERT [PRODUCTION].[Product] ([ProductId], [ProductName], [CategoryId], [UnitPrice]) VALUES (1, N'Ice Cream', 1, 4.50)
GO
INSERT [PRODUCTION].[Product] ([ProductId], [ProductName], [CategoryId], [UnitPrice]) VALUES (2, N'Meat', 2, 6.95)
GO
INSERT [PRODUCTION].[Product] ([ProductId], [ProductName], [CategoryId], [UnitPrice]) VALUES (3, N'Soap', 3, 5.00)
GO
INSERT [PRODUCTION].[Product] ([ProductId], [ProductName], [CategoryId], [UnitPrice]) VALUES (4, N'Iphone', 4, 499.00)
GO
INSERT [PRODUCTION].[Product] ([ProductId], [ProductName], [CategoryId], [UnitPrice]) VALUES (5, N'Surface', 5, 699.00)
GO
INSERT [PRODUCTION].[Product] ([ProductId], [ProductName], [CategoryId], [UnitPrice]) VALUES (6, N'Sony', 6, 299.00)
GO
INSERT [PRODUCTION].[Product] ([ProductId], [ProductName], [CategoryId], [UnitPrice]) VALUES (7, N'Tires', 7, 89.00)
GO
INSERT [PRODUCTION].[Product] ([ProductId], [ProductName], [CategoryId], [UnitPrice]) VALUES (8, N'Oil', 8, 7.99)
GO
INSERT [PRODUCTION].[Product] ([ProductId], [ProductName], [CategoryId], [UnitPrice]) VALUES (9, N'Wax', 9, 9.59)
GO
SET IDENTITY_INSERT [PRODUCTION].[Product] OFF
GO

SET IDENTITY_INSERT [PRODUCTION].[ProductCategory] ON 
GO
INSERT [PRODUCTION].[ProductCategory] ([CategoryId], [CategoryName]) VALUES (1, N'Frozen')
GO
INSERT [PRODUCTION].[ProductCategory] ([CategoryId], [CategoryName]) VALUES (2, N'Deli')
GO
INSERT [PRODUCTION].[ProductCategory] ([CategoryId], [CategoryName]) VALUES (3, N'Haba')
GO
INSERT [PRODUCTION].[ProductCategory] ([CategoryId], [CategoryName]) VALUES (4, N'Mobile')
GO
INSERT [PRODUCTION].[ProductCategory] ([CategoryId], [CategoryName]) VALUES (5, N'Computers')
GO
INSERT [PRODUCTION].[ProductCategory] ([CategoryId], [CategoryName]) VALUES (6, N'TV')
GO
INSERT [PRODUCTION].[ProductCategory] ([CategoryId], [CategoryName]) VALUES (7, N'Parts')
GO
INSERT [PRODUCTION].[ProductCategory] ([CategoryId], [CategoryName]) VALUES (8, N'Accersories')
GO
INSERT [PRODUCTION].[ProductCategory] ([CategoryId], [CategoryName]) VALUES (9, N'Detailing')
GO
SET IDENTITY_INSERT [PRODUCTION].[ProductCategory] OFF
GO

SET IDENTITY_INSERT [SALES].[Customer] ON 
GO
INSERT [SALES].[Customer] ([CustomerId], [FirstName], [LastName], [City], [State]) VALUES (1, N'Carl', N'Lopez', N'Corona', N'CA')
GO
INSERT [SALES].[Customer] ([CustomerId], [FirstName], [LastName], [City], [State]) VALUES (2, N'Jean', N'Roberts', N'RiversIde', N'CA')
GO
INSERT [SALES].[Customer] ([CustomerId], [FirstName], [LastName], [City], [State]) VALUES (3, N'Emma', N'Parks', N'Moreno Valley', N'CA')
GO
INSERT [SALES].[Customer] ([CustomerId], [FirstName], [LastName], [City], [State]) VALUES (4, N'Jason', N'Davis', N'RiversIde', N'CA')
GO
INSERT [SALES].[Customer] ([CustomerId], [FirstName], [LastName], [City], [State]) VALUES (5, N'Richard', N'Thompson', N'Sedona', N'AZ')
GO
INSERT [SALES].[Customer] ([CustomerId], [FirstName], [LastName], [City], [State]) VALUES (6, N'Abigail', N'Rose', N'Mesa', N'AZ')
GO
SET IDENTITY_INSERT [SALES].[Customer] OFF
GO

SET IDENTITY_INSERT [SALES].[Orders] ON 
GO
INSERT [SALES].[Orders] ([OrderId], [CustomerId], [ProductId], [UnitsSold], [OrderDate], [SalesPersonId]) VALUES (1, 1, 1, 4, N'2022-05-01', 5)
GO
INSERT [SALES].[Orders] ([OrderId], [CustomerId], [ProductId], [UnitsSold], [OrderDate], [SalesPersonId]) VALUES (2, 2, 2, 3, N'2022-05-12', 5)
GO
INSERT [SALES].[Orders] ([OrderId], [CustomerId], [ProductId], [UnitsSold], [OrderDate], [SalesPersonId]) VALUES (3, 3, 3, 5, N'2022-06-11', 6)
GO
INSERT [SALES].[Orders] ([OrderId], [CustomerId], [ProductId], [UnitsSold], [OrderDate], [SalesPersonId]) VALUES (4, 1, 2, 5, N'2022-06-24', 7)
GO
INSERT [SALES].[Orders] ([OrderId], [CustomerId], [ProductId], [UnitsSold], [OrderDate], [SalesPersonId]) VALUES (5, 4, 4, 1, N'2022-06-25', 8)
GO
INSERT [SALES].[Orders] ([OrderId], [CustomerId], [ProductId], [UnitsSold], [OrderDate], [SalesPersonId]) VALUES (6, 5, 5, 1, N'2022-06-27', 8)
GO
INSERT [SALES].[Orders] ([OrderId], [CustomerId], [ProductId], [UnitsSold], [OrderDate], [SalesPersonId]) VALUES (7, 2, 6, 1, N'2022-07-02', 8)
GO
INSERT [SALES].[Orders] ([OrderId], [CustomerId], [ProductId], [UnitsSold], [OrderDate], [SalesPersonId]) VALUES (8, 6, 7, 4, N'2022-07-05', 4)
GO
INSERT [SALES].[Orders] ([OrderId], [CustomerId], [ProductId], [UnitsSold], [OrderDate], [SalesPersonId]) VALUES (9, 6, 8, 5, N'2022-07-05', 4)
GO
INSERT [SALES].[Orders] ([OrderId], [CustomerId], [ProductId], [UnitsSold], [OrderDate], [SalesPersonId]) VALUES (10, 6, 7, 4, N'2022-07-05', 9)
GO
INSERT [SALES].[Orders] ([OrderId], [CustomerId], [ProductId], [UnitsSold], [OrderDate], [SalesPersonId]) VALUES (11, 6, 6, 2, N'2022-07-05', 8)
GO
SET IDENTITY_INSERT [SALES].[Orders] OFF
GO


/* Adding FOREIGN KEY constraints between tables 
FOREIGN KEY is column in a table that enforce referential integrity to the primary key of other table
and creates a link between the two tables.*/

ALTER TABLE [HR].[Employee] 
ADD  CONSTRAINT [FK_Employee_Department] FOREIGN KEY([DepartmentId])
REFERENCES [HR].[Department] ([DepartmentId])
GO

ALTER TABLE [PRODUCTION].[Product] 
ADD  CONSTRAINT [FK_Product_ProductCategory] FOREIGN KEY([CategoryId])
REFERENCES [PRODUCTION].[ProductCategory] ([CategoryId])
GO

ALTER TABLE [SALES].[Orders] 
ADD  CONSTRAINT [FK_Orders_Customer] FOREIGN KEY([CustomerId])
REFERENCES [SALES].[Customer] ([CustomerId])
GO

ALTER TABLE [SALES].[Orders] 
ADD  CONSTRAINT [FK_Orders_Employee] FOREIGN KEY([SalesPersonId])
REFERENCES [HR].[Employee] ([EmployeeId])
GO

ALTER TABLE [SALES].[Orders] 
ADD  CONSTRAINT [FK_Orders_Product] FOREIGN KEY([ProductId])
REFERENCES [PRODUCTION].[Product] ([ProductId])
GO