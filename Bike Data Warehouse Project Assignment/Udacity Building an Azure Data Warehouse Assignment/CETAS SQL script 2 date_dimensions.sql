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

IF OBJECT_ID('dbo.date_dimensions') IS NOT NULL
BEGIN
    DROP EXTERNAL TABLE date_dimensions;
END


CREATE EXTERNAL TABLE dbo.date_dimensions
WITH (
	LOCATION = 'date_dimensions_folder',
	DATA_SOURCE = [louisfs_louis_dfs_core_windows_net],
	FILE_FORMAT = [SynapseDelimitedTextFormat]
	)
AS
SELECT 
    DISTINCT TO_CHAR(t.started_at :: DATE, 'YYYYMMDDHH')::integer AS date_id,
    EXTRACT(YEAR FROM t.started_at) AS year,
	EXTRACT(QUARTER FROM t.started_at) AS quarter,
	EXTRACT(MONTH FROM t.started_at) AS month,
	EXTRACT(WEEK FROM t.started_at) AS week,
	EXTRACT(DAY FROM t.started_at) AS day,
	CASE WHEN EXTRACT(ISODOW FROM t.started_at) IN (6, 7) THEN true ELSE false END AS is_weekend,
	EXTRACT(HOUR FROM t.started_at) AS hour
FROM dbo.trip AS t

UNION

SELECT 
    DISTINCT TO_CHAR(t.ended_at :: DATE, 'YYYYMMDDHH')::integer AS date_id,
    EXTRACT(YEAR FROM t.ended_at) AS year,
	EXTRACT(QUARTER FROM t.ended_at) AS quarter,
	EXTRACT(MONTH FROM t.ended_at) AS month,
	EXTRACT(WEEK FROM t.ended_at) AS week,
	EXTRACT(DAY FROM t.ended_at) AS day,
	CASE WHEN EXTRACT(ISODOW FROM t.ended_at) IN (6, 7) THEN true ELSE false END AS is_weekend,
	EXTRACT(HOUR FROM t.ended_at) AS hour
FROM dbo.trip AS t

UNION

SELECT 
    DISTINCT TO_CHAR(p.date :: DATE, 'YYYYMMDD')::integer AS date_id,
    EXTRACT(YEAR FROM p.date) AS year,
	EXTRACT(QUARTER FROM p.date) AS quarter,
	EXTRACT(MONTH FROM p.date) AS month,
	EXTRACT(WEEK FROM p.date) AS week,
	EXTRACT(DAY FROM p.date) AS day,
	CASE WHEN EXTRACT(ISODOW FROM p.date) IN (6, 7) THEN true ELSE false END AS is_weekend,
	NULL AS hour
FROM dbo.payment AS p;

GO


SELECT TOP 100 * FROM dbo.tripdate_dimensions
GO


