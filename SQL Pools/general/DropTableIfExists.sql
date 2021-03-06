/*

Simple script to drop a table if it already exsits


*/
CREATE PROC [dbo].[DropTableIfExists] @schema_name [varchar](50),@table_name [varchar](150) AS
BEGIN

DECLARE @sSQL varchar(8000);

if exists (
select 1 from sys.schemas s inner join sys.tables t 
on s.schema_id = t.schema_id 
where s.name =   @schema_name and t.name =  @table_name )
BEGIN
    PRINT 'DELETE TABLE'
    set @sSQL = 'DROP TABLE [' + @schema_name + '].[' + @table_name + '];'
    EXEC (@sSQL);
END
ELSE
BEGIN
    PRINT 'TABLE DOES NOT EXISTS'
END

END
