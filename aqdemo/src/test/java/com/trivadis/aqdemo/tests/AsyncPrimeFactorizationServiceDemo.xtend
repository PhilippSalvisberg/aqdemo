package com.trivadis.aqdemo.tests

import java.sql.CallableStatement
import java.sql.SQLException
import java.sql.Types
import javax.sql.DataSource
import org.apache.log4j.Logger
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.dao.DataAccessException
import org.springframework.jdbc.core.CallableStatementCallback
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.context.testng.AbstractTestNGSpringContextTests
import org.springframework.transaction.PlatformTransactionManager
import org.springframework.transaction.support.DefaultTransactionDefinition
import org.testng.annotations.AfterClass
import org.testng.annotations.BeforeClass
import org.testng.annotations.Test

@Test(threadPoolSize=4)
@ContextConfiguration(locations=#["file:src/test/resources/applicationContext.xml"])
class AsyncPrimeFactorizationServiceDemo extends AbstractTestNGSpringContextTests {
	@Autowired
	private DataSource aqDataSource

	@Autowired
	private PlatformTransactionManager txManager

	private JdbcTemplate jdbcTemplate

	private Logger logger = Logger.getLogger(AsyncPrimeFactorizationServiceDemo)

	@BeforeClass
	def setup() {
		jdbcTemplate = new JdbcTemplate(aqDataSource)
		// give MessageListener some time to initialize
		Thread.sleep(1000)
	}

	@Test()
	def requests() {
		val stmt = '''
			DECLARE
			   l_enqueue_options sys.dbms_aq.enqueue_options_t;
			   l_message_props   sys.dbms_aq.message_properties_t;
			   l_jms_message     sys.aq$_jms_text_message := sys.aq$_jms_text_message.construct;
			   l_msgid           RAW(16);
			   --
			   PROCEDURE enq(in_payload IN INTEGER) IS
			   BEGIN
			      l_jms_message.clear_properties();
			      l_message_props.correlation := sys_guid;
			      l_message_props.priority := 3;
			      l_message_props.recipient_list(1) := sys.aq$_agent(NULL, 'REQUESTS_AQ', 0);
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
			   enq(1315172931);
			END;
		'''
		jdbcTemplate.execute(stmt)
		logger.info("4 requests enqueued.")
	}

	@Test (dependsOnMethods=#["requests"])
	def responses() {
		val txStatus = txManager.getTransaction(new DefaultTransactionDefinition())
		jdbcTemplate.execute('BEGIN dbms_output.enable(100000); END;')
		val stmt = '''
			DECLARE
			   l_jms_message     sys.aq$_jms_text_message;
			   l_dequeue_options sys.dbms_aq.dequeue_options_t;
			   l_message_props   sys.dbms_aq.message_properties_t;
			   l_msgid           RAW(16);
			   l_text            VARCHAR2(4000);
			   l_count           INTEGER := 0;
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
			         l_count := l_count + 1;
			      EXCEPTION
			         WHEN e_no_msg THEN
			            dbms_output.put_line('no message found (' || l_count || ')');
			            EXIT WHEN l_count >= 4;
			      END;
			   END LOOP;
			END;
		'''
		jdbcTemplate.execute(stmt)
		var Integer outputStatus = 0
		while (outputStatus == 0) {
			outputStatus = jdbcTemplate.execute("BEGIN dbms_output.get_line(?, ?); END;",
				new CallableStatementCallback<Integer>() {
					override Integer doInCallableStatement(
						CallableStatement cs) throws SQLException, DataAccessException {
						cs.registerOutParameter(1, Types.VARCHAR);
						cs.registerOutParameter(2, Types.INTEGER);
						cs.execute
						val outputStatus = cs.getInt(2)
						if (outputStatus == 0) {
							logger.info('''dbms_output: «cs.getString(1)»''')
						}
						return outputStatus;
					}
				});
		}
		txManager.commit(txStatus)
	}

	@AfterClass
	def tearDown() {
		logger.info("test completed.")
	}
}