package com.trivadis.aqdemo;

import java.sql.SQLException;

import javax.jms.ConnectionFactory;
import javax.jms.JMSException;
import javax.jms.Session;
import javax.jms.TopicConnectionFactory;
import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.jms.listener.DefaultMessageListenerContainer;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import oracle.jms.AQjmsFactory;
import oracle.ucp.jdbc.PoolDataSource;
import oracle.ucp.jdbc.PoolDataSourceFactory;

@EnableTransactionManagement
@Configuration
public class AppConfig {
	private final Logger logger = Logger.getLogger(AppConfig.class);

	@Autowired(required = false)
	@Qualifier("aqUrl")
	private String aqUrl = "jdbc:oracle:thin:@titisee.trivadis.com:1521/phspdb2";

	@Autowired(required = false)
	@Qualifier("aqUserName")
	private String aqUserName = "aqdemo";

	@Autowired(required = false)
	@Qualifier("aqPassword")
	private String aqPassword = "aqdemo";

	@Autowired(required = false)
	@Qualifier("requestQueueName")
	private String requestQueueName = "aqdemo.requests_aq";

	@Autowired(required = false)
	@Qualifier("responseQueueName")
	private String responseQueueName = "aqdemo.responses_aq";

	@Autowired(required = false)
	@Qualifier("appName")
	private String appName = "Java";

	@Autowired(required = false)
	@Qualifier("concurrency")
	private String concurrency = "1-4";
	
	@Bean
	public ConnectionFactory connectionFactory() {
		logger.info("connectionFactory() called.");
		TopicConnectionFactory connectionFactory;
		try {
			connectionFactory = AQjmsFactory.getTopicConnectionFactory(aqDataSource());
		} catch (JMSException e) {
			throw new RuntimeException("cannot get connection factory.");
		}
		return connectionFactory;
	}

	@Bean
	public TextMessageListener messageListener() {
		logger.info("messageListener() called.");
		return new TextMessageListener();
	}

	@Bean
	public DefaultMessageListenerContainer highPriorityJmsContainer() {
		logger.info("highPriorityJmsContainer() called.");
		DefaultMessageListenerContainer cont = new DefaultMessageListenerContainer();
		cont.setConnectionFactory(connectionFactory());
		cont.setDestinationName(requestQueueName);
		cont.setMessageSelector("(JMSPriority IN (1,2) and appName = '" + appName + "')");
		cont.setMessageListener(messageListener());
		cont.setPubSubDomain(true);
		cont.setSubscriptionName(appName + "_High_Priority");
		cont.setSubscriptionDurable(true); // allow enqueue when service is down
		cont.setSessionAcknowledgeMode(Session.SESSION_TRANSACTED);
		cont.setConcurrency(concurrency);
		cont.setMaxMessagesPerTask(1);
		return cont;
	}

	@Bean
	public DefaultMessageListenerContainer lowPriorityJmsContainer() {
		logger.info("lowPriorityJmsContainer() called.");
		DefaultMessageListenerContainer cont = new DefaultMessageListenerContainer();
		cont.setConnectionFactory(connectionFactory());
		cont.setDestinationName(requestQueueName);
		cont.setMessageSelector("(JMSPriority > 2 and appName = '" + appName + "')");
		cont.setMessageListener(messageListener());
		cont.setPubSubDomain(true);
		cont.setSubscriptionName(appName + "_Low_Priority");
		cont.setSubscriptionDurable(true); // allow enqueue when service is down
		cont.setSessionAcknowledgeMode(Session.SESSION_TRANSACTED);
		cont.setConcurrency(concurrency);
		cont.setMaxMessagesPerTask(1);
		return cont;
	}
	
	@Bean
	public DataSource aqDataSource() {
		logger.info("aqDataSource() called.");
		PoolDataSource pds = PoolDataSourceFactory.getPoolDataSource();
		try {
			pds.setConnectionFactoryClassName("oracle.jdbc.OracleDriver");
			String url = aqUrl;
			pds.setURL(url);
			pds.setUser(aqUserName);
			pds.setPassword(aqPassword);
			pds.setInactiveConnectionTimeout(60);
		} catch (SQLException e) {
			throw new RuntimeException("driver not found");
		}
		return pds;
	}
	
    @Bean
    public PlatformTransactionManager txManager() {
        return new DataSourceTransactionManager(aqDataSource());
    }
	
}