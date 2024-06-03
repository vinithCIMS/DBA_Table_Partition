
DECLARE @FutureValue datetime = DATEADD(year, 1, CONVERT(date, GETDATE())); --Change dynamically if needed
DECLARE @PartitionRangeInterval datetime = DATEADD(dd, 1, 0);

EXEC dbo.[PartitionManagement_Split]
      @PartitionFunctionName = 'pf_DateMonthly', --Mention Partition Function_Name
    , @RoundRobinFileGroups = 'PRIMARY', --Desired Datafile to be creating Partitions
    , @TargetRangeValue = @FutureValue,
    , @PartitionIncrementExpression = 'DATEADD(month, 1, CONVERT(datetime, @CurrentRangeValue))', --Increment Expression [Monthly, Quarterly, and Yearly]
    , @PartitionRangeInterval = @PartitionRangeInterval,
    , @DebugOnly = 0,
    , @AllowDataMovementForColumnstore = 1; -- Enable data movement for non-empty partitions with columnstore
