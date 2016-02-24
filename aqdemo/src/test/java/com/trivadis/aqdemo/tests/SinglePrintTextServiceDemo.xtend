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
class SinglePrintTextServiceDemo extends AbstractTestNGSpringContextTests {
	@Autowired
	private DataSource aqDataSource
	
	private JdbcTemplate jdbcTemplate

	private Logger logger = Logger.getLogger(SinglePrintTextServiceDemo)
	
	@BeforeClass
	def setup() {
		jdbcTemplate = new JdbcTemplate(aqDataSource)
		Thread.sleep(1000)
	}

	@Test()
	def enqueueSingleMessage() {
		val stmt = '''
			DECLARE
			   l_enqueue_options sys.dbms_aq.enqueue_options_t;
			   l_message_props   sys.dbms_aq.message_properties_t;
			   l_jms_message     sys.aq$_jms_text_message := sys.aq$_jms_text_message.construct;
			   l_msgid           RAW(16);
			BEGIN
			   l_message_props.recipient_list(1) := sys.aq$_agent(NULL, 'REQUESTS_AQ', 0);
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
		'''
		jdbcTemplate.execute(stmt)
		logger.info("one message enqueued.")
	}
	
	@AfterClass
	def tearDown() {
		// give MessageListener some time to complete
		Thread.sleep(2000)
		logger.info("test completed.")
	}
}