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

IF OBJECT_ID('dbo.station_dimensions') IS NOT NULL
BEGIN
    DROP EXTERNAL TABLE station_dimensions;
END


CREATE EXTERNAL TABLE dbo.station_dimensions
WITH (
	LOCATION = 'station_dimensions_folder',
	DATA_SOURCE = [louisfs_louis_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
AS
SELECT 
    s.station_id, s.name
FROM dbo.station AS s
GO


SELECT TOP 100 * FROM dbo.paydate_dimensions
GO


