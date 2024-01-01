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

IF OBJECT_ID('dbo.trip_facts') IS NOT NULL
BEGIN
    DROP EXTERNAL TABLE trip_facts;
END


CREATE EXTERNAL TABLE dbo.trip_facts
WITH (
	LOCATION = 'trip_facts_folder',
	DATA_SOURCE = [louisfs_louis_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
AS
SELECT 
    t.trip_id,
	TO_CHAR(t.started_at :: DATE, 'YYYYMMDDHH')::integer AS started_at_date_id,
	TO_CHAR(t.ended_at :: DATE, 'YYYYMMDDHH')::integer AS ended_at_date_id,
	t.start_station_id,
	t.end_station_id, 
	t.rider_id,
	DATEDIFF(YEAR, t.started_at, r.birthday) AS rider_age, 
	DATEDIFF(HOUR, t.ended_at, t.started_at) AS trip_duration
FROM dbo.trip AS t 
JOIN dbo.rider AS r ON t.rider_id = r.rider_id;
GO

SELECT TOP 100 * FROM dbo.trip_facts
GO


