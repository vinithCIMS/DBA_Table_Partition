# Table Partitioned Document for HA Project

## CIMSDE Database - ImportSKUs Table Partitioning

### Overview

This document outlines the steps taken to partition the `ImportSKUs` table in the `CIMSDE` database based on the `InsertedTime` column. The partitioning strategy involves creating monthly partitions from March 2020 to the current month.

### Steps Followed

1. **Full Database Backup**
    - **Objective**: To have a backout plan in place.
    - **Action**: Taken a full database backup.
    - **Backup Location**: `Z:\cIMS\Production\Database\CIMSDE\BAK\CIMSDE_backup_2024_06_22_201436_7459659.bak`
2. **Row Count and Data Validation**
    - **Objective**: To validate the data before partitioning.
    - **Actions**:
        - **Full Table Row Count**:
            
            ```sql
            
            SELECT COUNT(*) FROM ImportSKUs;
            -- Result: 53119138
            
            ```
    - **Output**:
        |TableName|Row_Count|
        |---|---|
        |ImportSKUs|53119138|

        - **Monthly Data Validation**:
            
            ```sql
            
            SELECT
                YEAR(InsertedTime) AS Year,
                DATENAME(MONTH, InsertedTime) AS Month,
                COUNT(*) AS RecordCount
            FROM
                [dbo].[ImportSKUs]
            GROUP BY
                YEAR(InsertedTime),
                DATENAME(MONTH, InsertedTime),
                MONTH(InsertedTime)
            ORDER BY
                Year,
                MONTH(InsertedTime);
            -- Result: Data available from March 2020 to the current month, matched with 53119138.
            
            ```
      - **Output**:
        |Year|Month|RecordCount|
        |---|---|---|
        |2020|March|74176|
        |2020|April|131658|
        |2020|May|121662|
        |2020|June|17137|
        |2020|July|516|
        |2020|August|19180|
        |2020|September|18629|
        |2020|October|121555|
        |2020|November|86|
        |2020|December|5010|
        |2021|January|64447|
        |2021|February|27641|
        |2021|March|99944|
        |2021|April|137971|
        |2021|May|460857|
        |2021|June|337467|
        |2021|July|360413|
        |2021|August|375155|
        |2021|September|9631620|
        |2021|October|11620688|
        |2021|November|10256346|
        |2021|December|14038635|
        |2022|January|5046602|
        |2022|February|4643|
        |2022|March|5261|
        |2022|April|3467|
        |2022|May|5488|
        |2022|June|8057|
        |2022|July|23805|
        |2022|August|2412|
        |2022|September|2926|
        |2022|October|2666|
        |2022|November|2046|
        |2022|December|3530|
        |2023|January|5529|
        |2023|February|2440|
        |2023|March|5458|
        |2023|April|2960|
        |2023|May|4117|
        |2023|June|6621|
        |2023|July|4964|
        |2023|August|5751|
        |2023|September|5793|
        |2023|October|4560|
        |2023|November|4188|
        |2023|December|4176|
        |2024|January|4885|
        |2024|February|4711|
        |2024|March|3868|
        |2024|April|4947|
        |2024|May|5450|
        |2024|June|7024|

            
3. **Filegroups and Files Creation**
    - **Objective**: To create filegroups and files based on data rows.
    - **Action**: Executed the following procedure:
        
        ```sql
        
        EXEC pr_Partition_CreateFiles 2020, 2024;
        
        ```
  - **Output**:
    |FileGroupName|FileName|UsedSpaceMB|TotalSizeMB|
    |---|---|---|---|
    |CIMSDE_2020|G:\HA\CIMS_Production\Database\CIMSDE_2020.ndf|269.13|328.00|
    |CIMSDE_2021|G:\HA\CIMS_Production\Database\CIMSDE_2021.ndf|24977.44|25032.00|
    |CIMSDE_2022|G:\HA\CIMS_Production\Database\CIMSDE_2022.ndf|2696.13|2760.00|
    |CIMSDE_2023|G:\HA\CIMS_Production\Database\CIMSDE_2023.ndf|30.94|72.00|
    |CIMSDE_2024|G:\HA\CIMS_Production\Database\CIMSDE_2024.ndf|17.13|72.00|
    |CIMSDE_DATA|G:\HA\CIMS_Production\Database\CIMSDE.mdf|507019.69|586080.00|
    |CIMSDE_OLD|G:\HA\CIMS_Production\Database\CIMSDE_OLD.ndf|0.06|8.00|
    |CIMSDE_TLOG|L:\SDI\cIMS\Production\Database\CIMSDE.ldf|169.48|40036.00|
4. **Partition Function and Schema Creation**
    - **Objective**: To create the partition function and partition schema.
    - **Action**: Executed the following procedure:
        
        ```sql
        
        EXEC pr_Partition_CreatePFS_DateMQY 2020, 2024, 'M';
        
        ```
        
    - **SQL Executed**:
        
        ```sql
        
      CREATE PARTITION FUNCTION [pf_DateMonthly](datetime)
      AS RANGE RIGHT FOR VALUES ('2000-01-01',
          '2020-01-01',
      	'2020-02-01','2020-03-01', '2020-04-01', '2020-05-01', '2020-06-01','2020-07-01', '2020-08-01', '2020-09-01', '2020-10-01', '2020-11-01','2020-12-01', '2021-01-01',
      	'2021-02-01','2021-03-01', '2021-04-01', '2021-05-01', '2021-06-01','2021-07-01', '2021-08-01', '2021-09-01', '2021-10-01', '2021-11-01','2021-12-01', '2022-01-01',
      	'2022-02-01', '2022-03-01', '2022-04-01', '2022-05-01', '2022-06-01','2022-07-01', '2022-08-01', '2022-09-01', '2022-10-01', '2022-11-01', '2022-12-01', '2023-01-01',
      	'2023-02-01', '2023-03-01', '2023-04-01', '2023-05-01', '2023-06-01', '2023-07-01', '2023-08-01', '2023-09-01', '2023-10-01', '2023-11-01', '2023-12-01', '2024-01-01',
      	'2024-02-01', '2024-03-01', '2024-04-01', '2024-05-01', '2024-06-01', '2024-07-01', '2024-08-01', '2024-09-01', '2024-10-01', '2024-11-01', '2024-12-01', '2025-01-01'
      );
      
      
      
      
      CREATE PARTITION SCHEME [ps_DateMonthly]
      AS PARTITION [pf_DateMonthly]
      TO ([PRIMARY],--[Beyond old Data, This Filegroup can't be changed in Future]
      	[CIMSDE_OLD],
      	[CIMSDE_2020], [CIMSDE_2020], [CIMSDE_2020], [CIMSDE_2020],[CIMSDE_2020], [CIMSDE_2020], [CIMSDE_2020], [CIMSDE_2020],[CIMSDE_2020],[CIMSDE_2020], [CIMSDE_2020],[CIMSDE_2020],
          [CIMSDE_2021], [CIMSDE_2021], [CIMSDE_2021], [CIMSDE_2021],[CIMSDE_2021], [CIMSDE_2021], [CIMSDE_2021], [CIMSDE_2021],[CIMSDE_2021],[CIMSDE_2021], [CIMSDE_2021],[CIMSDE_2021],
      	[CIMSDE_2022], [CIMSDE_2022], [CIMSDE_2022], [CIMSDE_2022],[CIMSDE_2022], [CIMSDE_2022], [CIMSDE_2022], [CIMSDE_2022],[CIMSDE_2022],[CIMSDE_2022], [CIMSDE_2022],[CIMSDE_2022],
      	[CIMSDE_2023], [CIMSDE_2023], [CIMSDE_2023], [CIMSDE_2023],[CIMSDE_2023], [CIMSDE_2023], [CIMSDE_2023], [CIMSDE_2023],[CIMSDE_2023],[CIMSDE_2023], [CIMSDE_2023],[CIMSDE_2023],
      	[CIMSDE_2024], [CIMSDE_2024], [CIMSDE_2024], [CIMSDE_2024],[CIMSDE_2024], [CIMSDE_2024], [CIMSDE_2024], [CIMSDE_2024],[CIMSDE_2024],[CIMSDE_2024], [CIMSDE_2024],[CIMSDE_2024],
      	[PRIMARY]--[Future all Boundaries will be in PRIMARY Datafile]
      );

        ```
        
5. **Clustered Index Creation**
    - **Objective**: To create a clustered index on the partition scheme.
    - **Actions**:
        - **Drop Existing Index**:
            
            ```sql
            
            IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ImportSKUs_Partitioned' AND object_id = OBJECT_ID('dbo.ImportSKUs'))
            BEGIN
                DROP INDEX ix_ImportSKUs_Partitioned ON [dbo].[ImportSKUs];
            END
            GO
            
            ```
            
        - **Create Clustered Index**:
            
            ```sql
            
            CREATE CLUSTERED INDEX IX_ImportSKUs_Partitioned
            ON [dbo].[ImportSKUs](InsertedTime) -- (schema).(table_Name).(Partitioning_Column_Name)
            ON ps_DateMonthly(InsertedTime); -- Partition_SCHEME_Name(Partitioning_Column_Name)
            GO
            
            ```
            
6. **Data Verification**
    - **Objective**: To verify the rows and data distribution across partitions.
    - **Action**: Executed the following procedure:
        
        ```sql
        
        EXEC pr_Partition_Getinfo 'ImportSKUs';
        
        ```
        
    - **Result**: Verified that monthly partitions and respective year-wise data files are moved as expected.
    - **Output**:
      |SchemaName|TableName|PartitionSchemeName|PartitionFilegroupName|PartitionFunctionName|PartitionFunctionRange|PartitionBoundary|PartitionBoundaryValue|PartitionKey|PartitionRange|PartitionNumber|PartitionRowCount|DataCompression|
      |-----|-----|-----|-----|-----|-----|-----|-----|:-----:|------------------------------------------|:-----:|:-----:|:-----:|
      |dbo|ImportSKUs|ps_DateMonthly|PRIMARY|pf_DateMonthly|Range Right|Lower Boundary|NULL|InsertedTime|InsertedTime &gt;= Infinity and InsertedTime &lt; Jan  1 2000 12:00AM|1|0|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_OLD|pf_DateMonthly|Range Right|Lower Boundary|2000-01-01 00:00:00|InsertedTime|InsertedTime &gt;= Jan  1 2000 12:00AM and InsertedTime &lt; Jan  1 2020 12:00AM|2|0|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2020|pf_DateMonthly|Range Right|Lower Boundary|2020-01-01 00:00:00|InsertedTime|InsertedTime &gt;= Jan  1 2020 12:00AM and InsertedTime &lt; Feb  1 2020 12:00AM|3|0|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2020|pf_DateMonthly|Range Right|Lower Boundary|2020-02-01 00:00:00|InsertedTime|InsertedTime &gt;= Feb  1 2020 12:00AM and InsertedTime &lt; Mar  1 2020 12:00AM|4|0|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2020|pf_DateMonthly|Range Right|Lower Boundary|2020-03-01 00:00:00|InsertedTime|InsertedTime &gt;= Mar  1 2020 12:00AM and InsertedTime &lt; Apr  1 2020 12:00AM|5|74176|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2020|pf_DateMonthly|Range Right|Lower Boundary|2020-04-01 00:00:00|InsertedTime|InsertedTime &gt;= Apr  1 2020 12:00AM and InsertedTime &lt; May  1 2020 12:00AM|6|131658|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2020|pf_DateMonthly|Range Right|Lower Boundary|2020-05-01 00:00:00|InsertedTime|InsertedTime &gt;= May  1 2020 12:00AM and InsertedTime &lt; Jun  1 2020 12:00AM|7|121662|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2020|pf_DateMonthly|Range Right|Lower Boundary|2020-06-01 00:00:00|InsertedTime|InsertedTime &gt;= Jun  1 2020 12:00AM and InsertedTime &lt; Jul  1 2020 12:00AM|8|17137|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2020|pf_DateMonthly|Range Right|Lower Boundary|2020-07-01 00:00:00|InsertedTime|InsertedTime &gt;= Jul  1 2020 12:00AM and InsertedTime &lt; Aug  1 2020 12:00AM|9|516|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2020|pf_DateMonthly|Range Right|Lower Boundary|2020-08-01 00:00:00|InsertedTime|InsertedTime &gt;= Aug  1 2020 12:00AM and InsertedTime &lt; Sep  1 2020 12:00AM|10|19180|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2020|pf_DateMonthly|Range Right|Lower Boundary|2020-09-01 00:00:00|InsertedTime|InsertedTime &gt;= Sep  1 2020 12:00AM and InsertedTime &lt; Oct  1 2020 12:00AM|11|18629|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2020|pf_DateMonthly|Range Right|Lower Boundary|2020-10-01 00:00:00|InsertedTime|InsertedTime &gt;= Oct  1 2020 12:00AM and InsertedTime &lt; Nov  1 2020 12:00AM|12|121555|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2020|pf_DateMonthly|Range Right|Lower Boundary|2020-11-01 00:00:00|InsertedTime|InsertedTime &gt;= Nov  1 2020 12:00AM and InsertedTime &lt; Dec  1 2020 12:00AM|13|86|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2020|pf_DateMonthly|Range Right|Lower Boundary|2020-12-01 00:00:00|InsertedTime|InsertedTime &gt;= Dec  1 2020 12:00AM and InsertedTime &lt; Jan  1 2021 12:00AM|14|5010|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2021|pf_DateMonthly|Range Right|Lower Boundary|2021-01-01 00:00:00|InsertedTime|InsertedTime &gt;= Jan  1 2021 12:00AM and InsertedTime &lt; Feb  1 2021 12:00AM|15|64447|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2021|pf_DateMonthly|Range Right|Lower Boundary|2021-02-01 00:00:00|InsertedTime|InsertedTime &gt;= Feb  1 2021 12:00AM and InsertedTime &lt; Mar  1 2021 12:00AM|16|27641|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2021|pf_DateMonthly|Range Right|Lower Boundary|2021-03-01 00:00:00|InsertedTime|InsertedTime &gt;= Mar  1 2021 12:00AM and InsertedTime &lt; Apr  1 2021 12:00AM|17|99944|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2021|pf_DateMonthly|Range Right|Lower Boundary|2021-04-01 00:00:00|InsertedTime|InsertedTime &gt;= Apr  1 2021 12:00AM and InsertedTime &lt; May  1 2021 12:00AM|18|137971|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2021|pf_DateMonthly|Range Right|Lower Boundary|2021-05-01 00:00:00|InsertedTime|InsertedTime &gt;= May  1 2021 12:00AM and InsertedTime &lt; Jun  1 2021 12:00AM|19|460857|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2021|pf_DateMonthly|Range Right|Lower Boundary|2021-06-01 00:00:00|InsertedTime|InsertedTime &gt;= Jun  1 2021 12:00AM and InsertedTime &lt; Jul  1 2021 12:00AM|20|337467|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2021|pf_DateMonthly|Range Right|Lower Boundary|2021-07-01 00:00:00|InsertedTime|InsertedTime &gt;= Jul  1 2021 12:00AM and InsertedTime &lt; Aug  1 2021 12:00AM|21|360413|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2021|pf_DateMonthly|Range Right|Lower Boundary|2021-08-01 00:00:00|InsertedTime|InsertedTime &gt;= Aug  1 2021 12:00AM and InsertedTime &lt; Sep  1 2021 12:00AM|22|375155|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2021|pf_DateMonthly|Range Right|Lower Boundary|2021-09-01 00:00:00|InsertedTime|InsertedTime &gt;= Sep  1 2021 12:00AM and InsertedTime &lt; Oct  1 2021 12:00AM|23|9631620|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2021|pf_DateMonthly|Range Right|Lower Boundary|2021-10-01 00:00:00|InsertedTime|InsertedTime &gt;= Oct  1 2021 12:00AM and InsertedTime &lt; Nov  1 2021 12:00AM|24|11620688|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2021|pf_DateMonthly|Range Right|Lower Boundary|2021-11-01 00:00:00|InsertedTime|InsertedTime &gt;= Nov  1 2021 12:00AM and InsertedTime &lt; Dec  1 2021 12:00AM|25|10256346|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2021|pf_DateMonthly|Range Right|Lower Boundary|2021-12-01 00:00:00|InsertedTime|InsertedTime &gt;= Dec  1 2021 12:00AM and InsertedTime &lt; Jan  1 2022 12:00AM|26|14038635|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2022|pf_DateMonthly|Range Right|Lower Boundary|2022-01-01 00:00:00|InsertedTime|InsertedTime &gt;= Jan  1 2022 12:00AM and InsertedTime &lt; Feb  1 2022 12:00AM|27|5046602|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2022|pf_DateMonthly|Range Right|Lower Boundary|2022-02-01 00:00:00|InsertedTime|InsertedTime &gt;= Feb  1 2022 12:00AM and InsertedTime &lt; Mar  1 2022 12:00AM|28|4643|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2022|pf_DateMonthly|Range Right|Lower Boundary|2022-03-01 00:00:00|InsertedTime|InsertedTime &gt;= Mar  1 2022 12:00AM and InsertedTime &lt; Apr  1 2022 12:00AM|29|5261|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2022|pf_DateMonthly|Range Right|Lower Boundary|2022-04-01 00:00:00|InsertedTime|InsertedTime &gt;= Apr  1 2022 12:00AM and InsertedTime &lt; May  1 2022 12:00AM|30|3467|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2022|pf_DateMonthly|Range Right|Lower Boundary|2022-05-01 00:00:00|InsertedTime|InsertedTime &gt;= May  1 2022 12:00AM and InsertedTime &lt; Jun  1 2022 12:00AM|31|5488|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2022|pf_DateMonthly|Range Right|Lower Boundary|2022-06-01 00:00:00|InsertedTime|InsertedTime &gt;= Jun  1 2022 12:00AM and InsertedTime &lt; Jul  1 2022 12:00AM|32|8057|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2022|pf_DateMonthly|Range Right|Lower Boundary|2022-07-01 00:00:00|InsertedTime|InsertedTime &gt;= Jul  1 2022 12:00AM and InsertedTime &lt; Aug  1 2022 12:00AM|33|23805|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2022|pf_DateMonthly|Range Right|Lower Boundary|2022-08-01 00:00:00|InsertedTime|InsertedTime &gt;= Aug  1 2022 12:00AM and InsertedTime &lt; Sep  1 2022 12:00AM|34|2412|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2022|pf_DateMonthly|Range Right|Lower Boundary|2022-09-01 00:00:00|InsertedTime|InsertedTime &gt;= Sep  1 2022 12:00AM and InsertedTime &lt; Oct  1 2022 12:00AM|35|2926|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2022|pf_DateMonthly|Range Right|Lower Boundary|2022-10-01 00:00:00|InsertedTime|InsertedTime &gt;= Oct  1 2022 12:00AM and InsertedTime &lt; Nov  1 2022 12:00AM|36|2666|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2022|pf_DateMonthly|Range Right|Lower Boundary|2022-11-01 00:00:00|InsertedTime|InsertedTime &gt;= Nov  1 2022 12:00AM and InsertedTime &lt; Dec  1 2022 12:00AM|37|2046|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2022|pf_DateMonthly|Range Right|Lower Boundary|2022-12-01 00:00:00|InsertedTime|InsertedTime &gt;= Dec  1 2022 12:00AM and InsertedTime &lt; Jan  1 2023 12:00AM|38|3530|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2023|pf_DateMonthly|Range Right|Lower Boundary|2023-01-01 00:00:00|InsertedTime|InsertedTime &gt;= Jan  1 2023 12:00AM and InsertedTime &lt; Feb  1 2023 12:00AM|39|5529|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2023|pf_DateMonthly|Range Right|Lower Boundary|2023-02-01 00:00:00|InsertedTime|InsertedTime &gt;= Feb  1 2023 12:00AM and InsertedTime &lt; Mar  1 2023 12:00AM|40|2440|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2023|pf_DateMonthly|Range Right|Lower Boundary|2023-03-01 00:00:00|InsertedTime|InsertedTime &gt;= Mar  1 2023 12:00AM and InsertedTime &lt; Apr  1 2023 12:00AM|41|5458|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2023|pf_DateMonthly|Range Right|Lower Boundary|2023-04-01 00:00:00|InsertedTime|InsertedTime &gt;= Apr  1 2023 12:00AM and InsertedTime &lt; May  1 2023 12:00AM|42|2960|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2023|pf_DateMonthly|Range Right|Lower Boundary|2023-05-01 00:00:00|InsertedTime|InsertedTime &gt;= May  1 2023 12:00AM and InsertedTime &lt; Jun  1 2023 12:00AM|43|4117|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2023|pf_DateMonthly|Range Right|Lower Boundary|2023-06-01 00:00:00|InsertedTime|InsertedTime &gt;= Jun  1 2023 12:00AM and InsertedTime &lt; Jul  1 2023 12:00AM|44|6621|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2023|pf_DateMonthly|Range Right|Lower Boundary|2023-07-01 00:00:00|InsertedTime|InsertedTime &gt;= Jul  1 2023 12:00AM and InsertedTime &lt; Aug  1 2023 12:00AM|45|4964|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2023|pf_DateMonthly|Range Right|Lower Boundary|2023-08-01 00:00:00|InsertedTime|InsertedTime &gt;= Aug  1 2023 12:00AM and InsertedTime &lt; Sep  1 2023 12:00AM|46|5751|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2023|pf_DateMonthly|Range Right|Lower Boundary|2023-09-01 00:00:00|InsertedTime|InsertedTime &gt;= Sep  1 2023 12:00AM and InsertedTime &lt; Oct  1 2023 12:00AM|47|5793|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2023|pf_DateMonthly|Range Right|Lower Boundary|2023-10-01 00:00:00|InsertedTime|InsertedTime &gt;= Oct  1 2023 12:00AM and InsertedTime &lt; Nov  1 2023 12:00AM|48|4560|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2023|pf_DateMonthly|Range Right|Lower Boundary|2023-11-01 00:00:00|InsertedTime|InsertedTime &gt;= Nov  1 2023 12:00AM and InsertedTime &lt; Dec  1 2023 12:00AM|49|4188|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2023|pf_DateMonthly|Range Right|Lower Boundary|2023-12-01 00:00:00|InsertedTime|InsertedTime &gt;= Dec  1 2023 12:00AM and InsertedTime &lt; Jan  1 2024 12:00AM|50|4176|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2024|pf_DateMonthly|Range Right|Lower Boundary|2024-01-01 00:00:00|InsertedTime|InsertedTime &gt;= Jan  1 2024 12:00AM and InsertedTime &lt; Feb  1 2024 12:00AM|51|4885|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2024|pf_DateMonthly|Range Right|Lower Boundary|2024-02-01 00:00:00|InsertedTime|InsertedTime &gt;= Feb  1 2024 12:00AM and InsertedTime &lt; Mar  1 2024 12:00AM|52|4711|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2024|pf_DateMonthly|Range Right|Lower Boundary|2024-03-01 00:00:00|InsertedTime|InsertedTime &gt;= Mar  1 2024 12:00AM and InsertedTime &lt; Apr  1 2024 12:00AM|53|3868|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2024|pf_DateMonthly|Range Right|Lower Boundary|2024-04-01 00:00:00|InsertedTime|InsertedTime &gt;= Apr  1 2024 12:00AM and InsertedTime &lt; May  1 2024 12:00AM|54|4947|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2024|pf_DateMonthly|Range Right|Lower Boundary|2024-05-01 00:00:00|InsertedTime|InsertedTime &gt;= May  1 2024 12:00AM and InsertedTime &lt; Jun  1 2024 12:00AM|55|5450|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2024|pf_DateMonthly|Range Right|Lower Boundary|2024-06-01 00:00:00|InsertedTime|InsertedTime &gt;= Jun  1 2024 12:00AM and InsertedTime &lt; Jul  1 2024 12:00AM|56|7024|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2024|pf_DateMonthly|Range Right|Lower Boundary|2024-07-01 00:00:00|InsertedTime|InsertedTime &gt;= Jul  1 2024 12:00AM and InsertedTime &lt; Aug  1 2024 12:00AM|57|0|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2024|pf_DateMonthly|Range Right|Lower Boundary|2024-08-01 00:00:00|InsertedTime|InsertedTime &gt;= Aug  1 2024 12:00AM and InsertedTime &lt; Sep  1 2024 12:00AM|58|0|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2024|pf_DateMonthly|Range Right|Lower Boundary|2024-09-01 00:00:00|InsertedTime|InsertedTime &gt;= Sep  1 2024 12:00AM and InsertedTime &lt; Oct  1 2024 12:00AM|59|0|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2024|pf_DateMonthly|Range Right|Lower Boundary|2024-10-01 00:00:00|InsertedTime|InsertedTime &gt;= Oct  1 2024 12:00AM and InsertedTime &lt; Nov  1 2024 12:00AM|60|0|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2024|pf_DateMonthly|Range Right|Lower Boundary|2024-11-01 00:00:00|InsertedTime|InsertedTime &gt;= Nov  1 2024 12:00AM and InsertedTime &lt; Dec  1 2024 12:00AM|61|0|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|CIMSDE_2024|pf_DateMonthly|Range Right|Lower Boundary|2024-12-01 00:00:00|InsertedTime|InsertedTime &gt;= Dec  1 2024 12:00AM and InsertedTime &lt; Jan  1 2025 12:00AM|62|0|NONE|
      |dbo|ImportSKUs|ps_DateMonthly|PRIMARY|pf_DateMonthly|Range Right|Lower Boundary|2025-01-01 00:00:00|InsertedTime|InsertedTime &gt;= Jan  1 2025 12:00AM and InsertedTime &lt; Infinity|63|0|NONE|

### Conclusion

The `ImportSKUs` table has been successfully partitioned by the `InsertedTime` column into monthly partitions from March 2020 to the current month. All steps, including backup, data validation, filegroup creation, partition function and schema creation, clustered index creation, and data verification, were completed successfully.
