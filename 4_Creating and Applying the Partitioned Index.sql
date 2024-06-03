
-- Drop the index if it exists
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ImportReceiptDetails_Partitioned' AND object_id = OBJECT_ID('dbo.ImportReceiptDetails'))
BEGIN
    DROP INDEX IX_ImportReceiptDetails_Partitioned ON [dbo].[ImportReceiptDetails];
END
GO

-- Create the clustered index on the partition scheme
CREATE CLUSTERED INDEX IX_ImportReceiptDetails_Partitioned
ON [dbo].[ImportReceiptDetails](InsertedTime) --[(schema).(table_Name).(Partitioning_Column_Name)]
ON ps_DateMonthly(InsertedTime);--Partition_SCHEME_Name(Partitioning_Column_Name)
GO
