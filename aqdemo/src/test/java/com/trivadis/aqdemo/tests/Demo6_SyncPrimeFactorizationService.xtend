package com.trivadis.aqdemo.tests

import com.trivadis.aqdemo.tests.model.PrimeFactorization
import javax.sql.DataSource
import org.apache.log4j.Logger
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.jdbc.core.BeanPropertyRowMapper
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.context.testng.AbstractTestNGSpringContextTests
import org.testng.Assert
import org.testng.annotations.AfterClass
import org.testng.annotations.BeforeClass
import org.testng.annotations.Test

@Test
@ContextConfiguration(locations=#["file:src/test/resources/applicationContext.xml"])
class Demo6_SyncPrimeFactorizationService extends AbstractTestNGSpringContextTests {
	@Autowired
	private DataSource aqDataSource

	private JdbcTemplate jdbcTemplate

	private Logger logger = Logger.getLogger(Demo6_SyncPrimeFactorizationService)

	@BeforeClass
	def setup() {
		jdbcTemplate = new JdbcTemplate(aqDataSource)
		val stmt = '''
			CREATE OR REPLACE FUNCTION get_prime_fact(in_number  IN INTEGER,
			                                          in_timeout IN INTEGER DEFAULT 30)
			   RETURN VARCHAR2 IS
			   PRAGMA AUTONOMOUS_TRANSACTION;
			   l_correlation VARCHAR2(128);
			   --
			   FUNCTION enqueue(in_number IN INTEGER, in_timeout IN INTEGER) RETURN VARCHAR2 IS
			      l_enqueue_options sys.dbms_aq.enqueue_options_t;
			      l_message_props   sys.dbms_aq.message_properties_t;
			      l_jms_message     sys.aq$_jms_text_message := sys.aq$_jms_text_message.construct;
			      l_msgid           RAW(16);
			   BEGIN
			      l_jms_message.clear_properties();
			      l_message_props.correlation := sys_guid;
			      l_message_props.priority := 3;
			      l_message_props.expiration := in_timeout;
			      l_jms_message.header.set_replyto(sys.aq$_agent('PLSQL', 'RESPONSES_AQ', 0));
			      l_jms_message.set_string_property('appName', 'Java');
			      l_jms_message.set_string_property('beanName', 'PrimeFactorizationService');
			      l_jms_message.set_text(in_number);
			      dbms_aq.enqueue(queue_name         => 'aqdemo.requests_aq',
			                      enqueue_options    => l_enqueue_options,
			                      message_properties => l_message_props,
			                      payload            => l_jms_message,
			                      msgid              => l_msgid);
			      COMMIT;
			      RETURN l_message_props.correlation;
			   END enqueue;
			   --
			   FUNCTION dequeue(in_correlation IN VARCHAR2, in_timeout IN INTEGER) RETURN VARCHAR2 IS
			      l_jms_message     sys.aq$_jms_text_message;
			      l_dequeue_options sys.dbms_aq.dequeue_options_t;
			      l_message_props   sys.dbms_aq.message_properties_t;
			      l_msgid           RAW(16);
			      l_text            VARCHAR2(4000);
			      e_no_msg EXCEPTION;
			      PRAGMA EXCEPTION_INIT(e_no_msg, -25228);
			   BEGIN
			      l_dequeue_options.consumer_name := 'PLSQL';
			      l_dequeue_options.navigation    := sys.dbms_aq.first_message;
			      l_dequeue_options.wait          := in_timeout;
			      l_dequeue_options.correlation   := in_correlation;
			      BEGIN
			         dbms_aq.dequeue(queue_name         => 'aqdemo.responses_aq',
			                         dequeue_options    => l_dequeue_options,
			                         message_properties => l_message_props,
			                         payload            => l_jms_message,
			                         msgid              => l_msgid);
			         l_jms_message.get_text(l_text);
			         COMMIT;
			         RETURN l_text;
			      EXCEPTION
			         WHEN e_no_msg THEN
			            COMMIT;
			            RETURN NULL;
			      END;
			   END dequeue;
			BEGIN
			   l_correlation := enqueue(in_number, in_timeout);
			   RETURN dequeue(l_correlation, in_timeout);
			END get_prime_fact;
		'''
		jdbcTemplate.execute(stmt)
	}

	@Test()
	def process() {
		val stmt = '''
			 SELECT rownum                          AS input_number,
			       aqdemo.get_prime_fact(rownum, 1) AS prime_factorization
			   FROM dual
			CONNECT BY rownum <= 100
		'''
		jdbcTemplate.fetchSize = 20
		var int resultCount = 0
		var int rowCount = 0
		val primeFactorizations = jdbcTemplate.query(stmt,
			new BeanPropertyRowMapper<PrimeFactorization>(PrimeFactorization))
		for (p : primeFactorizations) {
			rowCount++
			resultCount += if (p.primeFactorization != null) {1} else {0}
			logger.info('''prime factorization of «p.inputNumber»: «p.primeFactorization»''')
		}
		Assert.assertEquals(rowCount, 100)
		Assert.assertEquals(resultCount, 99)
	}

	@AfterClass
	def tearDown() {
		logger.info("test completed.")
	}
}