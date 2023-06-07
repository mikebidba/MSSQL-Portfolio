# Michael Romero's MSSQL Portfolio

Welcome to my repository.   This repository contains scripts to demonstrate basic MSSQL database commands.  As you review and try these scripts, please note that there are many different ways to accomplish the same tasks as described in these scripts.  My goal here is to show the many favors of MSSQL commands and their implementations.   

## Project MStore
This database is a simplified version of the classic database store.  Start your review by executing script CreatingDatabase_MStore.sql to create and load the sample data.  Try some of the commands listed in script  DQL_DML_Operations_MStore.sql or execute the entire script.  You can vary the commands to test out or try your own.  Mstore is a very simple database in 3NF. MStore_Relational_Diagram.png shows the relationship between tables used in this sample database.  This database will grow with more command and scripting examples with time.  

Script User-defined_Objects_Mstore.sql should be execute in its entire form.  This script creates a view used in UDF that is eventually used in a stored procedure.  This 3-step process could have been accomplished in the stored procedure alone but I wanted to show the creation and integration of User Defined Objects in the Mstore database.

Script AuditLogging_WithTrigger_Mstore.sql demonstrates trigger usage on database Mstore.  The stored procedure for SALES.ispOrders will insert new orders. Trigger SALES.trgOrdersHistory will add order operations to SALES.OrdersHistory.  SALES.OrdersHistory includes a hashing column that can be used later to verify the data entry integrity against manual data alteration. Please execute the first 4 object in order 1 through 4. After these required executions you can run any of the 3 EXEC TESTs or any testing of your own.

Thank you and enjoy.    
