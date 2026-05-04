-- Simple MS SQL Server Partitioning Example
-- This example demonstrates partitioning a Sales table by OrderDate (yearly partitions)

-- Step 1: Create a partition function
-- This defines the boundary values for partitioning
CREATE PARTITION FUNCTION pf_Sales_OrderDate (datetime)
AS RANGE RIGHT FOR VALUES ('2020-01-01', '2021-01-01', '2022-01-01', '2023-01-01');

-- Step 2: Create a partition scheme
-- This maps partitions to filegroups (using PRIMARY for simplicity)
CREATE PARTITION SCHEME ps_Sales_OrderDate
AS PARTITION pf_Sales_OrderDate
TO (PRIMARY, PRIMARY, PRIMARY, PRIMARY, PRIMARY);

-- Step 3: Create a partitioned table
CREATE TABLE Sales_Partitioned (
    SaleID int IDENTITY(1,1) PRIMARY KEY,
    CustomerID int,
    ProductID int,
    OrderDate datetime,
    Quantity int,
    UnitPrice decimal(10,2),
    TotalAmount AS (Quantity * UnitPrice) PERSISTED
) ON ps_Sales_OrderDate(OrderDate);

-- Step 4: Insert sample data across different years
INSERT INTO Sales_Partitioned (CustomerID, ProductID, OrderDate, Quantity, UnitPrice)
VALUES
    (1, 101, '2019-06-15', 2, 50.00),  -- Before first partition
    (2, 102, '2020-03-20', 1, 75.50),  -- Partition 1
    (3, 103, '2020-11-10', 3, 25.75),  -- Partition 1
    (4, 104, '2021-05-05', 1, 100.00), -- Partition 2
    (5, 105, '2021-12-25', 2, 45.25),  -- Partition 2
    (6, 106, '2022-08-15', 4, 30.00),  -- Partition 3
    (7, 107, '2023-01-10', 1, 80.75),  -- Partition 4
    (8, 108, '2023-09-30', 2, 60.50),  -- Partition 4
    (9, 109, '2024-02-14', 3, 40.25);  -- Partition 5

-- Step 5: Query to see partition information
SELECT
    p.partition_number,
    p.rows,
    prv.value AS boundary_value,
    fg.name AS filegroup_name
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
INNER JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
LEFT JOIN sys.partition_range_values prv ON pf.function_id = prv.function_id AND p.partition_number = prv.boundary_id + CASE WHEN pf.boundary_value_on_right = 1 THEN 1 ELSE 0 END
INNER JOIN sys.filegroups fg ON ps.data_space_id = fg.data_space_id
WHERE OBJECT_NAME(p.object_id) = 'Sales_Partitioned'
ORDER BY p.partition_number;

-- Step 6: Query data from specific partitions
-- Query partition 1 (2020 data)
SELECT * FROM Sales_Partitioned
WHERE $PARTITION.pf_Sales_OrderDate(OrderDate) = 1;

-- Query partition 2 (2021 data)
SELECT * FROM Sales_Partitioned
WHERE $PARTITION.pf_Sales_OrderDate(OrderDate) = 2;

-- Step 7: Switch partitions (advanced example - moving data between partitions)
-- First, create a staging table with the same structure
CREATE TABLE Sales_Staging (
    SaleID int IDENTITY(1,1) PRIMARY KEY,
    CustomerID int,
    ProductID int,
    OrderDate datetime,
    Quantity int,
    UnitPrice decimal(10,2),
    TotalAmount AS (Quantity * UnitPrice) PERSISTED
) ON PRIMARY;

-- Insert data to be moved (example: moving 2020 data to staging)
INSERT INTO Sales_Staging (CustomerID, ProductID, OrderDate, Quantity, UnitPrice)
SELECT CustomerID, ProductID, OrderDate, Quantity, UnitPrice
FROM Sales_Partitioned
WHERE OrderDate >= '2020-01-01' AND OrderDate < '2021-01-01';

-- Switch the partition (this moves the entire partition instantly)
ALTER TABLE Sales_Partitioned SWITCH PARTITION 1 TO Sales_Staging;

-- Clean up example (commented out to avoid accidental execution)
-- DROP TABLE Sales_Partitioned;
-- DROP TABLE Sales_Staging;
-- DROP PARTITION SCHEME ps_Sales_OrderDate;
-- DROP PARTITION FUNCTION pf_Sales_OrderDate;