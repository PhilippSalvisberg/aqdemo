package com.trivadis.aqdemo;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import javax.jms.JMSException;
import javax.jms.Session;
import javax.jms.TextMessage;
import javax.jms.Topic;
import javax.jms.TopicSession;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.ApplicationContext;
import org.springframework.jms.listener.SessionAwareMessageListener;
import org.springframework.stereotype.Component;

import com.trivadis.aqdemo.service.TextMessageService;

import oracle.jms.AQjmsAgent;
import oracle.jms.AQjmsTopicPublisher;

@Component
public class TextMessageListener implements SessionAwareMessageListener<TextMessage> {
	private final Logger logger = Logger.getLogger(TextMessageListener.class.getName());

	@Autowired
	private ApplicationContext ctx;

	@Autowired(required = false)
	@Qualifier("responseQueueName")
	private String responseQueueName = "aqdemo.responses_aq";

	@PostConstruct
	public void initialize() {
		logger.info("TextMessageListener initialized.");
	}

	@PreDestroy
	public void cleanup() {
		logger.info("TextMessageListener cleaned up.");
	}

	public void onMessage(final TextMessage request, final Session session) {

		TextMessageService service;
		String messageId = null;
		try {
			messageId = request.getJMSMessageID();
			logger.debug("processing message " + messageId + "...");

			// prepare response
			TextMessage response = null;
			AQjmsAgent replyTo = (AQjmsAgent) request.getJMSReplyTo();
			if (replyTo != null) {
				response = session.createTextMessage();
				String corrId = request.getJMSCorrelationID();
				if (corrId == null) {
					corrId = messageId;
					logger.debug("using message id as correlation id for response of message " + messageId);
				}
				response.setJMSCorrelationID(corrId);
			}
			
			// instantiate service and process request
			String beanName = request.getStringProperty("beanName");
			if (beanName != null) {
				service = ctx.getBean(request.getStringProperty("beanName"), TextMessageService.class);
				service.process(request, response);
				logger.debug("service " + beanName + " processed for message " + messageId + ".");
				if (response != null) {
					Topic topic = session.createTopic(responseQueueName);
					AQjmsTopicPublisher publisher = (AQjmsTopicPublisher) ((TopicSession) session)
							.createPublisher(topic);
					AQjmsAgent[] recipients = { replyTo };
					publisher.publish(response, recipients);
					logger.debug("published response for message " + messageId + ".");
				}
			} else {
				logger.error("No JMS property beanName found. Cannot process message.");
			}
		} catch (JMSException e) {
			logger.error("message " + messageId + " processed with error: " + e.getMessage());
			throw new RuntimeException(e);
		}
	}
}
