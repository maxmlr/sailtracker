---------------------------------------------------------------------------
-- pg_cron async job
--
--CREATE DATABASE cron_database;
--CREATE SCHEMA IF NOT EXISTS cron;
--\c cron_database
\c postgres

CREATE EXTENSION IF NOT EXISTS pg_cron; -- provides a simple cron-based job scheduler for PostgreSQL
-- TRUNCATE table jobs
--TRUNCATE TABLE cron.job CONTINUE IDENTITY RESTRICT;

-- Create a every 5 minutes or minute job cron_process_new_logbook_fn ??
SELECT cron.schedule('cron_new_logbook', '*/5 * * * *', 'select public.cron_process_new_logbook_fn()');
--UPDATE cron.job SET database = 'signalk' where jobname = 'cron_new_logbook';

-- Create a every 5 minute job cron_process_new_stay_fn
SELECT cron.schedule('cron_new_stay', '*/6 * * * *', 'select public.cron_process_new_stay_fn()');
--UPDATE cron.job SET database = 'signalk' where jobname = 'cron_new_stay';

-- Create a every 6 minute job cron_process_new_moorage_fn, delay from stay to give time to generate geo reverse location, eg: name
SELECT cron.schedule('cron_new_moorage', '*/7 * * * *', 'select public.cron_process_new_moorage_fn()');
--UPDATE cron.job SET database = 'signalk' where jobname = 'cron_new_moorage';

-- Create a every 10 minute job cron_process_monitor_offline_fn
SELECT cron.schedule('cron_monitor_offline', '*/10 * * * *', 'select public.cron_process_monitor_offline_fn()');
--UPDATE cron.job SET database = 'signalk' where jobname = 'cron_monitor_offline';

-- Create a every 10 minute job cron_process_monitor_online_fn
SELECT cron.schedule('cron_monitor_online', '*/10 * * * *', 'select public.cron_process_monitor_online_fn()');
--UPDATE cron.job SET database = 'signalk' where jobname = 'cron_monitor_online';

-- Create a every 5 minute job cron_process_new_account_fn
--SELECT cron.schedule('cron_new_account', '*/5 * * * *', 'select public.cron_process_new_account_fn()');
--UPDATE cron.job SET database = 'signalk' where jobname = 'cron_new_account';

-- Create a every 5 minute job cron_process_new_vessel_fn
--SELECT cron.schedule('cron_new_vessel', '*/5 * * * *', 'select public.cron_process_new_vessel_fn()');
--UPDATE cron.job SET database = 'signalk' where jobname = 'cron_new_vessel';

-- Create a every 6 minute job cron_process_new_account_otp_validation_queue_fn, delay from cron_new_account
--SELECT cron.schedule('cron_new_account_otp', '*/6 * * * *', 'select public.cron_process_new_account_otp_validation_fn()');
--UPDATE cron.job SET database = 'signalk' where jobname = 'cron_new_account_otp';

-- Notification
-- Create a every 1 minute job cron_process_new_notification_queue_fn, new_account, new_vessel, _new_account_otp
SELECT cron.schedule('cron_new_notification', '*/2 * * * *', 'select public.cron_process_new_notification_fn()');
--UPDATE cron.job SET database = 'signalk' where jobname = 'cron_new_notification';

-- Maintenance
-- Vacuum database at “At 01:01 on Sunday.”
SELECT cron.schedule('cron_vacuum', '1 1 * * 0', 'VACUUM (FULL, VERBOSE, ANALYZE, INDEX_CLEANUP) api.logbook,api.stays,api.moorages,api.metadata,api.metrics;');
-- Remove all jobs log at “At 02:02 on Sunday.”
SELECT cron.schedule('job_run_details_cleanup', '2 2 * * 0', 'select public.job_run_details_cleanup_fn()');
-- Any other maintenance require?

-- OTP
-- Create a every 15 minute job cron_process_prune_otp_fn
SELECT cron.schedule('cron_prune_otp', '*/15 * * * *', 'select public.cron_process_prune_otp_fn()');

-- Cron job settings
UPDATE cron.job SET database = 'signalk';
UPDATE cron.job SET username = 'username'; -- TODO update to scheduler, pending process_queue update
--UPDATE cron.job SET username = 'username' where jobname = 'cron_vacuum'; -- TODO Update to superuser for vaccuum permissions
UPDATE cron.job SET nodename = '/var/run/postgresql/'; -- VS default localhost ??
-- check job lists
SELECT * FROM cron.job;
-- unschedule by job id
--SELECT cron.unschedule(1);
-- unschedule by job name
--SELECT cron.unschedule('cron_new_logbook');
-- TRUNCATE TABLE cron.job_run_details
--TRUNCATE TABLE cron.job_run_details CONTINUE IDENTITY RESTRICT;
-- check job log
select * from cron.job_run_details ORDER BY end_time DESC LIMIT 10;
-- DEBUG Disable all
UPDATE cron.job SET active = False;