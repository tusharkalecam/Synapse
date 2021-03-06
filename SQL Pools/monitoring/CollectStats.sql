
CREATE PROC [monitoring].[CollectStats] @setupmode [int] AS
BEGIN
    SET NOCOUNT ON
/*
Usage: 
exec [monitoring].[CollectStats]  1 -- this creates the monitoring tables.
exec [monitoring].[CollectStats]  0 -- this populates the monitoring tables
exec [monitoring].[CollectStats]  2 -- creates views
*/	
	--declare @setupmode int = 1;

	-- Can't remember why I added the batches for the views, so we could see the latest import.
	declare @processdate datetime2 = getdate();
	declare @batchid int;

	if @setupmode = 1
		BEGIN
		IF OBJECT_ID('monitoring.[batches]') IS NOT NULL
		BEGIN;
			DROP TABLE monitoring.[batches] 
		END;

		create table monitoring.[batches] 
		(
		batchid int,
		sysdate datetime2
		)
		with	( distribution = round_robin, HEAP)

		insert into  monitoring.[batches]  values (0,@processdate);
	END
	

	if @setupmode = 0
	begin

	set @batchid  = (select max(batchid) + 1 from monitoring.[batches]);

	insert into  monitoring.[batches]  values (
		@batchid
		,@processdate);

	end

	IF OBJECT_ID('tempdb..#loop_ddl') IS NOT NULL
	  BEGIN;
		DROP TABLE #loop_ddl;
	  END;

	CREATE TABLE #loop_ddl
	WITH
	(
		DISTRIBUTION   = round_robin
	)
	AS 
	select  description,
			dmv_name, 
			where_clause, 
			database_type,
			[enabled],
			storage, 
			ROW_NUMBER() OVER (ORDER BY (SELECT NULL))    AS [seq_nmbr] 
	from monitoring.control where [enabled] = 1


	DECLARE
		@i INT = 1
		, @t INT = (SELECT COUNT(*) FROM #loop_ddl)
		, @statement NVARCHAR(4000)   = N''
		, @dmv_name NVARCHAR(200) = N''
		, @setup_sql NVARCHAR(4000) = N''
		, @insert_sql NVARCHAR(4000) = N''
		, @view_sql_drop  NVARCHAR(4000) = N''
		, @view_sql_create  NVARCHAR(4000) = N''
		, @storage NVARCHAR(50) = N''
		, @where_clause NVARCHAR(4000) = N'';

	WHILE @i <= @t
	  BEGIN
		SELECT @dmv_name = dmv_name, @storage=storage, @where_clause = where_clause FROM #loop_ddl WHERE seq_nmbr = @i;


		set @statement = 'SELECT * FROM sys.' + @dmv_name
		SET @setup_sql = ''
		set @insert_sql = ''

		SET @setup_sql = '
			IF OBJECT_ID(''monitoring.[' + @dmv_name + ']'') IS NOT NULL
			BEGIN;
				DROP table monitoring.[' + @dmv_name + '];
		   END;
		   '
		if len(@where_clause ) > 0 
		BEGIN
			SET @setup_sql = @setup_sql + '
					create table monitoring.[' + @dmv_name + '] with	( distribution = round_robin, ' + @storage + ')
					as
					SELECT 0 as BatchId,  ' + @where_clause + ' as compkey,* FROM sys.[' + @dmv_name + '] OPTION (label=''Monitoring'')'
		END
		ELSE
		BEGIN
			SET @setup_sql = @setup_sql +  '
					create table monitoring.[' + @dmv_name + '] with	( distribution = round_robin, ' + @storage + ')
					as
					SELECT 0 as BatchId, * FROM sys.[' + @dmv_name + '] OPTION (label=''Monitoring'')'
		END

		 
		if len(@where_clause ) > 0 
		BEGIN
				 set @insert_sql = @insert_sql + '
					INSERT INTO  monitoring.[' + @dmv_name + '] 
					SELECT ' + convert(varchar,@batchid) + ' as BatchId, ' + @where_clause + ' as compkey, * FROM sys.[' + @dmv_name + '] where ' + @where_clause + ' not in ( select ' + @where_clause + ' from monitoring.[' + @dmv_name + ']) OPTION (label=''Monitoring'')'
		END
		ELSE
		BEGIN
				 set @insert_sql = @insert_sql + '
					INSERT INTO  monitoring.[' + @dmv_name + '] 
					SELECT ' + convert(varchar,@batchid) + ' as BatchId, NULL as compkey, * FROM sys.[' + @dmv_name + ']  OPTION (label=''Monitoring'')'

		END

	 set @view_sql_drop = '		
			IF OBJECT_ID(''monitoring.[vw_' + @dmv_name + ']'') IS NOT NULL
			BEGIN
				drop view monitoring.[vw_' + @dmv_name + '];
		   END;'

		set @view_sql_create = '		
		create view monitoring.[vw_' + @dmv_name + '] 
		as
		SELECT  * FROM monitoring.[' + @dmv_name + '] 
		where batchid = (select max(batchid) from  [monitoring].[batches]) ;'


	   if @setupmode = 1 
	   BEGIN
   		  PRINT @setup_sql
		 EXEC sp_executesql @setup_sql
	   END
	   
	    if @setupmode = 0 
	   BEGIN
		PRINT @insert_sql
		EXEC sp_executesql @insert_sql
	   END 

	   if @setupmode = 2 
	   BEGIN
		PRINT @view_sql_drop
		EXEC sp_executesql @view_sql_drop

		PRINT @view_sql_create
		EXEC sp_executesql @view_sql_create


	   END 

		SET @i+=1;
	END

	DROP TABLE #loop_ddl;

	


END
