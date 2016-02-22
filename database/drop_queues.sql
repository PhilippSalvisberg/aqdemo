BEGIN
   dbms_aqadm.stop_queue(
      queue_name => 'REQUESTS_AQ'
   );
END;
/

begin
   dbms_aqadm.drop_queue (queue_name => 'REQUESTS_AQ');
END;
/

BEGIN
   dbms_aqadm.stop_queue(
      queue_name => 'RESPONSES_AQ'
   );
END;
/

begin
   dbms_aqadm.drop_queue (queue_name => 'RESPONSES_AQ');
END;
/
