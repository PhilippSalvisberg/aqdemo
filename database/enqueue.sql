DECLARE
   l_enqueue_options sys.dbms_aq.enqueue_options_t;
   l_message_props   sys.dbms_aq.message_properties_t;
   l_jms_message     sys.aq$_jms_text_message := sys.aq$_jms_text_message.construct;
   l_msgid           RAW(16);
BEGIN
   l_message_props.correlation := sys_guid;
   l_message_props.recipient_list(1) := sys.aq$_agent('APP_B', 'REQUESTS_AQ', 0);   
   l_jms_message.set_text('Hello App B');
   dbms_aq.enqueue(queue_name         => 'REQUESTS_AQ',
                   enqueue_options    => l_enqueue_options,
                   message_properties => l_message_props,
                   payload            => l_jms_message,
                   msgid              => l_msgid);
   COMMIT;
END;
/

DECLARE
   l_enqueue_options sys.dbms_aq.enqueue_options_t;
   l_message_props   sys.dbms_aq.message_properties_t;
   l_jms_message     sys.aq$_jms_text_message := sys.aq$_jms_text_message.construct;
   l_msgid           RAW(16);
BEGIN
   l_message_props.correlation := sys_guid;
   l_message_props.priority := 1;
   l_message_props.recipient_list(1) := sys.aq$_agent(NULL, 'REQUESTS_AQ', 0);
   l_jms_message.header.set_replyto(sys.aq$_agent('PLSQL', 'RESPONSES_AQ', 0));
   l_jms_message.set_string_property('appName', 'Java');
   l_jms_message.set_string_property('beanName', 'PrintTextService');
   l_jms_message.set_text('Hello Java Service!');
   dbms_aq.enqueue(queue_name         => 'REQUESTS_AQ',
                   enqueue_options    => l_enqueue_options,
                   message_properties => l_message_props,
                   payload            => l_jms_message,
                   msgid              => l_msgid);
   COMMIT;
END;
/

DECLARE
   l_enqueue_options sys.dbms_aq.enqueue_options_t;
   l_message_props   sys.dbms_aq.message_properties_t;
   l_jms_message     sys.aq$_jms_text_message := sys.aq$_jms_text_message.construct;
   l_msgid           RAW(16);
BEGIN
   FOR i IN 1 .. 200
   LOOP
      l_jms_message.clear_properties();
      l_message_props.correlation := sys_guid;
      l_message_props.priority := 1;
      l_message_props.recipient_list(1) := sys.aq$_agent(NULL, 'REQUESTS_AQ', 0);
      l_jms_message.header.set_replyto(sys.aq$_agent('PLSQL', 'RESPONSES_AQ', 0));
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

DECLARE
   l_enqueue_options sys.dbms_aq.enqueue_options_t;
   l_message_props   sys.dbms_aq.message_properties_t;
   l_jms_message     sys.aq$_jms_text_message := sys.aq$_jms_text_message.construct;
   l_msgid           RAW(16);
BEGIN
   FOR i IN 1 .. 20
   LOOP
      l_jms_message.clear_properties();
      l_message_props.correlation := sys_guid;
      l_message_props.priority := 3;
      l_message_props.recipient_list(1) := sys.aq$_agent(NULL, 'REQUESTS_AQ', 0);
      l_jms_message.header.set_replyto(sys.aq$_agent('PLSQL', 'RESPONSES_AQ', 0));
      l_jms_message.set_string_property('appName', 'Java');
      l_jms_message.set_string_property('beanName', 'SlowPrintTextService');
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

