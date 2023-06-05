/*
File: DQL_DML_Operations_Mstore.sql
Author: Michael Romero

Description: This script creates demonstration samples of Data Query Language (DQL) 
and Data Manipulation Language (DML) executions on database Mstore.

Prerequisite: Execute script CreatingDatabase_Mstore.sql
*/


/* Point to Mstore database */
USE Mstore;

/*  List all the employees that work at Mstore */
SELECT FirstName, LastName FROM HR.Employee;

/*  List all the employees by date hired */
SELECT FirstName, LastName, HiredDate FROM HR.Employee ORDER BY HiredDate;


/*  List 3 most recent the employees hired */
SELECT TOP 3 FirstName, LastName, HiredDate FROM HR.Employee ORDER BY HiredDate DESC;

/*  List average employees salary to 2 decimal places */
SELECT CAST(AVG(Salary) as decimal(10,2)) AS 'AVG SALARY' FROM HR.Employee;

/*  List Department Managers */
SELECT E.EmployeeId, E.FirstName, E.LastName,  (E.FirstName + ' ' + E.LastName) AS "FullName",  D.DepartmentName
FROM 
	HR.Employee E
		INNER JOIN
	HR.Department D
		ON E.DepartmentId = D.DepartmentId;

/*  List Employees and their Department Managers  - using Self join*/
SELECT E.EmployeeId, (E.FirstName + ' ' + E.LastName) AS "EmployeeName", Coalesce((M.FirstName + ' ' + M.LastName), 'Manager') AS "ManagerName"  ---D.DepartmentName
FROM 
	HR.Employee E
		LEFT OUTER JOIN
	HR.Employee M
		ON E.ManagerId = M.EmployeeId;


/*  List Employees and their Department AND Managers  - OUTER AND INNER joins*/
SELECT E.EmployeeId, (E.FirstName + ' ' + E.LastName) AS "EmployeeName", COALESCE((M.FirstName + ' ' + M.LastName), 'Manager') AS "ManagerName", D.DepartmentName
FROM 
	HR.Employee E
		LEFT OUTER JOIN
	HR.Employee M
		ON E.ManagerId = M.EmployeeId
		INNER JOIN
	HR.Department D
		ON E.DepartmentId = D.DepartmentId;



/* List highest paid Employees and non-Manager by department - using CTE and Window function*/
WITH CTE 
AS 
(
    SELECT E.DepartmentId, D.DepartmentName,(E.FirstName + ' ' + E.LastName) AS "EmployeeName", E.Salary,
           DENSE_RANK() OVER(PARTITION BY E.DepartmentId ORDER BY E.Salary DESC) AS RankId
        FROM 
			HR.Employee E
				INNER JOIN
			HR.Department D
				ON E.DepartmentId = D.DepartmentId
		WHERE E.ManagerId <> 0 --FILTER OUT MANAGERS
)
SELECT DepartmentName, EmployeeName, Salary
    FROM CTE
    WHERE RankId = 1;


/* List highest paid salary by department for managers - using aggregation*/
SELECT 
    E.DepartmentId, D.DepartmentName, MAX(E.Salary) [HighestSalary]
FROM
   HR.Department D
   INNER JOIN HR.Employee E on D.DepartmentId = E.DepartmentId
WHERE
	E.ManagerId <> 0  --FILTER OUT MANAGERS
GROUP BY
	E.DepartmentId, D.DepartmentName;



/* Best selling product in 2022 */
WITH CTE
AS
(
SELECT P.ProductId, P.ProductName, SUM(O.UnitsSold) [TotalUnitsSold], MAX(P.UnitPrice) [UnitPrice] , SUM(O.UnitsSold * P.UnitPrice) [TotalSales]
  FROM 
	SALES.Orders O
		INNER JOIN
	PRODUCTION.Product P
		ON O.ProductId = P.ProductId
	WHERE
		YEAR(O.OrderDate) = '2022' 
GROUP BY
	P.ProductId,
	P.ProductName
)
SELECT TOP 1 * FROM CTE ORDER BY TotalSales DESC;



/* Worst selling product in 2022 */
WITH CTE
AS
(
SELECT P.ProductId, P.ProductName, SUM(O.UnitsSold) [TotalUnitsSold], MAX(P.UnitPrice) [UnitPrice] , SUM(O.UnitsSold * P.UnitPrice) [TotalSales]
  FROM 
	SALES.Orders O
		INNER JOIN
	PRODUCTION.Product P
		ON O.ProductId = P.ProductId
	WHERE
		YEAR(O.OrderDate) = '2022' 
GROUP BY
	P.ProductId,
	P.ProductName
)
SELECT TOP 1 * FROM CTE ORDER BY TotalSales ASC;



/* Which Product Category is best selling of all times */
WITH CTE
AS
(
SELECT C.CategoryId,C.CategoryName, SUM(O.UnitsSold) [TotalUnitsSold], MAX(P.UnitPrice) [UnitPrice] , SUM(O.UnitsSold * P.UnitPrice) [TotalSales]
  FROM 
	SALES.Orders O
		INNER JOIN
	PRODUCTION.Product P
		ON O.ProductId = P.ProductId
		INNER JOIN
	PRODUCTION.ProductCategory C
		ON P.CategoryId = C.CategoryId
GROUP BY
	C.CategoryId,
	C.CategoryName
)
SELECT TOP 1 * FROM CTE ORDER BY TotalSales DESC;



/* Best sales person for year 2022 */
SELECT TOP 1 E.EmployeeId,(E.FirstName + ' ' + E.LastName) [EmployeeName] , SUM(O.UnitsSold * P.UnitPrice) [TotalSales]
FROM 
	HR.Employee E 
		INNER JOIN
	SALES.Orders O 
		ON E.EmployeeId = O.SalesPersonId
		INNER JOIN
	PRODUCTION.Product P
		ON O.ProductId = P.ProductId
	WHERE
		YEAR(O.OrderDate) = '2022' 
GROUP BY 
	E.EmployeeId, (E.FirstName + ' ' + E.LastName)
ORDER BY 
	TotalSales DESC;


/* Identify Best Customer by state in 2022*/
WITH CTE
AS
(
SELECT  C.[State], (C.FirstName + ' ' + C.LastName) [EmployeeName] , SUM(O.UnitsSold * P.UnitPrice) [TotalSales],
DENSE_RANK() OVER(PARTITION BY C.[STATE] ORDER BY SUM(O.UnitsSold * P.UnitPrice) DESC) AS RankId
FROM 
	SALES.Customer C 
		INNER JOIN
	SALES.Orders O 
		ON C.CustomerId = O.CustomerId
		INNER JOIN
	PRODUCTION.Product P
		ON O.ProductId = P.ProductId
	WHERE
		YEAR(O.OrderDate) = '2022' 
GROUP BY 
	C.[State], C.CustomerId, (C.FirstName + ' ' + C.LastName)
)	
SELECT * FROM CTE WHERE RankId = 1;



/* Add a new employee - using Select Insert */
INSERT INTO HR.Employee
	SELECT N'Lee', N'Taylor', 2, 2, 65000, N'2022-04-15'

/* Add a 2 new employee - using Union*/
INSERT INTO HR.Employee
	SELECT N'Rachel', N'Kim', 1, 1, 65000, N'2022-04-20'
UNION
	SELECT N'Andre', N'Hansen', 3, 3, 72000, N'2022-04-21';



/* Add a 3 new product */

INSERT [PRODUCTION].[Product] ([ProductName], [CategoryId], [UnitPrice])
VALUES 
	( N'Veggies', 1, 2.99),
	( N'Pie', 1, 8.49),
	( N'Shampoo', 3, 7.59);



/* Add 3 new orders - Output new OrderId */
INSERT [SALES].[Orders] ([CustomerId], [ProductId], [UnitsSold], [OrderDate], [SalesPersonId])
OUTPUT inserted.OrderId
VALUES 
	(1, 1, 4, N'2022-09-01', 5),
	(2, 2, 3, N'2022-09-12', 5),
	(3, 3, 5, N'2022-09-11', 6);




/* Update a single Product to new price */
UPDATE PRODUCTION.Product
	SET UnitPrice = 3.99
	WHERE ProductId = 3;

SELECT * FROM PRODUCTION.Product WHERE ProductId = 3;


/* Discount all frozen food by 20% */

UPDATE PRODUCTION.Product
	SET UnitPrice = UnitPrice - (UnitPrice * 0.20)
	FROM 
		PRODUCTION.Product P
			INNER JOIN
		PRODUCTION.ProductCategory C
			ON P.CategoryId = C.CategoryId
	WHERE
		C.CategoryName = N'Frozen';

SELECT P.*
	FROM 
		PRODUCTION.Product P
			INNER JOIN
		PRODUCTION.ProductCategory C
			ON P.CategoryId = C.CategoryId
	WHERE
		C.CategoryName = N'Frozen';



/* Delete OrderID 7 with verification*/
SELECT * FROM SALES.Orders WHERE OrderId = 7;
DELETE FROM SALES.Orders WHERE OrderId = 7;
SELECT * FROM SALES.Orders WHERE OrderId = 7;


