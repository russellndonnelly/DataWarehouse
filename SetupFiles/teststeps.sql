/*To test LoadSCDtype126example.dtsx do:
--1) Run package to initially load DimCustomer by setting the following:
		Project.params.Reload = True
		In the package LoadSCD126example.dtsx:
			Package Parameters TestSCDProcess = True
		Once the DimCustomer is successfully loaded set Project.params.Reload = False
**************************************************************/
--Run these queries in between successful loads to check successful loads:
/**************************************************************/
SELECT * FROM [AdventureWorksDWExtended].[stage].[DimCustomer]
Where BusinessEntityID_nk in (29484,29485,29486)
Order By BusinessEntityID_nk


SELECT * FROM [AdventureWorksDWExtended].[dbo].[DimCustomer]
Where BusinessEntityID_nk in (29484,29485,29486)
Order By BusinessEntityID_nk, EffectiveDate

SELECT * FROM [AdventureWorksDWExtended].[dbo].[DimCustomer]
Order By BusinessEntityID_nk, EffectiveDate

/**************************************************************/

--3) Updates to test function of SCD. Type 1,2 and 6
/*
UPDATE [AdventureWorksDWExtended].[stage].[DimCustomer]
SET
	Title = 'Mss'
	,MiddleName = 'X'
	,PhoneNumber = '3339991111'
	,ModifiedDate = GetDate()
WHERE BusinessEntityID_nk = '29484';

UPDATE [AdventureWorksDWExtended].[stage].[DimCustomer]
SET
	Title = 'Mss'
	,MiddleName = 'X'
	,PhoneNumber = '2229991111'
	,ModifiedDate = GetDate()
WHERE BusinessEntityID_nk = '29485';

UPDATE [AdventureWorksDWExtended].[stage].[DimCustomer]
SET
	Title = 'Mss'
	,MiddleName = 'X'
	,PhoneNumber = '1119991111'
	,ModifiedDate = GetDate()
WHERE BusinessEntityID_nk = '29486';
**************************************************************/

--4) Type 6 attribute only:
/*
UPDATE [AdventureWorksDWExtended].[stage].[DimCustomer]
SET
	PhoneNumber = '3339990000'
	,ModifiedDate = GetDate()
WHERE BusinessEntityID_nk = '29484'

UPDATE [AdventureWorksDWExtended].[stage].[DimCustomer]
SET
	PhoneNumber = '2229990000'
	,ModifiedDate = GetDate()
WHERE BusinessEntityID_nk = '29485'

UPDATE [AdventureWorksDWExtended].[stage].[DimCustomer]
SET
	PhoneNumber = '1119990000'
	,ModifiedDate = GetDate()
WHERE BusinessEntityID_nk = '29486'
**********************************************************/	

--5) Type 1,2 and 6 again:
/*
UPDATE [AdventureWorksDWExtended].[stage].[DimCustomer]
SET
	Title = 'Msss'
	,PhoneNumber = '3339993333'
	,MiddleName = 'N'
	,ModifiedDate = GetDate()
WHERE BusinessEntityID_nk = '29484';

UPDATE [AdventureWorksDWExtended].[stage].[DimCustomer]
SET
	Title = 'Msss'
	,PhoneNumber = '2229993333'
	,MiddleName = 'N'
	,ModifiedDate = GetDate()
WHERE BusinessEntityID_nk = '29485';

UPDATE [AdventureWorksDWExtended].[stage].[DimCustomer]
SET
	Title = 'Msss'
	,PhoneNumber = '1119993333'
	,MiddleName = 'N'
	,ModifiedDate = GetDate()
WHERE BusinessEntityID_nk = '29486';
**********************************************************/

--5) Type 2 only:
/*
UPDATE [AdventureWorksDWExtended].[stage].[DimCustomer]
SET
	MiddleName = 'N'
	,ModifiedDate = GetDate()
WHERE BusinessEntityID_nk = '29484';

UPDATE [AdventureWorksDWExtended].[stage].[DimCustomer]
SET
	MiddleName = 'Z'
	,ModifiedDate = GetDate()
WHERE BusinessEntityID_nk = '29485';

UPDATE [AdventureWorksDWExtended].[stage].[DimCustomer]
SET
	MiddleName = 'Z'
	,ModifiedDate = GetDate()
WHERE BusinessEntityID_nk = '29486';
**************************************************************/