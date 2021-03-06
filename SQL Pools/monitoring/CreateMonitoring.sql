
CREATE PROC [monitoring].[CreateMonitoring] AS
BEGIN
/*
Proc: create the monitoring control table.

The monitoring runs from this table.

We are only collecting a subset of the DMV's
*/

-- delete table if it already exists
IF OBJECT_ID('monitoring.control') IS NOT NULL
BEGIN;
	DROP TABLE monitoring.control;
END;

-- Create monitoring table
create table monitoring.control
(
 description varchar(50),
 dmv_name varchar(200),
 where_clause varchar(250),
 database_type int,
 [enabled] int,
 [storage] varchar(50),
 [filter] varchar(50)
)

-- Insert the DMV's we want to collect.  We use a composite key to use to work out if we have already collected the data.
insert into monitoring.control values ('DMVs','dm_pdw_dms_workers','request_id + status + convert(varchar(10),total_elapsed_time)',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
insert into monitoring.control values ('DMVs','dm_pdw_exec_requests','[request_id] + [status]',1,1,'CLUSTERED COLUMNSTORE INDEX','');
insert into monitoring.control values ('DMVs','dm_pdw_exec_sessions','[request_id] + [status]',1,1,'CLUSTERED COLUMNSTORE INDEX','');
insert into monitoring.control values ('DMVs','dm_pdw_errors','[error_id]',1,1,'CLUSTERED COLUMNSTORE INDEX','');
insert into monitoring.control values ('DMVs','dm_pdw_request_steps','request_id + convert(varchar(10),step_index) +  convert(varchar(10),total_elapsed_time) + operation_type',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
--	insert into monitoring.control values ('DMVs','dm_pdw_resource_waits','request_id + session_id + convert(varchar(10),wait_id) + convert(varchar(32),object_name) ',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
--	insert into monitoring.control values ('DMVs','dm_pdw_sql_requests','request_id +  convert(varchar(10),step_index) + convert(varchar(10), pdw_node_id)+ convert(varchar(10),distribution_id) + status',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');

--

/*
	insert into monitoring.control values ('DMVs','pdw_column_distribution_properties','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_distributions','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_index_mappings','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_loader_backup_run_details','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_loader_backup_runs','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_materialized_view_column_distribution_properties','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_materialized_view_distribution_properties','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_materialized_view_mappings','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_nodes_column_store_dictionaries','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_nodes_column_store_row_groups','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_nodes_column_store_segments','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_nodes_columns','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_nodes_indexes','',1,1,'HEAP');
	insert into monitoring.control values ('DMVs','pdw_nodes_partitions','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_nodes_pdw_physical_databases','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_nodes_tables','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_replicated_table_cache_state','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_table_distribution_properties','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','pdw_table_mappings','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','workload_management_workload_classifier_details','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','workload_management_workload_classifiers','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_dms_cores','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_dms_external_work','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('Sessions','dm_pdw_exec_sessions','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_exec_connections','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
 	insert into monitoring.control values ('DMVs','dm_pdw_hadoop_operations','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_lock_waits','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_database_encryption_keys','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_os_threads','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_sys_info','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_wait_stats','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_waits','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_workload_management_workload_groups_stats','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_db_column_store_row_group_physical_stats','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_db_column_store_row_group_operational_stats','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_db_file_space_usage','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');	
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_db_index_usage_stats','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_db_partition_stats','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');	
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_db_session_space_usage','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');	
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_db_task_space_usage','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');	
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_exec_background_job_queue','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');	
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_exec_background_job_queue_stats','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');	
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_exec_cached_plans','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');	
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_exec_connections','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');	
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_exec_procedure_stats','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');	
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_exec_query_memory_grants','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_exec_query_optimizer_info','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_exec_query_resource_semaphores','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_exec_query_stats','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_exec_requests','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_exec_sessions','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_io_pending_io_requests','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_io_virtual_file_stats','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_buffer_descriptors','',1,0,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_child_instances','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_cluster_nodes','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_dispatcher_pools','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_dispatchers','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_hosts','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_latch_stats','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_memory_brokers','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_memory_cache_clock_hands','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_memory_cache_counters','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_memory_cache_entries','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_memory_cache_hash_tables','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_memory_clerks','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_memory_node_access_stats','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_memory_nodes','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_memory_objects','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_memory_pools','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_nodes','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_performance_counters','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_process_memory','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_schedulers','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_spinlock_stats','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_sys_info','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_sys_memory','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_tasks','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_threads','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_virtual_address_dump','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_wait_stats','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_waiting_tasks','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_os_workers','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_tran_active_snapshot_database_transactions','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_tran_active_transactions','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_tran_commit_table','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_tran_current_snapshot','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_tran_current_transaction','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_tran_database_transactions','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_tran_locks','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_tran_session_transactions','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
	insert into monitoring.control values ('DMVs','dm_pdw_nodes_tran_top_version_generators','',1,1,'CLUSTERED COLUMNSTORE INDEX','REQUEST_ID');
*/

END