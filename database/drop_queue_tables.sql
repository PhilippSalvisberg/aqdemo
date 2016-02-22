begin
   dbms_aqadm.drop_queue_table (queue_table => 'REQUESTS_QT');
end;
/

begin
   dbms_aqadm.drop_queue_table (queue_table => 'RESPONSES_QT');
end;
/
