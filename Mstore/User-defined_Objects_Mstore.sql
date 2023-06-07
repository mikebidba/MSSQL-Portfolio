/*
File: User-defined_Objects_Mstore.sql
Author: Michael Romero
Created: June 2023

Description: This script creates demonstration samples of User-defined objects (e.g. Views, Stored Procedures, UDFs) on database Mstore.
The stored Procedure SALES.uspDiscountWorstProduct will add a discount to worst selling product.

Usage: Execute  this entire script to build all 3 object and test final result for Mstore database.

Prerequisite: Execute script CreatingDatabase_Mstore.sql

Script Compatiability: SQL Server 2016 or higher
*/


/* Point to Mstore database */
USE Mstore;
GO

/****** Creating Object: View SALES.vwPoductSalesByYear ******/

DROP VIEW IF EXISTS SALES.vwPoductSalesByYear;
GO

-- =============================================
-- Author:		Michael Romero
-- Created: June 2023
-- Description:	List all the employees that work at Mstore
-- =============================================
CREATE VIEW SALES.vwPoductSalesByYear
AS
SELECT P.ProductId, P.ProductName, SUM(O.UnitsSold) [TotalUnitsSold], MAX(P.UnitPrice) [UnitPrice] , SUM(O.UnitsSold * P.UnitPrice) [TotalSales], YEAR(O.OrderDate) [Year]
  FROM 
	SALES.Orders O
		INNER JOIN
	PRODUCTION.Product P
		ON O.ProductId = P.ProductId
GROUP BY
	P.ProductId,
	P.ProductName,
	YEAR(O.OrderDate);
GO



/****** Creating Object: User Defined Function SALES.ufnGetWorstProductId ******/

DROP FUNCTION IF EXISTS SALES.fn_GetWorstProductId;
GO

-- =============================================
-- Author:		Michael Romero
-- Created: June 2023
-- Description:	Returns Worst selling ProductId at Mstore
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION SALES.fn_GetWorstProductId(@YEAR INT)
RETURNS INT 
AS 
-- Returns ProductId
BEGIN
    DECLARE @ret INT;

    SET @ret = 0;

	SELECT TOP 1 @ret = ProductId
	FROM SALES.vwPoductSalesByYear
	WHERE [Year] = @Year
	ORDER BY TotalSales ASC

    
    RETURN @ret
END;

GO






/****** Creating Object: Stored Procedure SALES.DiscountWorstProduct ******/

USE [Mstore];
GO

DROP PROCEDURE IF EXISTS SALES.uspDiscountWorstProduct;
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Michael Romero
-- Created: June 2023
-- Description:	Add discount to worst selling product unit price
-- =============================================
CREATE PROCEDURE [SALES].[uspDiscountWorstProduct] 
	@Year INT = 2022, --Defaults
	@DiscountRate DECIMAL(10,4) = 0.25  --Defaults
AS
BEGIN
	SET NOCOUNT ON

	DECLARE 
		@ProductID INT,
		@UnitPrice_Old DECIMAL(10,2)
 	
	/* Find Worst selling ProductId */
	SELECT @ProductID = SALES.fn_GetWorstProductId(@Year)

	/* Store old Product price */
	SELECT @UnitPrice_Old = UnitPrice FROM PRODUCTION.Product WHERE ProductId = @ProductID

	BEGIN TRY
		BEGIN TRANSACTION
		/* Update Product to new price */
		UPDATE PRODUCTION.Product
			SET UnitPrice = UnitPrice - (UnitPrice * @DiscountRate)
			WHERE ProductId = @ProductID

        PRINT 'COMMITTED TRANSACTION.'  

        COMMIT TRANSACTION;

	    /* Display New Product Price*/
		SELECT ProductId, ProductName, FORMAT(@DiscountRate, 'P') [Discounted %] ,@UnitPrice_Old [UnitPriceOld],UnitPrice [UnitPriceNew] 
			FROM PRODUCTION.Product 
			WHERE ProductId = @ProductID

	END TRY
	BEGIN CATCH
	/* Is transaction committable */
		IF (XACT_STATE()) = 1  
			BEGIN  
				PRINT 'COMMITTED TRANSACTION.'  
				COMMIT TRANSACTION;     
			END
			ELSE
			BEGIN  
				PRINT 'ROLLING BACK TRANSACTION.'  
				ROLLBACK TRANSACTION;     
			END
	END CATCH



END;
GO




/* TEST EXEC  -  stored procedure to discount worst selling product in 2022 by 10.5% */
USE [Mstore]
GO

EXEC	[SALES].[uspDiscountWorstProduct]
		@Year = 2022,
		@DiscountRate = 0.105


GO