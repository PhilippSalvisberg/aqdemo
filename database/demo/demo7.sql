SET ECHO ON TERMOUT ON SERVEROUTPUT ON SIZE 1000000 PAGESIZE 100 LINESIZE 250 FEEDBACK ON TIMING OFF

COLUMN msg_id FORMAT A32
COLUMN corr_id FORMAT A32
COLUMN consumer_name FORMAT A18
COLUMN app_name FORMAT A5 HEADING "APP"
COLUMN bean_name FORMAT A25
COLUMN msg_text FORMAT A13 
COLUMN enq_timestamp FORMAT A12 HEADING "ENQ_TIME"
COLUMN deq_timestamp FORMAT A12 HEADING "DEQ_TIME"
COLUMN time_in_system FORMAT A26

COLUMN request_text FORMAT A12
COLUMN response_text FORMAT A13
COLUMN request_timestamp FORMAT A12 HEADING "REQ_TIME"
COLUMN response_state FORMAT A9 HEADING "MSG_STATE"
COLUMN request_from FORMAT A18
COLUMN response_by FORMAT A18
COLUMN response_time FORMAT A26


ALTER SESSION SET nls_date_format = 'YYYY-MM-DD';
ALTER SESSION SET nls_timestamp_format = 'HH24:MI:SS.FF3';
ALTER SESSION SET nls_timestamp_tz_format = 'HH24:MI:SS.FF3';

CLEAR SCREEN
REM ===========================================================================
REM 1. Monitor requests
REM ===========================================================================

SELECT msg_id,
       --corr_id,
       msg_state,
       --retry_count,
       consumer_name,
       app_name,
       bean_name,
       msg_text,
       enq_timestamp,
       --deq_timestamp,
       time_in_system
  FROM monitor_requests_v
FETCH FIRST 100 ROWS ONLY;

PAUSE
CLEAR SCREEN

REM ===========================================================================
REM 2. Monitor requests
REM ===========================================================================
SELECT corr_id,
       response_state,
       --response_retry_count,
       --request_from,
       --response_by,
       app_name,
       bean_name,
       request_text,
       response_text,
       request_timestamp,
       response_time
  FROM monitor_responses_v
FETCH FIRST 100 ROWS ONLY;
