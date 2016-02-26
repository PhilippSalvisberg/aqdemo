/*
* Copyright 2016 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

SET DEFINE OFF
SET SCAN OFF
SET ECHO OFF
SET SERVEROUTPUT ON SIZE 1000000
SPOOL install.log

PROMPT ======================================================================
PROMPT This script installs Oracle queue tables and queues used by the 
PROMPT aqdemo Java command line application. 
PROMPT
PROMPT Please connect to the target user aqdemo. This user and its 
PROMPT associated tablespace aqdemo needs to be created in advance. 
PROMPT See ./user/sys/tablespace/aqdemo.sql and ./usr/sys/account/aqdemo.sql
PROMPT ======================================================================
PROMPT

PROMPT ======================================================================
PROMPT create request and response queue tables
PROMPT ======================================================================
PROMPT 
@./user/aqdemo/queue_table/requests_qt.sql
@./user/aqdemo/queue_table/responses_qt.sql

PROMPT ======================================================================
PROMPT create request and response queues and enable enqueue/dequeue ops
PROMPT ======================================================================
PROMPT 
@./user/aqdemo/queue/requests_aq.sql
@./user/aqdemo/queue/responses_aq.sql

PROMPT ======================================================================
PROMPT create function to call a Java service synchronously 
PROMPT ======================================================================
PROMPT 
@./user/aqdemo/function/get_prime_fact.fnc

PROMPT ======================================================================
PROMPT test: enqueue a message for recipient APP_B
PROMPT ======================================================================
PROMPT 
DECLARE
   l_enqueue_options sys.dbms_aq.enqueue_options_t;
   l_message_props   sys.dbms_aq.message_properties_t;
   l_jms_message     sys.aq$_jms_text_message := sys.aq$_jms_text_message.construct;
   l_msgid           RAW(16);
BEGIN
   l_message_props.correlation := sys_guid;
   l_message_props.recipient_list(1) := sys.aq$_agent('APP_B', 'REQUESTS_AQ', 0);   
   l_jms_message.set_text('Hello App B!');
   dbms_aq.enqueue(queue_name         => 'REQUESTS_AQ',
                   enqueue_options    => l_enqueue_options,
                   message_properties => l_message_props,
                   payload            => l_jms_message,
                   msgid              => l_msgid);
   COMMIT;
END;
/

PROMPT ======================================================================
PROMPT test: dequeue all messages for recipient/consumer APP_B
PROMPT ======================================================================
PROMPT 
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
      l_dequeue_options.wait          := 2;
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
            EXIT;
      END;
   END LOOP;
END;
/

SPOOL OFF
