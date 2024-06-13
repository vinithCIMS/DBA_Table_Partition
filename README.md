# DBA_Table_Partition

# **Proof of Concept (POC) Document for Table Partitioning in SQL Server**

## **Introduction**

This document provides a step-by-step guide to implementing table partitioning in SQL Server. The process includes adding filegroups, creating partition functions and schemes, making partitions, viewing partition information, managing future partitions, and migrating partitions to appropriate filegroups.

## **Prerequisites**

- SQL Server Management Studio (SSMS)
- Appropriate permissions to modify the database structure
- A database owner should be **`[sa]`**

## **Steps for Table Partitioning**

### **Step 1: Adding FileGroups and Mapping Files to Database**
First, we need to create new filegroups and map them to corresponding files. Filegroups are logical storage units that simplify database management and improve performance. We will add four filegroups named [VIA_HA_CIMSDEOnsite_OLD], [VIA_HA_CIMSDEOnsite_2021], [VIA_HA_CIMSDEOnsite_2022], and [VIA_HA_CIMSDEOnsite_2023]. Each filegroup will be associated with a separate file on the disk. This ensures that data is distributed across different storage locations for better performance.
Create new filegroups and map them to files based on historical data.

```sql

-- Adding filegroups
ALTER DATABASE [VIA_HA_CIMSDEOnsite] ADD FILEGROUP [VIA_HA_CIMSDEOnsite_OLD];
ALTER DATABASE [VIA_HA_CIMSDEOnsite] ADD FILEGROUP [VIA_HA_CIMSDEOnsite_2021];
ALTER DATABASE [VIA_HA_CIMSDEOnsite] ADD FILEGROUP [VIA_HA_CIMSDEOnsite_2022];
ALTER DATABASE [VIA_HA_CIMSDEOnsite] ADD FILEGROUP [VIA_HA_CIMSDEOnsite_2023];

-- Adding files to the filegroups
ALTER DATABASE [VIA_HA_CIMSDEOnsite] ADD FILE ( NAME = 'VIA_HA_CIMSDEOnsite_OLD', FILENAME = 'W:\Temp\!!POC_Data_Table_Partition\HA_Test_Datafiles\VIA_HA_CIMSDEOnsite_2021.ndf') TO FILEGROUP [VIA_HA_CIMSDEOnsite_OLD];
ALTER DATABASE [VIA_HA_CIMSDEOnsite] ADD FILE ( NAME = 'VIA_HA_CIMSDEOnsite_2021', FILENAME = 'W:\Temp\!!POC_Data_Table_Partition\HA_Test_Datafiles\VIA_HA_CIMSDEOnsite_2021.ndf') TO FILEGROUP [VIA_HA_CIMSDEOnsite_2021];
ALTER DATABASE [VIA_HA_CIMSDEOnsite] ADD FILE ( NAME = 'VIA_HA_CIMSDEOnsite_2022', FILENAME = 'W:\Temp\!!POC_Data_Table_Partition\HA_Test_Datafiles\VIA_HA_CIMSDEOnsite_2022.ndf') TO FILEGROUP [VIA_HA_CIMSDEOnsite_2022];
ALTER DATABASE [VIA_HA_CIMSDEOnsite] ADD FILE ( NAME = 'VIA_HA_CIMSDEOnsite_2023', FILENAME = 'W:\Temp\!!POC_Data_Table_Partition\HA_Test_Datafiles\VIA_HA_CIMSDEOnsite_2023.ndf') TO FILEGROUP [VIA_HA_CIMSDEOnsite_2023];

```

### **Step 2: Creating Partition Function**

Define a partition function based on the date to split data into monthly partitions.
Next, we define a partition function to distribute data across partitions based on a date column. A partition function defines how to map rows of a table or index into partitions. In this example, the partition function [pf_DateMonthly] will create monthly partitions. We specify date ranges to partition data from January 2000 to January 2021 will be on [VIA_HA_CIMSDEOnsite_OLD] and forward years should be year wise datafile . The function uses the RANGE RIGHT option to include the specified date in the higher partition.

```sql

CREATE PARTITION FUNCTION [pf_DateMonthly](datetime)
AS RANGE RIGHT FOR VALUES (
    '2000-01-01','2021-01-01',
	'2021-02-01','2021-03-01', '2021-04-01', '2021-05-01', '2021-06-01','2021-07-01', '2021-08-01', '2021-09-01', '2021-10-01', '2021-11-01','2021-12-01', '2022-01-01',
	'2022-02-01', '2022-03-01', '2022-04-01', '2022-05-01', '2022-06-01','2022-07-01', '2022-08-01', '2022-09-01', '2022-10-01', '2022-11-01', '2022-12-01', '2023-01-01',
	'2023-02-01', '2023-03-01', '2023-04-01', '2023-05-01', '2023-06-01', '2023-07-01', '2023-08-01', '2023-09-01', '2023-10-01', '2023-11-01', '2023-12-01', '2024-01-01'
);

```

### **Step 3: Creating Partition Scheme**

Map the partition function to the filegroups.
After defining the partition function, we create a partition scheme. A partition scheme maps the partitions defined by the partition function to specific filegroups. Here, the partition scheme [ps_DateMonthly] maps the monthly partitions to the filegroups created earlier. Data from the year 2021 is mapped to [VIA_HA_CIMSDEOnsite_2021], data from 2022 to [VIA_HA_CIMSDEOnsite_2022], and data from 2023 to [VIA_HA_CIMSDEOnsite_2023]. Data beyond these ranges is stored in the [PRIMARY] filegroup.

```sql

CREATE PARTITION SCHEME [ps_DateMonthly]
AS PARTITION [pf_DateMonthly]
TO ([PRIMARY],--[Beyond old Data, This Filegroup can't be changed in Future]
	[VIA_HA_CIMSDEOnsite_OLD],
    	[VIA_HA_CIMSDEOnsite_2021], [VIA_HA_CIMSDEOnsite_2021], [VIA_HA_CIMSDEOnsite_2021], [VIA_HA_CIMSDEOnsite_2021],[VIA_HA_CIMSDEOnsite_2021], [VIA_HA_CIMSDEOnsite_2021], [VIA_HA_CIMSDEOnsite_2021], [VIA_HA_CIMSDEOnsite_2021],		[VIA_HA_CIMSDEOnsite_2021],[VIA_HA_CIMSDEOnsite_2021], [VIA_HA_CIMSDEOnsite_2021],[VIA_HA_CIMSDEOnsite_2021],
	[VIA_HA_CIMSDEOnsite_2022], [VIA_HA_CIMSDEOnsite_2022], [VIA_HA_CIMSDEOnsite_2022], [VIA_HA_CIMSDEOnsite_2022],[VIA_HA_CIMSDEOnsite_2022], [VIA_HA_CIMSDEOnsite_2022], [VIA_HA_CIMSDEOnsite_2022], [VIA_HA_CIMSDEOnsite_2022], 		[VIA_HA_CIMSDEOnsite_2022],[VIA_HA_CIMSDEOnsite_2022], [VIA_HA_CIMSDEOnsite_2022],[VIA_HA_CIMSDEOnsite_2022],
	[VIA_HA_CIMSDEOnsite_2023], [VIA_HA_CIMSDEOnsite_2023], [VIA_HA_CIMSDEOnsite_2023], [VIA_HA_CIMSDEOnsite_2023],[VIA_HA_CIMSDEOnsite_2023], [VIA_HA_CIMSDEOnsite_2023], [VIA_HA_CIMSDEOnsite_2023], [VIA_HA_CIMSDEOnsite_2023], 		[VIA_HA_CIMSDEOnsite_2023],[VIA_HA_CIMSDEOnsite_2023], [VIA_HA_CIMSDEOnsite_2023],[VIA_HA_CIMSDEOnsite_2023],
	[PRIMARY]--[Future all Boundaries will be in PRIMARY Datafile]
);

```

### **Step 4: Creating and Applying the Partitioned Index**

Drop the index If existed and create a new partitioned clustered index.

To apply partitioning, we need to create a partitioned index on the table. First, we drop the existing index if it exists to avoid conflicts. Then, we create a new clustered index on the [InsertedTime] column. This index uses the previously defined partition scheme to distribute data across partitions. Partitioned indexes enhance query performance by limiting data scans to relevant partitions.

```sql

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

```

### **Step 5: Viewing Partitioned Table Information**

Retrieve information about the partitioned table.

It's crucial to verify that the table is partitioned correctly. We query system views to retrieve information about the partitioned table. The query provides details like schema name, table name, partition scheme, filegroup, function, and boundary values. This information helps in understanding how data is distributed across partitions. Monitoring partitions ensures that data management goals are being met.

```sql

SELECT
    OBJECT_SCHEMA_NAME(pstats.object_id) AS SchemaName,
    OBJECT_NAME(pstats.object_id) AS TableName,
    ps.name AS PartitionSchemeName,
    ds.name AS PartitionFilegroupName,
    pf.name AS PartitionFunctionName,
    CASE pf.boundary_value_on_right WHEN 0 THEN 'Range Left' ELSE 'Range Right' END AS PartitionFunctionRange,
    CASE pf.boundary_value_on_right WHEN 0 THEN 'Upper Boundary' ELSE 'Lower Boundary' END AS PartitionBoundary,
    prv.value AS PartitionBoundaryValue,
    c.name AS PartitionKey,
    CASE
        WHEN pf.boundary_value_on_right = 0
        THEN c.name + ' > ' + CAST(ISNULL(LAG(prv.value) OVER(PARTITION BY pstats.object_id ORDER BY pstats.object_id, pstats.partition_number), 'Infinity') AS VARCHAR(100)) + ' and ' + c.name + ' <= ' + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100))
        ELSE c.name + ' >= ' + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100))  + ' and ' + c.name + ' < ' + CAST(ISNULL(LEAD(prv.value) OVER(PARTITION BY pstats.object_id ORDER BY pstats.object_id, pstats.partition_number), 'Infinity') AS VARCHAR(100))
    END AS PartitionRange,
    pstats.partition_number AS PartitionNumber,
    pstats.row_count AS PartitionRowCount,
    p.data_compression_desc AS DataCompression
FROM sys.dm_db_partition_stats AS pstats
INNER JOIN sys.partitions AS p ON pstats.partition_id = p.partition_id
INNER JOIN sys.destination_data_spaces AS dds ON pstats.partition_number = dds.destination_id
INNER JOIN sys.data_spaces AS ds ON dds.data_space_id = ds.data_space_id
INNER JOIN sys.partition_schemes AS ps ON dds.partition_scheme_id = ps.data_space_id
INNER JOIN sys.partition_functions AS pf ON ps.function_id = pf.function_id
INNER JOIN sys.indexes AS i ON pstats.object_id = i.object_id AND pstats.index_id = i.index_id AND dds.partition_scheme_id = i.data_space_id AND i.type <= 1 /* Heap or Clustered Index */
INNER JOIN sys.index_columns AS ic ON i.index_id = ic.index_id AND i.object_id = ic.object_id AND ic.partition_ordinal > 0
INNER JOIN sys.columns AS c ON pstats.object_id = c.object_id AND ic.column_id = c.column_id
LEFT JOIN sys.partition_range_values AS prv ON pf.function_id = prv.function_id AND pstats.partition_number = (CASE pf.boundary_value_on_right WHEN 0 THEN prv.boundary_id ELSE (prv.boundary_id+1) END)
WHERE pstats.object_id = OBJECT_ID('VIA_HA_CIMSDEOnsite.dbo.ImportReceiptDetails') --('DB_Name.Schema.Table_Name)
ORDER BY TableName, PartitionNumber;

```

### **Step 6: Install Partition Management Split Procedure**

Before proceeding, ensure that the **`PartitionManagement_Split`** stored procedure is installed in  database.
- [PartitionManagement_Split](https://github.com/vinithCIMS/DBA_Table_Partition/blob/main/6_PartitionManagement_Split.sql)

To manage partitions dynamically, we'll install a stored procedure named PartitionManagement_Split. This procedure facilitates the creation of new partitions based on the specified partition function. It accepts parameters such as the partition function name, target range value, and partition range interval. Installing this procedure provides a convenient way to automate partition management tasks.

### **Step 7: Create Monthly Partitions One Year Forward**

Automatically create monthly partitions for one year into the future.
Now, we'll use the PartitionManagement_Split procedure to create monthly partitions for one year forward from the current date. We specify the partition function name (pf_DateMonthly), the filegroup to create partitions (PRIMARY), and the partition range interval. This step ensures that the table remains optimized for data storage and retrieval by continuously managing partitions.

```sql

DECLARE @FutureValue datetime = DATEADD(year, 1, CONVERT(date, GETDATE())); --Change dynamically if needed
DECLARE @PartitionRangeInterval datetime = DATEADD(dd, 1, 0);

EXEC dbo.[PartitionManagement_Split]
      @PartitionFunctionName = 'pf_DateMonthly' --Mention Partition Function_Name
    , @RoundRobinFileGroups = 'PRIMARY' --Desired Datafile to be creating Partitions
    , @TargetRangeValue = @FutureValue
    , @PartitionIncrementExpression = 'DATEADD(month, 1, CONVERT(datetime, @CurrentRangeValue))' --Increment Expression [Monthly, Quarterly, and Yearly]
    , @PartitionRangeInterval = @PartitionRangeInterval
    , @DebugOnly = 0
    , @AllowDataMovementForColumnstore = 1; -- Enable data movement for non-empty partitions with columnstore

```

### **Step 8: Add Future FileGroup and Mapping Files**

Prepare for future data by adding a new filegroup and mapping files.
Next, we'll add a new filegroup named [VIA_HA_CIMSDEOnsite_2024] to accommodate data for the year 2024. We associate this filegroup with a corresponding file on the disk. By adding filegroups and mapping files based on future data, we ensure seamless data management and performance optimization.

```sql

ALTER DATABASE [VIA_HA_CIMSDEOnsite] ADD FILEGROUP [VIA_HA_CIMSDEOnsite_2024];

ALTER DATABASE [VIA_HA_CIMSDEOnsite] ADD FILE ( NAME = 'VIA_HA_CIMSDEOnsite_2024', FILENAME = 'W:\Temp\!!POC_Data_Table_Partition\HA_Test_Datafiles\VIA_HA_CIMSDEOnsite_2024.ndf') TO FILEGROUP [VIA_HA_CIMSDEOnsite_2024];

```

### **Step 9: Migrating Partitions to Desired Year-Wise FileGroup**

Move partitions from the PRIMARY data file to the old year filegroup.

Finally, we'll migrate partitions from the PRIMARY filegroup to the desired year-wise filegroup ([VIA_HA_CIMSDEOnsite_2024]). This migration involves splitting existing partitions and merging them with the target filegroup. By redistributing partitions, we maintain data integrity and optimize storage utilization based on the data's temporal characteristics.

```sql

-- Migrate each month's partition to the new filegroup
ALTER PARTITION FUNCTION pf_DateMonthly() MERGE RANGE ('2024-01-01');
ALTER PARTITION SCHEME ps_DateMonthly NEXT USED [VIA_HA_CIMSDEOnsite_2024];
ALTER PARTITION FUNCTION pf_DateMonthly() SPLIT RANGE ('2024-01-01');

ALTER PARTITION FUNCTION pf_DateMonthly() MERGE RANGE ('2024-02-01');
ALTER PARTITION SCHEME ps_DateMonthly NEXT USED [VIA_HA_CIMSDEOnsite_2024];
ALTER PARTITION FUNCTION pf_DateMonthly() SPLIT RANGE ('2024-02-01');

ALTER PARTITION FUNCTION pf_DateMonthly() MERGE RANGE ('2024-03-01');
ALTER PARTITION SCHEME ps_DateMonthly NEXT USED [VIA_HA_CIMSDEOnsite_2024];
ALTER PARTITION FUNCTION pf_DateMonthly() SPLIT RANGE ('2024-03-01');

ALTER PARTITION FUNCTION pf_DateMonthly() MERGE RANGE ('2024-04-01');
ALTER PARTITION SCHEME ps_DateMonthly NEXT USED [VIA_HA_CIMSDEOnsite_2024];
ALTER PARTITION FUNCTION pf_DateMonthly() SPLIT RANGE ('2024-04-01');

ALTER PARTITION FUNCTION pf_DateMonthly() MERGE RANGE ('2024-05-01');
ALTER PARTITION SCHEME ps_DateMonthly NEXT USED [VIA_HA_CIMSDEOnsite_2024];
ALTER PARTITION FUNCTION pf_DateMonthly() SPLIT RANGE ('2024-05-01');

ALTER PARTITION FUNCTION pf_DateMonthly() MERGE RANGE ('2024-06-01');
ALTER PARTITION SCHEME ps_DateMonthly NEXT USED [VIA_HA_CIMSDEOnsite_2024];
ALTER PARTITION FUNCTION pf_DateMonthly() SPLIT RANGE ('2024-06-01');

ALTER PARTITION FUNCTION pf_DateMonthly() MERGE RANGE ('2024-07-01');
ALTER PARTITION SCHEME ps_DateMonthly NEXT USED [VIA_HA_CIMSDEOnsite_2024];
ALTER PARTITION FUNCTION pf_DateMonthly() SPLIT RANGE ('2024-07-01');

ALTER PARTITION FUNCTION pf_DateMonthly() MERGE RANGE ('2024-08-01');
ALTER PARTITION SCHEME ps_DateMonthly NEXT USED [VIA_HA_CIMSDEOnsite_2024];
ALTER PARTITION FUNCTION pf_DateMonthly() SPLIT RANGE ('2024-08-01');

ALTER PARTITION FUNCTION pf_DateMonthly() MERGE RANGE ('2024-09-01');
ALTER PARTITION SCHEME ps_DateMonthly NEXT USED [VIA_HA_CIMSDEOnsite_2024];
ALTER PARTITION FUNCTION pf_DateMonthly() SPLIT RANGE ('2024-09-01');

ALTER PARTITION FUNCTION pf_DateMonthly() MERGE RANGE ('2024-10-01');
ALTER PARTITION SCHEME ps_DateMonthly NEXT USED [VIA_HA_CIMSDEOnsite_2024];
ALTER PARTITION FUNCTION pf_DateMonthly() SPLIT RANGE ('2024-10-01');

ALTER PARTITION FUNCTION pf_DateMonthly() MERGE RANGE ('2024-11-01');
ALTER PARTITION SCHEME ps_DateMonthly NEXT USED [VIA_HA_CIMSDEOnsite_2024];
ALTER PARTITION FUNCTION pf_DateMonthly() SPLIT RANGE ('2024-11-01');

ALTER PARTITION FUNCTION pf_DateMonthly() MERGE RANGE ('2024-12-01');
ALTER PARTITION SCHEME ps_DateMonthly NEXT USED [VIA_HA_CIMSDEOnsite_2024];
ALTER PARTITION FUNCTION pf_DateMonthly() SPLIT RANGE ('2024-12-01');

```

## **Conclusion**

By following these steps,  have successfully partitioned  table in SQL Server. This will help in managing and querying large datasets more efficiently. Ensure to periodically review and manage partitions based on  data growth and retention policies.


## Table Partitioning Backout Plan

This outlines step-by-step process to back out the table partitioning setup for the `[dbo].[ImportReceiptDetails]` table in the `[VIA_HA_CIMSDEOnsite]` database. The goal is to revert the table to its original, non-partitioned state, and remove all associated filegroups, files, partition schemes, and functions.

### Step 1: Recreate the Clustered Index on the Primary Filegroup

**Objective:** Move all data back to the primary filegroup by recreating the clustered index on the `InsertedTime` column and ensuring that all rows are located in the primary filegroup.

```sql

CREATE CLUSTERED INDEX [IX_ImportReceiptDetails_Partitioned] -- indexName
    ON [dbo].[ImportReceiptDetails](InsertedTime) -- {TableName}(Partitioned_Column_Name)
    WITH (DROP_EXISTING = ON)
    ON [PRIMARY]; -- All rows should be PRIMARY
GO

```

**Explanation:**

- This command drops the existing partitioned clustered index and recreates it on the `PRIMARY` filegroup.
- The `DROP_EXISTING = ON` option ensures that the current index is dropped and recreated without needing to delete it manually, which helps to reallocate data into the primary filegroup.

### Step 2: Drop the Partition Scheme

**Objective:** Remove the partition scheme `ps_DateMonthly` to disassociate it from the table.

```sql

DROP PARTITION SCHEME ps_DateMonthly;
GO

```

**Explanation:**

- The `DROP PARTITION SCHEME` command removes the partition scheme, ensuring that no tables can use this scheme for partitioning in the future.

### Step 3: Drop the Partition Function

**Objective:** Remove the partition function `pf_DateMonthly` to eliminate the partitioning logic.

```sql

DROP PARTITION FUNCTION pf_DateMonthly;
GO

```

**Explanation:**

- The `DROP PARTITION FUNCTION` command deletes the partition function, effectively removing the range definitions used for partitioning.

### Step 4: Remove Database Files Associated with the Filegroups

**Objective:** Remove the physical files that were associated with the partition-specific filegroups.

```sql

ALTER DATABASE [VIA_HA_CIMSDEOnsite] REMOVE FILE VIA_HA_CIMSDEOnsite_2021;
ALTER DATABASE [VIA_HA_CIMSDEOnsite] REMOVE FILE VIA_HA_CIMSDEOnsite_2022;
ALTER DATABASE [VIA_HA_CIMSDEOnsite] REMOVE FILE VIA_HA_CIMSDEOnsite_2023;
ALTER DATABASE [VIA_HA_CIMSDEOnsite] REMOVE FILE VIA_HA_CIMSDEOnsite_2024;
GO

```

**Explanation:**

- The `REMOVE FILE` command is used to remove the specified data files from the database, which were previously associated with each partition-specific filegroup.

### Step 5: Remove the Filegroups

**Objective:** Remove the filegroups `CIMSDE_2021`, `CIMSDE_2022`, `CIMSDE_2023`, and `CIMSDE_2024` from the database configuration.

```sql

ALTER DATABASE [VIA_HA_CIMSDEOnsite] REMOVE FILEGROUP VIA_HA_CIMSDEOnsite_2021;
ALTER DATABASE [VIA_HA_CIMSDEOnsite] REMOVE FILEGROUP VIA_HA_CIMSDEOnsite_2022;
ALTER DATABASE [VIA_HA_CIMSDEOnsite] REMOVE FILEGROUP VIA_HA_CIMSDEOnsite_2023;
ALTER DATABASE [VIA_HA_CIMSDEOnsite] REMOVE FILEGROUP VIA_HA_CIMSDEOnsite_2024;
GO

```

**Explanation:**

- The `REMOVE FILEGROUP` command deletes the specified filegroups from the database, ensuring that they are no longer available for future use.
