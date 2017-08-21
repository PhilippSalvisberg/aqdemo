DECLARE
   r_purge_options   sys.dbms_aqadm.aq$_purge_options_t;
BEGIN
   sys.dbms_aqadm.purge_queue_table(
      queue_table       => 'REQUESTS_QT',
      purge_condition   => '1=1',
      purge_options     => r_purge_options
   );
   sys.dbms_aqadm.purge_queue_table(
      queue_table       => 'RESPONSES_QT',
      purge_condition   => '1=1',
      purge_options     => r_purge_options
   );
END;
/
