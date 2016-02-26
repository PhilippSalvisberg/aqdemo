SET ECHO ON TERMOUT ON SERVEROUTPUT ON SIZE 1000000 PAGESIZE 100 LINESIZE 250 FEEDBACK ON

REM ===========================================================================
REM 1. Print Text Service - Multiple Messages
REM ===========================================================================

DECLARE
   l_enqueue_options sys.dbms_aq.enqueue_options_t;
   l_message_props   sys.dbms_aq.message_properties_t;
   l_jms_message     sys.aq$_jms_text_message := sys.aq$_jms_text_message.construct;
   l_msgid           RAW(16);
BEGIN
   FOR i IN 1 .. 200
   LOOP
      l_jms_message.clear_properties();
      l_message_props.priority := 1;
      l_jms_message.set_string_property('appName', 'Java');
      l_jms_message.set_string_property('beanName', 'PrintTextService');
      l_jms_message.set_text('Hello Java Service ' || i || '!');
      dbms_aq.enqueue(queue_name         => 'REQUESTS_AQ',
                      enqueue_options    => l_enqueue_options,
                      message_properties => l_message_props,
                      payload            => l_jms_message,
                      msgid              => l_msgid);
      COMMIT;
   END LOOP;
END;
/
