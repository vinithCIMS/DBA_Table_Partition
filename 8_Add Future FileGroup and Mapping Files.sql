
ALTER DATABASE [VIA_HA_CIMSDEOnsite] ADD FILEGROUP [CIMSDE_2024];

ALTER DATABASE [VIA_HA_CIMSDEOnsite] ADD FILE ( NAME = 'CIMSDE_2024', FILENAME = 'W:\Temp\!!POC_Data_Table_Partition\HA_Test_Datafiles\CIMSDE_2024.ndf') TO FILEGROUP [CIMSDE_2024];
