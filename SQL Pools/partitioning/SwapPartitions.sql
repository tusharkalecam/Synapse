/****** Object:  StoredProcedure [dbo].[Partition_load_Stage2]    Script Date: 13/03/2020 14:20:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[Partition_load_Stage2] @hDAY [varchar](12),@SourceSchema [varchar](50),@SourceTbl [varchar](50),@DestSchema [varchar](50),@DestTbl [varchar](50) AS
begin
	declare @sSQLSplitSource varchar(4000);
	declare @sSQLSplitDestination varchar(4000);
	declare @sSQLSwap varchar(4000);
	declare @sSQLStats varchar(4000);
	-- load data into the stage table

	declare @username [varchar](50) ='loaderuser'
	declare @resourceclass [varchar](50) = 'xlargerc'
	declare @dwuc [varchar](50) = '400'

	declare @procname varchar(50) = 'Partition_load_Stage2'

    exec logit @procname,'Start', @username, @resourceclass,  @dwuc


	declare @SourceTablename varchar(50) = '[' + @SourceSchema + '].[' + @SourceTbl + ']'
	declare @DestinationTablename varchar(50) = '[' + @DestSchema + '].[' + @DestTbl + ']'


	-- Step 3 - split the partitions

	-- 3a - find the partition we are loading data from

	declare @sourcePartitionNumber int;
	declare @destPartitionNumber int;
	-- get the partition number we just created above
	 SELECT 
		   @sourcePartitionNumber = prt.[partition_number]
	FROM   sys.schemas sch
		   INNER JOIN sys.tables tbl    ON  sch.schema_id       = tbl.schema_id
		   INNER JOIN sys.partitions prt    ON  prt.[object_id]     = tbl.[object_id]
		   INNER JOIN sys.indexes idx   ON  prt.[object_id]     = idx.[object_id] AND prt.[index_id] = idx.[index_id]
		   INNER JOIN sys.data_spaces               ds  ON  idx.[data_space_id] = ds.[data_space_id]                       
		   INNER JOIN sys.partition_schemes     ps  ON  ds.[data_space_id]  = ps.[data_space_id]                
		   INNER JOIN sys.partition_functions       pf  ON  ps.[function_id]    = pf.[function_id]              
		   LEFT JOIN sys.partition_range_values rng ON  pf.[function_id]    = rng.[function_id] AND rng.[boundary_id] = prt.[partition_number]    
	WHERE      tbl.name = @SourceTbl and sch.name = @SourceSchema  and rng.[value] = @hDAY


	-- 3b - find the partition we are loading data to

	 SELECT 
		   @destPartitionNumber = prt.[partition_number]
	FROM   sys.schemas sch
		   INNER JOIN sys.tables tbl    ON  sch.schema_id       = tbl.schema_id
		   INNER JOIN sys.partitions prt    ON  prt.[object_id]     = tbl.[object_id]
		   INNER JOIN sys.indexes idx   ON  prt.[object_id]     = idx.[object_id] AND prt.[index_id] = idx.[index_id]
		   INNER JOIN sys.data_spaces               ds  ON  idx.[data_space_id] = ds.[data_space_id]                       
		   INNER JOIN sys.partition_schemes     ps  ON  ds.[data_space_id]  = ps.[data_space_id]                
		   INNER JOIN sys.partition_functions       pf  ON  ps.[function_id]    = pf.[function_id]              
		   LEFT JOIN sys.partition_range_values rng ON  pf.[function_id]    = rng.[function_id] AND rng.[boundary_id] = prt.[partition_number]    
	WHERE      tbl.name = @DestTbl and sch.name = @DestSchema and rng.[value] = @hDAY


	-- 3c - Dynamicially move data from the loading partition to the destination partition
	-- move the data from the inserted partition to new table

	set @sSQLSwap = 'ALTER TABLE ' + @SourceTablename + ' SWITCH PARTITION ' +  convert(varchar,@sourcePartitionNumber) + ' TO  ' + @DestinationTablename + ' PARTITION ' + 
		convert(varchar,@destPartitionNumber) + ';'
	print @sSQLSwap
	
	exec logit @procname,'Swap', @username, @resourceclass,  @dwuc
	
	exec (@sSQLSwap)

	exec logit @procname,'Update Stats', @username, @resourceclass,  @dwuc
	-- update the stats of the two tables
	SET @sSQLStats = 'update statistics ' + @SourceTablename + ';'
	exec (@sSQLStats)
	print @sSQLStats

	SET @sSQLStats = 'update statistics ' + @DestinationTablename + ';'
	exec (@sSQLStats)
	print @sSQLStats

	exec logit @procname,'Finish', @username, @resourceclass,  @dwuc
END



