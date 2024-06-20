/**************************************
Purpose:	Sets up database (AdventureWorksDWExtended), tables and functions.
			Needs AdventureWorks2022 database
**************************************/

USE [AdventureWorksDWExtended]
GO

/********************************************************************************************************/
--create stage schema
IF NOT EXISTS ( SELECT * FROM sys.schemas WHERE name = N'Demo' )
	EXEC('CREATE SCHEMA [Demo] AUTHORIZATION [dbo]');
GO

/****** Object:  Table [dbo].[sysssislog] ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sysssislog]') AND type in (N'U'))
DROP TABLE [dbo].[sysssislog]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sysssislog]
(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[event] [sysname] NOT NULL,
	[computer] [nvarchar](128) NOT NULL,
	[operator] [nvarchar](128) NOT NULL,
	[source] [nvarchar](1024) NOT NULL,
	[sourceid] [uniqueidentifier] NOT NULL,
	[executionid] [uniqueidentifier] NOT NULL,
	[starttime] [datetime] NOT NULL,
	[endtime] [datetime] NOT NULL,
	[datacode] [int] NOT NULL,
	[databytes] [image] NULL,
	[message] [nvarchar](2048) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


/********************************************************************************************************/
/****** Object:  Table [dbo].[Audit]    Script Date: 6/6/2024 11:56:12 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Audit]') AND type in (N'U'))
DROP TABLE [dbo].[Audit]
GO

/****** Object:  Table [dbo].[Audit]    Script Date: 6/6/2024 11:56:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Audit]
(
	[AuditId] [int] IDENTITY(1,1) NOT NULL,
	[PackageName] [varchar](200) NULL,
	[TableName] [varchar](200) NULL,
	[Status] [varchar](25) NULL,
	[StartDateTime] [datetime] NULL,
	[EndDateTime] [datetime] NULL,
	[ElapsedTimeHHMMSS] [time](7) NULL,
	[RowCount] [int] NULL,
	[RowsPerMinute] [float] NULL,
	[Note] [varchar] (max) NULL,
 CONSTRAINT [PK_AuditKey] PRIMARY KEY CLUSTERED 
(
	[AuditId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


/********************************************************************************************************/
/****** Object:  StoredProcedure [dbo].[AuditCreateRow] ******/
DROP PROCEDURE IF EXISTS [dbo].[AuditCreateRow]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[AuditCreateRow]
	@TableName varchar(200),
	@PackageName varchar(200),
	@Status as varchar(25) = 'Running',
	@AuditId INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	--Insert a new record into the [Audit] table and return the AuditKey that was generated
    INSERT INTO [dbo].[Audit]
           (
		   [TableName]
		   ,[PackageName]
           --,[ChangeTracking_VersionNumber]
           ,[Status]
           ,[StartDateTime]
           ,[EndDateTime]
		   ,[ElapsedTimehhmmss]
           ,[RowCount]
		   )
     VALUES
	(
		@TableName
		,@PackageName
		--,NULL
		,'Running'
		,getdate()
		,NULL
		,NULL
		,0
	)
	
	Select @AuditId = SCOPE_IDENTITY();
END
GO

/********************************************************************************************************/
/****** Object:  StoredProcedure [dbo].[AuditUpdateRow] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE  IF EXISTS [dbo].[AuditUpdateRow]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AuditUpdateRow]
	@AuditId as int,
	@Status as varchar(25) = 'Running',
	@RowCount as int
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @EndDateTime as datetime = getdate();
	Declare @ConcatenatedString as varchar(max);

	IF @Status = 'Error'
	SELECT
		@ConcatenatedString =
		(
			SELECT 
			STUFF((
				SELECT TOP 3 CHAR(13) + CHAR(10) + ', ' + '//SOURCE:' +  Convert(varchar(1024),[source]) + ';SOURCEID:' + Convert(varchar(36),[sourceid]) + ';DATACODE:' + Convert(varchar(100),[datacode]) + ';MESSAGE:' + Convert(varchar(2048),[message])
				FROM [dbo].[sysssislog]
				Where 
					event = 'OnError'
				Order By id desc
				FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)'), 1, 2, '')
		)
	ELSE
		Set @ConcatenatedString = ''

    Update [dbo].[Audit]
	Set
		--[ChangeTracking_VersionNumber]
		[Status] = @Status
		,[EndDateTime] = @EndDateTime
		,[ElapsedTimeHHMMSS] = Convert(time(7),convert(varchar(5),DateDiff(s, [StartDateTime], @EndDateTime)/3600)+
								':'+convert(varchar(5),DateDiff(s, [StartDateTime], @EndDateTime)%3600/60)+
								':'+convert(varchar(5),(DateDiff(s, [StartDateTime], @EndDateTime)%60)))
		,[RowCount] = @RowCount
		,[RowsPerMinute] = 
			Case 
				(
					DATEDIFF(SECOND, [StartDateTime], @EndDateTime) + 
					(
						CAST(DATEPART(MILLISECOND, @EndDateTime) AS decimal(10,3)) - CAST(DATEPART(MILLISECOND, [StartDateTime]) AS decimal(10,3))
					)/1000.0
				)*60
			When 0 Then 0		--numerator is zero
			Else
			@RowCount/
				(
					DATEDIFF(SECOND, [StartDateTime], @EndDateTime) + 
					(
						CAST(DATEPART(MILLISECOND, @EndDateTime) AS decimal(10,3)) - CAST(DATEPART(MILLISECOND, [StartDateTime]) AS decimal(10,3))
					)/1000.0
				)*60
			End
		,[Note]= @ConcatenatedString
	Where AuditId = @AuditId
END
GO

/********************Recreates staging table for dimension load******************************************/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[stage].[DimCustomer]') AND type in (N'U'))
	DROP TABLE [stage].[DimCustomer]
GO

/****** Object:  Table [stage].[DimCustomer]    Script Date: 6/6/2024 11:57:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stage].[DimCustomer]
(
	[BusinessEntityID_nk] [int] NOT NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[PhoneNumber] [nvarchar](25) NULL,
	[PhoneType] [nvarchar](50) NULL,
    [ModifiedDate] [datetime] NULL
) ON [PRIMARY]
GO



/****** recreate [dbo].[DimCustomer]******************************************************************/
USE [AdventureWorksDWExtended]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DimCustomer]') AND type in (N'U'))
DROP TABLE [dbo].[DimCustomer]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DimCustomer]
(
	[CustomerID_sk] [int] IDENTITY(1,1) NOT NULL,
	[BusinessEntityID_nk] [int] NOT NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](50) NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[PhoneNumber_curr] [nvarchar](25) NULL,		--current phone number (type 3 or 6)
	[PhoneNumber_prev] [nvarchar](25) NULL,		--previous phone number (type 3 or 6)
	[PhoneType] [nvarchar](50) NULL,
	[EffectiveDate] [datetime] NULL,			--effective date for the row (type 2, 1 day plus expiration date of previous historical row)
	[ExpirationDate] [datetime] NULL,			--expiration date for the row (type 2, 1 day minus effective date of next historical row)
	[DateInserted] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[IsCurrentRow] [bit] NULL
) ON [PRIMARY]
GO

/**************************************************************************************************
Purpose:	Source to insert rows in stage table from source, normally new or updated records
			For demo/template, rows are from AdventureWorks2022 tables
			Replace with any source table and ideally a filter to find new records and eliminate processed records
**************************************************************************************************/
USE AdventureWorks2022

Select
	CustomerID as 'BusinessEntityID_nk'
	,IsNull(pers.Title,'N/A') as 'Title'
	,FirstName
	,IsNull(pers.MiddleName,'Unavailable') as 'MiddleName'
	,LastName
	,Convert(nvarchar(25),dbo.ufnRemoveAllNonNumericCharacters(PhoneNumber)) as PhoneNumber
	,pht.Name as 'PhoneType'
	,GREATEST
		(	
			Convert(date,cust.ModifiedDate)
			,Convert(date,pht.ModifiedDate)
			,Convert(date,pers.ModifiedDate)
			,Convert(date,pho.ModifiedDate)
		)  as ModifiedDate
From [Person].[Person] as pers
Inner Join [Sales].[Customer] as cust
	On pers.BusinessEntityID = cust.PersonID
Left Join [Person].[PersonPhone] as pho
	On pers.BusinessEntityID = pho.BusinessEntityID
Left Join [Person].[PhoneNumberType] as pht
	On pho.PhoneNumberTypeID = pht.PhoneNumberTypeID
Where pers.PersonType != 'EM'


/***********************************UserDefinedFunction [dbo].[ufnRemoveAllNonNumericCharacters]******/
USE [AdventureWorks2022]
GO

DROP FUNCTION [dbo].[ufnRemoveAllNonNumericCharacters]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE Function [dbo].[ufnRemoveAllNonNumericCharacters]
(@strInput NVARCHAR(max))
RETURNS NVARCHAR(max)
AS
--returns string with all non numeric characters removed from @strInput
BEGIN
    While PatIndex('%[^0-9]%', @strInput) > 0
        Set @strInput = Stuff(@strInput, PatIndex('%[^0-9]%', @strInput), 1, '')
    RETURN @strInput
END
GO