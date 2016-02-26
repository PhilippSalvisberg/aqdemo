SET ECHO ON TERMOUT ON SERVEROUTPUT ON SIZE 1000000 PAGESIZE 100 LINESIZE 250 FEEDBACK ON TIMING OFF

COLUMN msg_state FORMAT A9
COLUMN msg_text FORMAT A30

CLEAR SCREEN
REM ===========================================================================
REM 1. Print text service - single message
REM ===========================================================================

DECLARE
   l_enqueue_options sys.dbms_aq.enqueue_options_t;
   l_message_props   sys.dbms_aq.message_properties_t;
   l_jms_message     sys.aq$_jms_text_message := sys.aq$_jms_text_message.construct;
   l_msgid           RAW(16);
BEGIN
   l_jms_message.set_string_property('appName', 'Java');
   l_jms_message.set_string_property('beanName', 'PrintTextService');
   l_jms_message.set_text('Hello Java Service!');
   dbms_aq.enqueue(queue_name         => 'REQUESTS_AQ',
				   enqueue_options    => l_enqueue_options,
				   message_properties => l_message_props,
				   payload            => l_jms_message,
				   msgid              => l_msgid);
   COMMIT;
   dbms_output.put_line('message ' || l_msgid || ' enqueued.');
END;
/
PAUSE
SELECT msg_id, msg_state, retry_count, t.user_data.text_vc AS msg_text
  FROM aq$requests_qt t
 ORDER BY enq_timestamp DESC
 FETCH FIRST ROW ONLY;

PAUSE
CLEAR SCREEN
REM ===========================================================================
REM 2. Wrong bean
REM ===========================================================================

DECLARE
   l_enqueue_options sys.dbms_aq.enqueue_options_t;
   l_message_props   sys.dbms_aq.message_properties_t;
   l_jms_message     sys.aq$_jms_text_message := sys.aq$_jms_text_message.construct;
   l_msgid           RAW(16);
BEGIN
   l_jms_message.set_string_property('appName', 'Java');
   l_jms_message.set_string_property('beanName', 'PrintTextService42');
   l_jms_message.set_text('Hello Java Service 42!');
   dbms_aq.enqueue(queue_name         => 'REQUESTS_AQ',
				   enqueue_options    => l_enqueue_options,
				   message_properties => l_message_props,
				   payload            => l_jms_message,
				   msgid              => l_msgid);
   COMMIT;
   dbms_output.put_line('message ' || l_msgid || ' enqueued.');
END;
/
PAUSE
SELECT msg_id, msg_state, retry_count, t.user_data.text_vc AS msg_text
  FROM aq$requests_qt t
 ORDER BY enq_timestamp DESC
 FETCH FIRST 2 ROWS ONLY;
