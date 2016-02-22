package com.trivadis.aqdemo.tests

import javax.sql.DataSource
import org.apache.log4j.Logger
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.context.testng.AbstractTestNGSpringContextTests
import org.testng.annotations.AfterClass
import org.testng.annotations.BeforeClass
import org.testng.annotations.Test

@Test
@ContextConfiguration(locations=#["file:src/test/resources/applicationContext.xml"])
class MultiPrintTextServiceDemo extends AbstractTestNGSpringContextTests {
	@Autowired
	private DataSource aqDataSource
	
	private JdbcTemplate jdbcTemplate
	private int currentInvocation;

	private Logger logger = Logger.getLogger(MultiPrintTextServiceDemo)
	
	@BeforeClass
	def setup() {
		jdbcTemplate = new JdbcTemplate(aqDataSource)
		currentInvocation = 0;
		// give MessageListener some time to initialize
		Thread.sleep(1000)
	}
	
	synchronized def increment() {
		currentInvocation++
		return currentInvocation
	}

	@Test(invocationCount=4, threadPoolSize=1)
	def enqueueMultiMessages() {
		val invocation = increment()
		val stmt = '''
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
			      l_jms_message.set_text('Hello Java Service ' || i || ' («invocation»)!');
			      dbms_aq.enqueue(queue_name         => 'REQUESTS_AQ',
			                      enqueue_options    => l_enqueue_options,
			                      message_properties => l_message_props,
			                      payload            => l_jms_message,
			                      msgid              => l_msgid);
			      COMMIT;
			   END LOOP;
			END;
		'''
		jdbcTemplate.execute(stmt)
		logger.info("200 messages enqueued.")
	}
	
	@AfterClass
	def tearDown() {
		// give MessageListener some time to complete
		Thread.sleep(4000)
		logger.info("test completed.")
	}	
}