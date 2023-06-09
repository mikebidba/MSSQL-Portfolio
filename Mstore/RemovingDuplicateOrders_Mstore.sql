/*
File: RemovingDuplicateOrders_Mstore.sql
Author: Michael Romero
Created: June 2023

Description: This script demostrates 4 different ways to remove duplicates in database Mstore.  
There are many variations and combination of these solutions but these 4 show some common techniques.

Prerequisite: Execute script CreatingDatabase_Mstore.sql

*/


/* Point to Mstore database */
USE Mstore;
GO

 
/****** Scenario 1 - Same order entered 3 times - Classic and my favorite ******/

--Loading orders with all columns identical
INSERT SALES.Orders (CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId)
	VALUES 
		(4, 6, 3, N'2023-03-05', 8),
		(4, 6, 3, N'2023-03-05', 8),
		(4, 6, 3, N'2023-03-05', 8);


--Just finding the duplicates in order table
SELECT	CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId,
		COUNT(CustomerId) [Dup_Count]
	FROM 
		SALES.Orders
	GROUP BY
		CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId
	HAVING 
		COUNT(CustomerId) > 1;


--Keep the first duplicate order entry and delete the remaining dulpicates 
DELETE FROM SALES.Orders
	WHERE OrderId NOT IN
	(
		SELECT 
			MIN(OrderId) 
			FROM 
				SALES.Orders
			GROUP BY 
				CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId
	);

-- Display Orders table to verify duplicates have been removed
SELECT * FROM SALES.Orders;
GO






/****** Scenario 2 - Same order entered 3 times - Using a Windows Function ******/

--This method only works when a single table is involved.

--Loading orders with all columns identical
INSERT SALES.Orders (CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId)
	VALUES 
		(5, 6, 3, N'2023-03-05', 8),
		(5, 6, 3, N'2023-03-05', 8),
		(5, 6, 3, N'2023-03-05', 8);

--Just finding the duplicates
WITH CTE
AS
(
	SELECT 
		*,
		RANK() OVER(PARTITION BY CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId ORDER BY OrderId ASC) AS [RankId]
		FROM 
			SALES.Orders
)
SELECT * FROM CTE WHERE RankId > 1;

--Keep the first duplicate order entry and delete the remaining dulpicates 
WITH CTE
AS
(
	SELECT 
		OrderID,
		RANK() OVER(PARTITION BY CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId ORDER BY OrderId ASC) AS [RankId]
		FROM 
			SALES.Orders
)
DELETE FROM CTE
	WHERE RankId > 1;

-- Display Orders table to verify duplicates have been removed
SELECT * FROM SALES.Orders;
GO





/****** Scenario 3 - Same order entered 3 times - Using a Windows Function and a variable table ******/

--This method demonstate variable table usage but it could have easily been accomplished with a Temp table or subquery.

INSERT SALES.Orders (CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId)
	VALUES 
		(2, 6, 3, N'2023-03-05', 8),
		(2, 6, 3, N'2023-03-05', 8),
		(2, 6, 3, N'2023-03-05', 8);


DECLARE @Dups TABLE
(
	Id INT IDENTITY(1,1),
	OrderId	INT
);

--Finding and loading the duplicates into variable table @Dups
WITH CTE
AS
(
	SELECT 
		OrderId,
		RANK() OVER(PARTITION BY CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId ORDER BY OrderId ASC) AS [RankId]
		FROM 
			SALES.Orders
)
INSERT INTO @Dups
	SELECT OrderId FROM CTE WHERE RankId > 1;

--Display duplicate orders
SELECT O.* 
	FROM 
		SALES.Orders O
			INNER JOIN
		@Dups D
			ON O.OrderId = D.OrderId;


--Keep the first duplicate order entry and delete the remaining dulpicates 
DELETE FROM SALES.Orders
	WHERE OrderId IN (SELECT OrderId FROM @Dups);


-- Display Orders table to verify duplicates have been removed
SELECT * FROM SALES.Orders;
GO




/****** Scenario 4 - Same order entered 3 times - Using a Windows Function and a Subquery ******/

--This method only works when a single table is involved.

--Loading orders with all columns identical
INSERT SALES.Orders (CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId)
	VALUES 
		(1, 6, 3, N'2023-03-05', 8),
		(1, 6, 3, N'2023-03-05', 8),
		(1, 6, 3, N'2023-03-05', 8);

--Just finding the duplicates
WITH CTE
AS
(
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId ORDER BY OrderId ASC) AS [RowNum]
		FROM 
			SALES.Orders
)
SELECT * FROM CTE WHERE RowNum > 1;

--Keep the first duplicate order entry and delete the remaining dulpicates 
DELETE Dups
	FROM
	(
		SELECT 
			*,
			ROW_NUMBER() OVER(PARTITION BY CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId ORDER BY OrderId ASC) AS [RowNum]
			FROM 
				SALES.Orders
	) AS Dups
		WHERE RowNum > 1;

-- Display Orders table to verify duplicates have been removed
SELECT * FROM SALES.Orders;
GO




/****** Scenario 4B - Same order entered 3 times - Using a Windows Function and a Subquery ******/

--This method works when 1 or tables are involved.

--Loading orders with all columns identical
INSERT SALES.Orders (CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId)
	VALUES 
		(3, 6, 1, N'2023-03-05', 8),
		(3, 6, 1, N'2023-03-05', 8),
		(3, 6, 1, N'2023-03-05', 8);

--Just finding the duplicates
WITH CTE
AS
(
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId ORDER BY OrderId ASC) AS [RowNum]
		FROM 
			SALES.Orders
)
SELECT * FROM CTE WHERE RowNum > 1;

--Keep the first duplicate order entry and delete the remaining dulpicates 
DELETE S
	FROM 
		SALES.Orders S
			INNER JOIN
		(
			SELECT 
				*,
				ROW_NUMBER() OVER(PARTITION BY CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId ORDER BY OrderId ASC) AS [RowNum]
				FROM 
					SALES.Orders
		) AS Dups 
			ON S.OrderId = Dups.OrderId
		WHERE Dups.RowNum > 1;

-- Display Orders table to verify duplicates have been removed
SELECT * FROM SALES.Orders;
GO