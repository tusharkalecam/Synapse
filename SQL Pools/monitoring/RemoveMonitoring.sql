
CREATE PROC [monitoring].[RemoveMonitoring] AS
BEGIN
/* usage: This removes all the tables in the monitoring schema
*/

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
	select 'DROP TABLE [' + ss.name + '].[' + tt.name  + ']' as [statement], ROW_NUMBER() OVER (ORDER BY (SELECT NULL))    AS [seq_nmbr] 
	from sys.tables tt inner join sys.schemas ss on tt.schema_id = ss.schema_id where ss.name = 'monitoring'

	DECLARE
		@i INT = 1
		, @t INT = (SELECT COUNT(*) FROM #loop_ddl)
		, @statement NVARCHAR(4000)   = N'';
		

	  WHILE @i <= @t
	  BEGIN
		SELECT @statement = [statement] FROM #loop_ddl WHERE seq_nmbr = @i;

   		  PRINT @statement
		  EXEC sp_executesql @statement

		  SET @i+=1;
	   END

	DROP TABLE #loop_ddl;


END
