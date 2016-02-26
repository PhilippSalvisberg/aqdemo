BEGIN
   dbms_aqadm.create_queue_table (
      queue_table          => 'RESPONSES_QT'
     ,queue_payload_type   => 'SYS.AQ$_JMS_TEXT_MESSAGE'
     ,storage_clause       => 'TABLESPACE AQDEMO
                               LOB (USER_DATA.TEXT_LOB) STORE AS SECUREFILE (
                                    TABLESPACE AQDEMO DISABLE STORAGE IN ROW CHUNK 32 k CACHE)
                               OPAQUE TYPE USER_PROP STORE AS SECUREFILE LOB (ENABLE STORAGE IN ROW) CACHE'     
     ,sort_list            => 'PRIORITY,ENQ_TIME'
     ,multiple_consumers   => TRUE
   );
END;
/
