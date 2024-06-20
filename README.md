SSIS example for loading SCD 1,2,6 attributes using AdventureWorks2022 in SQL Server 2022 and

Microsoft Visual Studio Professional 2022 (2) Version 17.10.3 VisualStudio.17.Release/17.10.3+35013.160 Microsoft .NET Framework Version 4.8.09032

Installed Version: Professional

SQL Server Data Tools 17.10.172.0 Microsoft SQL Server Data Tools

SQL Server Integration Services 16.0.5556.0 Microsoft SQL Server Integration Services Designer Version 16.0.5556.0

Uses batch processes instead of row by row used in MS SCD wizard To use:

1) Get AdventureWorks2022 here: https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms
2) Run CreateAdventureWorksDWExtended.sql to create db on local server
3) Run the SetupDatabase.sql script in the solution make sure these two databases are present: AdventureWorksDWExtended and AdventureWorks2022
4) Get the solution Datawarehouse.sln and open
5) Run the setup script in the solution: SetupDatabase.sql
6) Go through the test steps in the teststeps.sql and note the changes that occur in dbo.DimCustomer

Uses batch processes instead of row by row used in MS SCD wizard
