IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') 
	CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
	WITH ( FORMAT_TYPE = DELIMITEDTEXT ,
	       FORMAT_OPTIONS (
			 FIELD_TERMINATOR = ',',
			 FIRST_ROW = 2,
			 USE_TYPE_DEFAULT = FALSE
			))
GO

IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'adlsnycpayroll-louis-b_louistorageacc1_dfs_core_windows_net') 
	CREATE EXTERNAL DATA SOURCE [adlsnycpayroll-louis-b_louistorageacc1_dfs_core_windows_net] 
	WITH (
		LOCATION = 'abfss://adlsnycpayroll-louis-b@louistorageacc1.dfs.core.windows.net' 
	)
GO

CREATE EXTERNAL TABLE dbo.NYC_Payroll_Data (
	[FiscalYear] bigint,
	[PayrollNumber] bigint,
	[AgencyCode] bigint,
	[AgencyName] nvarchar(400),
	[EmployeeID] bigint,
	[LastName] nvarchar(400),
	[FirstName] nvarchar(400),
	[AgencyStartDate] nvarchar(400),
	[WorkLocationBorough] nvarchar(400),
	[TitleCode] bigint,
	[TitleDescription] nvarchar(400),
	[LeaveStatusasofJune30] nvarchar(400),
	[BaseSalary] float,
	[PayBasis] nvarchar(400),
	[RegularHours] bigint,
	[RegularGrossPaid] float,
	[OTHours] float,
	[TotalOTPaid] float,
	[TotalOtherPay] float
	)
	WITH (
	LOCATION = 'dirpayrollfiles/nycpayroll_2021.csv',
	DATA_SOURCE = [adlsnycpayroll-louis-b_louistorageacc1_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
GO


SELECT TOP 100 * FROM dbo.NYC_Payroll_Data
GO