SET ECHO ON TERMOUT ON SERVEROUTPUT ON SIZE 1000000 PAGESIZE 100 LINESIZE 250 FEEDBACK ON TIMING OFF

REM ===========================================================================
REM 1. Asynchronous prime factorization service Calls (enqueue) 
REM ===========================================================================

DECLARE
   PROCEDURE enq(in_payload IN INTEGER) IS
      l_enqueue_options sys.dbms_aq.enqueue_options_t;
      l_message_props   sys.dbms_aq.message_properties_t;
      l_jms_message     sys.aq$_jms_text_message := sys.aq$_jms_text_message.construct;
      l_msgid           RAW(16);
   BEGIN
      l_jms_message.clear_properties();
      l_message_props.correlation := sys_guid;
      l_message_props.priority := 3;
      l_jms_message.header.set_replyto(sys.aq$_agent('PLSQL', 'RESPONSES_AQ', 0));
      l_jms_message.set_string_property('appName', 'Java');
      l_jms_message.set_string_property('beanName', 'PrimeFactorizationService');
      l_jms_message.set_text(in_payload);
      dbms_aq.enqueue(queue_name         => 'aqdemo.requests_aq',
                      enqueue_options    => l_enqueue_options,
                      message_properties => l_message_props,
                      payload            => l_jms_message,
                      msgid              => l_msgid);
      COMMIT;
   END enq;
BEGIN
   enq(12345678901234567890);
   enq(4444444444444464);
   enq(4444444444444463);
   enq(1588689192055597);
   enq(3928720489);
END;
/

PAUSE
CLEAR SCREEN
REM ===========================================================================
REM 2. Asynchronous prime factorization service call results (dequeue) 
REM ===========================================================================
DECLARE
   l_jms_message     sys.aq$_jms_text_message;
   l_dequeue_options sys.dbms_aq.dequeue_options_t;
   l_message_props   sys.dbms_aq.message_properties_t;
   l_msgid           RAW(16);
   l_text            VARCHAR2(4000);
   l_count           INTEGER;
   e_no_msg EXCEPTION;
   PRAGMA EXCEPTION_INIT(e_no_msg, -25228);
BEGIN
   LOOP
      l_dequeue_options.consumer_name := 'PLSQL';
      l_dequeue_options.navigation    := sys.dbms_aq.first_message;
      l_dequeue_options.wait          := 1;
      BEGIN
         dbms_aq.dequeue(queue_name         => 'aqdemo.responses_aq',
                         dequeue_options    => l_dequeue_options,
                         message_properties => l_message_props,
                         payload            => l_jms_message,
                         msgid              => l_msgid);
         l_jms_message.get_text(l_text);
         dbms_output.put_line(l_text);
         COMMIT;
      EXCEPTION
         WHEN e_no_msg THEN
            SELECT count(*) 
              INTO l_count
              FROM aqdemo.aq$requests_qt t 
             WHERE msg_state = 'READY'
               AND t.user_data.get_string_property('beanName') = 'PrimeFactorizationService';
            dbms_output.put_line('no responses found, ' || l_count || ' requests pending.');
            EXIT WHEN l_count = 0;
      END;
   END LOOP;
END;
/
