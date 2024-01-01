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

IF OBJECT_ID('dbo.trip_dimensions') IS NOT NULL
BEGIN
    DROP EXTERNAL TABLE trip_dimensions;
END


CREATE EXTERNAL TABLE dbo.trip_dimensions
WITH (
	LOCATION = 'trip_dimensions_folder',
	DATA_SOURCE = [louisfs_louis_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
AS
SELECT 
    t.trip_id, t.rideable_type, t.started_at, t.ended_at,  
    start_station.name AS start_station_name,
    end_station.name AS end_station_name
FROM dbo.trip AS t
LEFT JOIN dbo.station AS start_station ON t.start_station_id = start_station.station_id
LEFT JOIN dbo.station AS end_station ON t.end_station_id = end_station.station_id;
GO


SELECT TOP 100 * FROM dbo.trip_dimensions
GO