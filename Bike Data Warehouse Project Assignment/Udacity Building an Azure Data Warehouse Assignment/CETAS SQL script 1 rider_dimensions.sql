-- Use the same file format as used for creating the External Tables during the LOAD step.
IF NOT EXISTS (SELECT * FROM sys.external_file_formats WHERE name = 'SynapseDelimitedTextFormat') 
	CREATE EXTERNAL FILE FORMAT [SynapseDelimitedTextFormat] 
	WITH ( FORMAT_TYPE = DELIMITEDTEXT ,
	       FORMAT_OPTIONS (
		FIELD_TERMINATOR = ',',
		FIRST_ROW = 2,
		USE_TYPE_DEFAULT = FALSE
		))
GO

-- Use the same data source as used for creating the External Tables during the LOAD step.
-- Storage path where the result set will persist
IF NOT EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'louisfs_louis_dfs_core_windows_net') 
	CREATE EXTERNAL DATA SOURCE [louisfs_louis_dfs_core_windows_net] 
	WITH (
		LOCATION = 'abfss://louisfs@louis.dfs.core.windows.net' 
	)
GO

IF OBJECT_ID('dbo.rider_dimensions') IS NOT NULL
BEGIN
    DROP EXTERNAL TABLE rider_dimensions;
END


CREATE EXTERNAL TABLE dbo.rider_dimensions
WITH (
	LOCATION = 'rider_dimensions_folder',
	DATA_SOURCE = [louisfs_louis_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
AS
SELECT 
    r.rider_id, r.first, r.last, r.address, r.birthday, r.is_member, r.account_start_date, r.account_end_date, 
	DATEDIFF(year, r.account_start_date, r.birthday) AS age_at_acc_start
FROM dbo.rider AS r;
GO


SELECT TOP 100 * FROM dbo.rider_dimensions
GO


