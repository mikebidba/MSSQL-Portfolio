/*
File: Cursor_Looping_RBAR_Mstore.sql
Author: Michael Romero
Created: June 2023

Description: This script creates a demonstration sample of a Cursor looping through and updating a dataset and comparing it against a set-based operation.
RBAR (Row by Agonizing Row) is a SQL term for looping through and performing an action on a dataset one row at a time.
For small datasets like Mstore this is not an issue but in larger datasets or as small datasets grow over time this can result in a major performance issue.
If there is a set-based way to perform your task, always choose it over looping with a cursor. 

Note: Omitting transaction declaration as this is simple demonstration.

Prerequisite: Execute script CreatingDatabase_Mstore.sql


*/


/* Point to Mstore database */
USE Mstore;
GO


/****** Display Original table values for reference ******/
SELECT * FROM PRODUCTION.Product;
GO




/****** Scenario 1: Cursor to loop through each product and increase unit price by 10% ******/

--Adding and initializing timer
DECLARE 
	@StartTime datetime,
	@EndTime datetime

SELECT @StartTime = GETDATE();

--Create variables to hold cursor fetch values
DECLARE
	@ProductId	INT,
	@UnitPrice DECIMAL(10,2)

--Create Cursor
DECLARE db_cursor CURSOR FOR
	SELECT 
		ProductId,
		UnitPrice
	FROM 
		PRODUCTION.Product;

--Open cursor
OPEN db_cursor

--Fetch 1st row
FETCH NEXT 
	FROM db_cursor 
	INTO @ProductId, @UnitPrice;

WHILE @@FETCH_STATUS = 0
--Loop through each row 
	BEGIN
		--Update each UnitPrice 
		Update PRODUCTION.Product
			SET UnitPrice =  UnitPrice + (UnitPrice * 0.10)
			WHERE ProductId = @ProductId;

		--Get next row values
		FETCH NEXT 
			FROM db_cursor 
			INTO @ProductId, @UnitPrice; 

	END

--Close Cursor
CLOSE db_cursor;

--Deallocate Cursor
DEALLOCATE db_cursor;

--Cursor Completion time
SELECT @EndTime = GETDATE();

--Return execution time 
SELECT COALESCE(DATEDIFF(MS,@StartTime,@EndTime), 0) [Cursor Duration (ms)];

--Display updated table values
SELECT * FROM PRODUCTION.Product;

GO






/****** Scenario 2: Using Set-based operation to update product and increase unit price by 10% ******/


DECLARE 
	@StartTime datetime,
	@EndTime datetime

SELECT @StartTime = GETDATE();


--Update each UnitPrice 
Update PRODUCTION.Product
	SET UnitPrice =  UnitPrice + (UnitPrice * 0.10);


--Return execution time of your query
SELECT COALESCE(DATEDIFF(MS,@StartTime,@EndTime), 0)  [Set Based Duration (ms)];


--Display updated table values
SELECT * FROM PRODUCTION.Product;

GO


