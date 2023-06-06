# Michael Romero's MSSQL Portfolio

Welcome to my repository.   This repository contains scripts to demonstrate basic MSSQL database commands.  As you review and try these scripts, please note that there are many different ways to accomplish the same tasks as described in these scripts.  My goal here is to show the many favors of MSSQL commands and their implementations.   

## Project MStore
This database is a simplified version of the classic database store.  Start your review by executing script CreatingDatabase_MStore.sql to create and load the sample data.  Try some of the commands listed in script  DQL_DML_Operations_MStore.sql or execute the entire script.  You can vary the commands to test out or try your own.  Mstore is a very simple database in 3NF. MStore_Relational_Diagram.png shows the relationship between tables used in this sample database.  This database will grow with more command and scripting examples with time.  

Script User-defined_Objects_Mstore.sql should be execute in its entire form.  This script creates a view used in UDF that is eventually used in a stored procedure.  This 3-step process could have been accomplished in the stored procedure alone but I wanted to show the creation and integration of User Defined Objects in the Mstore database.

Thank you and enjoy.    
