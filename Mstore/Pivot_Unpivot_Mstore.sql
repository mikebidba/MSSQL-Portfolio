/*
File: Pivot_Unpivot_Mstore.sql
Author: Michael Romero
Created: July 2023

Description: This script creates a demonstration of Pivot and Unpivot.
Pivot converts rows data of the table into column data. Pivot denormalize data. 
Unpivot converts column data of the table into row data.  Unpivot normalize data. 


Prerequisite: Execute script CreatingDatabase_Mstore.sql

*/



/* Point to Mstore database */
USE Mstore;
GO

/****** Drop pivot and unpivot tables if they exist ******/
DROP TABLE IF EXISTS sales.unitssold2022_Pivoted;
GO

DROP TABLE IF EXISTS SALES.UnitsSold2022_Unpivoted;
GO


/****** Scenario 1: Create a pivot table for product sold in the months of May, June and July ******/

--Pivot Data
--Load into new table
SELECT * INTO SALES.UnitsSold2022_Pivoted FROM   
	(
		SELECT ProductId
			  ,UnitsSold
			  ,DATENAME(month, OrderDate) [Month]
		  FROM Mstore.SALES.Orders
		  WHERE YEAR(OrderDate) = '2022'
	) t 
	PIVOT(
		COUNT(UnitsSold) 
		FOR [Month] IN ( May,June,July)
	) AS pivot_table;
GO


--Display pivot results
SELECT * FROM SALES.UnitsSold2022_Pivoted;




/****** Scenario 2: Create a Unpivot table for  each product sold in the each months of May, June and July ******/

--Unpivot Data
--Load into new table
SELECT * INTO SALES.UnitsSold2022_Unpivoted FROM   
(
		SELECT ProductId
			  , May,June,July
		  FROM Mstore.SALES.UnitsSold2022_Pivoted
		  
	) t 
	UNPIVOT
		(UnitsSold  
		FOR [Month] IN ( May,June,July)
	) AS unpivot_table;
GO

--Display unpivot results
SELECT * FROM SALES.UnitsSold2022_Unpivoted;
GO

