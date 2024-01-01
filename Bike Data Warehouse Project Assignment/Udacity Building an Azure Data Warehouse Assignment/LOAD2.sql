IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') 
	CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
	WITH ( FORMAT_TYPE = DELIMITEDTEXT ,
	       FORMAT_OPTIONS (
			 FIELD_TERMINATOR = ',',
			 FIRST_ROW = 2,
			 USE_TYPE_DEFAULT = FALSE
			))
GO

IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'louisfs_louis_dfs_core_windows_net') 
	CREATE EXTERNAL DATA SOURCE [louisfs_louis_dfs_core_windows_net] 
	WITH (
		LOCATION = 'abfss://louisfs@louis.dfs.core.windows.net' 
	)
GO

CREATE EXTERNAL TABLE dbo.payment (
	[payment_id] bigint,
	[date] VARCHAR(50),
	[amount] float,
	[rider_id] bigint
	)
	WITH (
	LOCATION = 'publicpayment.txt',
	DATA_SOURCE = [louisfs_louis_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
GO


SELECT TOP 100 * FROM dbo.payment
GO