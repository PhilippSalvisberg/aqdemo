SET ECHO ON TERMOUT ON SERVEROUTPUT ON SIZE 1000000 PAGESIZE 100 LINESIZE 250 FEEDBACK ON TIMING OFF

REM ===========================================================================
REM 1. Slow print text service calls (blocking) 
REM ===========================================================================

DECLARE
   l_enqueue_options sys.dbms_aq.enqueue_options_t;
   l_message_props   sys.dbms_aq.message_properties_t;
   l_jms_message     sys.aq$_jms_text_message := sys.aq$_jms_text_message.construct;
   l_msgid           RAW(16);
BEGIN
   FOR i IN 1 .. 16
   LOOP
      l_jms_message.clear_properties();
      l_jms_message.set_string_property('appName', 'Java');
      l_jms_message.set_string_property('beanName', 'SlowPrintTextService');
      l_jms_message.set_text('Hello Slow Java Service ' || i || '!');
      dbms_aq.enqueue(queue_name         => 'REQUESTS_AQ',
                      enqueue_options    => l_enqueue_options,
                      message_properties => l_message_props,
                      payload            => l_jms_message,
                      msgid              => l_msgid);
      COMMIT;
   END LOOP;
END;
/

PAUSE
CLEAR SCREEN
REM ===========================================================================
REM 2. Fast print text service calls (blocked) 
REM ===========================================================================
DECLARE
   l_enqueue_options sys.dbms_aq.enqueue_options_t;
   l_message_props   sys.dbms_aq.message_properties_t;
   l_jms_message     sys.aq$_jms_text_message := sys.aq$_jms_text_message.construct;
   l_msgid           RAW(16);
BEGIN
   FOR i IN 1 .. 16
   LOOP
      l_jms_message.clear_properties();
      l_message_props.recipient_list(1) := sys.aq$_agent(NULL, 'REQUESTS_AQ', 0);
      l_jms_message.set_string_property('appName', 'Java');
      l_jms_message.set_string_property('beanName', 'PrintTextService');
      l_jms_message.set_text('Hello Fast Java Service ' || i || '!');
      dbms_aq.enqueue(queue_name         => 'REQUESTS_AQ',
                      enqueue_options    => l_enqueue_options,
                      message_properties => l_message_props,
                      payload            => l_jms_message,
                      msgid              => l_msgid);
      COMMIT;
   END LOOP;
END;
/
