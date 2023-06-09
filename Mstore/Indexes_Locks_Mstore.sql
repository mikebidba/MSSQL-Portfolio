/*
File: Indexes_Locks_Mstore.sql
Author: Michael Romero
Created: June 2023

Description: This script creates a demonstration of Indexes and their affects on query execution plans.


Prerequisite: Execute script CreatingDatabase_Mstore.sql

*/



/* Point to Mstore database */
USE Mstore;
GO




/****** Scenario 1: Create Update with exclusive lock on row - Adding NonClustered Index. ******/

--Open Query in Window 1
-- Update with exclusive lock on row
BEGIN TRANSACTION
	UPDATE PRODUCTION.Product
		SET ProductName = 'Hand Soap'
		WHERE ProductName = 'Soap';

	WAITFOR DELAY '00:00:20';  --delay transaction rollback for 20 seconds

ROLLBACK TRANSACTION
GO

--Open Query in Window 2
--Excute the following query in another query execution window while the above UPDATE transaction is also executing.
--This query requires a shared lock while doing a clustered index scan and it is resource locked from completing until the above Update completes.
SELECT ProductName
	FROM PRODUCTION.Product
	WHERE ProductName = 'Tires';
GO

--Resolve this resource lock by adding a NONCLUSTERED INDEX on ProductName column.
--This NONCLUSTERED INDEX with result in the Cluster Index Seek for Query Window 2 above
CREATE NONCLUSTERED INDEX IX_Product_ProductName
	ON Mstore.PRODUCTION.Product (ProductName);
GO







/****** Scenario 2: Create Update with exclusive lock on row - Adding NonClustered Index with INCLUDE. ******/


--Open Query in Window 1
BEGIN TRANSACTION
	UPDATE PRODUCTION.Product
		SET ProductName = 'Hand Soap'
		WHERE ProductName = 'Soap';

	WAITFOR DELAY '00:00:20';  --delay transaction rollback for 20 seconds

ROLLBACK TRANSACTION
GO

--Open Query in Window 2
--Excute the following query in another query execution window while the above UPDATE transaction is also executing.
--This query requires a shared lock while doing a clustered index scan and it is resource locked from completing until the above Update completes.
--Note: In this scenario the SELECT * will still cause a index scan using just the index on column ProductName only as in scenario 1.
SELECT *
	FROM PRODUCTION.Product
	WHERE ProductName = 'Tires';
GO

--Resolve this resource lock by adding a NONCLUSTERED INDEX on ProductName column and adding an INCLUDE for remaining 2 columns.
--This NONCLUSTERED INDEX with result in the Cluster Index Seek for Query Window 2 above
CREATE NONCLUSTERED INDEX IX_Product_ProductName2
	ON Mstore.PRODUCTION.Product (ProductName)
	INCLUDE (CategoryId, UnitPrice);
GO





/******* NOTE: Depending on the original Product table design, other variations of Clustered, NonClustered 
and even In-Memory Optimized NONCLUSTERED HASH indexes can be used to resolve similiar locking scenarios. *******/



/******* NOTE: View the type of locking resource by identifying the SPID for the each operation above and using the following query *******/
SELECT *
	FROM 
		sys.dm_tran_locks
	WHERE
		request_request_id = 82; --replace with the SPID from your executions.

GO


