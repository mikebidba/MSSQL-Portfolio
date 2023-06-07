/*
File: AuditLogging_WithTrigger_Mstore.sql
Author: Michael Romero
Created: June 2023

Description: This script creates demonstration Trigger usage on database Mstore.
The Stored Procedure for SALES.ispOrders will insert new orders. Trigger SALES.trgOrdersHistory will add order operations to SALES.OrdersHistory.
SALES.OrdersHistory includes a hashing column that can be used later to verify the data entry integrity against manual data alteration.


Prerequisite: Execute script CreatingDatabase_Mstore.sql

Usage: Execute following 4 object in numeric order 1 through 4.

Script Compatiability: SQL Server 2016 or higher
*/


/* Point to Mstore database */
USE Mstore;
GO

/****** 1. Creating Object: Table SALES.OrdersHistory ******/

-- USING SYSOBJECT DROP METHOD IN THIS SCRIPT TO SHOW CLASSIC TECHNIQUE
IF
EXISTS
(
	SELECT	1
	FROM	SYSOBJECTS
	WHERE	id	= OBJECT_ID ('SALES.OrdersHistory')
)
	DROP TABLE SALES.OrdersHistory;
GO


CREATE TABLE SALES.OrdersHistory
(
	OrdersHistoryId INT IDENTITY(1,1) NOT NULL,
	OrderId INT NOT NULL,
	CustomerId INT NULL,
	ProductId INT NULL,
	UnitsSold	INT NULL,
	OrderDate DATE NOT NULL, 
	SalesPersonId int NOT NULL,
	Operation NVARCHAR(10) NOT NULL,
	LogDate DATE NOT NULL CONSTRAINT DF_OrdersHistory_OrdersHistoryId_GETDATE DEFAULT GETDATE(),
	HashId	NVARCHAR(32) NULL,
	CONSTRAINT PK_OrdersHistory_OrdersHistoryId PRIMARY KEY CLUSTERED (OrdersHistoryId)
)
GO



/******* 2. Create Object: Hashing function  *********/
IF
EXISTS
(
	SELECT	1
	FROM	SYSOBJECTS
	WHERE	id	= OBJECT_ID ('SALES.fn_CalculateHash')
)
	DROP FUNCTION	SALES.fn_CalculateHash;
GO
 
 --Simple MD5 hashing function
CREATE FUNCTION	SALES.fn_CalculateHash
(
	@OrderId		nvarchar(10)	= ''
,	@CustomerId		nvarchar(10)	= ''
,	@ProductId		nvarchar(10)	= ''
,	@UnitsSold		nvarchar(10)	= ''
,	@OrderDate		nvarchar(10)	= ''
,	@SalesPersonId	nvarchar(10)	= ''
)
RETURNS NVARCHAR(32)
AS
BEGIN
	DECLARE  @strColumnValues NVARCHAR(max), 
		@Result NVARCHAR(32)
	 -- Concatenate a columns used in hashing function
	SET @strColumnValues = @OrderId + @CustomerId + @ProductId + @UnitsSold + @OrderDate + @SalesPersonId
    -- Generate HAshing MD5
    SET @Result = SubString(Master.dbo.fn_varbintohexstr(HashBytes('MD5', @strColumnValues)), 3, 32)
    -- Return Hashed value
    RETURN @Result
END
GO



/****** 3. Creating Object: Stored Procedure for SALES.ispOrders ******/

IF
EXISTS
(
	SELECT	1
	FROM	SYSOBJECTS
	WHERE	id	= OBJECT_ID ('SALES.ispOrders')
)
	DROP PROCEDURE SALES.ispOrders;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	Michael Romero
-- Created: June 2023
-- Description:	Insert order into Sales.Orders table
-- =============================================
CREATE PROCEDURE SALES.ispOrders
	@CustomerId		INT
,	@ProductId		INT
,	@UnitsSold		INT
,	@OrderDate		DATE
,	@SalesPersonId	INT
,	@OrderId		INT	OUTPUT
AS
BEGIN
	SET NOCOUNT ON
 	BEGIN TRY
		BEGIN TRANSACTION
		INSERT INTO SALES.Orders (CustomerId, ProductId, UnitsSold, SalesPersonId) 
			SELECT @CustomerId, @ProductId, @UnitsSold, @SalesPersonId
		SET @OrderId = SCOPE_IDENTITY()
        PRINT 'COMMITTED TRANSACTION FOR ORDERS.'  
        COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
	/* Is transaction committable */
		IF (XACT_STATE()) = 1  
			BEGIN  
				PRINT 'COMMITTED TRANSACTION FOR ORDERS.'  
				COMMIT TRANSACTION;     
			END
			ELSE
			BEGIN  
				PRINT 'ROLLING BACK TRANSACTION FOR ORDERS.'  
				ROLLBACK TRANSACTION;     
			END
	END CATCH

END;
GO





/****** 4. Creating Object: Trigger for SALES.OrdersHistory ******/
IF
EXISTS
(
	SELECT	1 
	FROM	sys.triggers
	WHERE	object_id = OBJECT_ID(N'[SALES].[trgOrdersHistory]')
)
	DROP TRIGGER SALES.trgOrdersHistory
GO


-- =============================================
-- Author:	Michael Romero
-- Created: June 2023
-- Description:	Trigger for Insert, Update and Delete of order into Sales.Orders table
-- Adds a history table entry for each row operation.
-- =============================================
CREATE TRIGGER SALES.trgOrdersHistory
ON	SALES.Orders
AFTER	INSERT,UPDATE,DELETE
AS
BEGIN
	DECLARE
		@insert bit = 0,
	    @delete bit = 0, 
		@LogDate	DATE,
		@Operation NVARCHAR(10)

	SET @LogDate = GETDATE()

    IF EXISTS(SELECT 1 FROM inserted) 
		SET @insert = 1
	  
    IF EXISTS(SELECT 1 FROM deleted) 
		SET @delete = 1 	
	
	SELECT @Operation = 
		CASE
			WHEN @delete = 0 THEN 'INSERT'
			WHEN @insert = 0 THEN 'DELETE'
			ELSE 'UPDATE'
		END

 	BEGIN TRY
		BEGIN TRANSACTION

			IF @Operation IN ('INSERT', 'UPDATE')
				BEGIN
					INSERT INTO SALES.OrdersHistory 
						SELECT OrderId, CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId, @Operation, @LogDate,
						SALES.fn_CalculateHash(OrderId, CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId)					
						FROM INSERTED
				END
				ELSE
				BEGIN
					INSERT INTO SALES.OrdersHistory 
						SELECT OrderId, CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId, @Operation, @LogDate,
						SALES.fn_CalculateHash(OrderId, CustomerId, ProductId, UnitsSold, OrderDate, SalesPersonId)					
						FROM DELETED
				END

        PRINT 'COMMITTED TRANSACTION FOR ORDERSHISTORY.'  
        COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
	/* Is transaction committable */
		IF (XACT_STATE()) = 1  
			BEGIN  
				PRINT 'COMMITTED TRANSACTION FOR ORDERSHISTORY.'  
				COMMIT TRANSACTION;     
			END
			ELSE
			BEGIN  
				PRINT 'ROLLING BACK TRANSACTION fOR ORDERSHISTORY.'  
				ROLLBACK TRANSACTION;     
			END
	END CATCH


END
GO


 
/****** EXEC TEST 1 - Insert new order ******/
USE [Mstore]
GO

DECLARE	@return_value INT,
		@OrderId	INT

EXEC	@return_value = SALES.ispOrders
		@CustomerId = 6,
		@ProductId = 7,
		@UnitsSold = 3,
		@OrderDate = NULL,
		@SalesPersonId = 9,
		@OrderId = @OrderId	OUTPUT

SELECT @OrderId [New OrderId], @return_value [Sproc Return_Value];


/****** EXEC TEST 2 - UPDATE 1 Order ******/
UPDATE [Mstore].[SALES].[Orders]
SET UnitsSold = 2
WHERE OrderId = 1;


/****** EXEC TEST 3 - DELETE 1 Order ******/
DELETE FROM [Mstore].[SALES].[Orders]
WHERE OrderId = 2;


/****** Dsiplay results from TEST 1, 2 and 3 in the Order and Order History ******/
SELECT *  FROM [Mstore].[SALES].[Orders]
WHERE OrderId IN (1,2);

SELECT *  FROM [Mstore].[SALES].[OrdersHistory];

