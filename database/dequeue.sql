DECLARE
   l_jms_message     sys.aq$_jms_text_message;
   l_dequeue_options sys.dbms_aq.dequeue_options_t;
   l_message_props   sys.dbms_aq.message_properties_t;
   l_msgid           RAW(16);
   l_text            VARCHAR2(4000);
   e_no_msg EXCEPTION;
   PRAGMA EXCEPTION_INIT(e_no_msg, -25228);
BEGIN
   LOOP
      l_dequeue_options.consumer_name := 'APP_B';
      l_dequeue_options.navigation    := sys.dbms_aq.first_message;
      l_dequeue_options.wait          := 5;
      BEGIN
         dbms_aq.dequeue(queue_name         => 'REQUESTS_AQ',
                         dequeue_options    => l_dequeue_options,
                         message_properties => l_message_props,
                         payload            => l_jms_message,
                         msgid              => l_msgid);
         l_jms_message.get_text(l_text);
         dbms_output.put_line(l_text);
         COMMIT;
      EXCEPTION
         WHEN e_no_msg THEN
            dbms_output.put_line('no message found');
            EXIT;
      END;
   END LOOP;
END;
/
