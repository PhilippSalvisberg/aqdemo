package com.trivadis.aqdemo.service;

import javax.jms.JMSException;
import javax.jms.TextMessage;

import org.apache.log4j.Logger;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;

@Service("PrintTextService")
@Scope("prototype")
public class PrintTextService implements TextMessageService {

	private final Logger logger = Logger.getLogger(PrintTextService.class);

	@Override
	public void process(TextMessage request, TextMessage response) {
		String payload = null;
		try {
			payload = request.getText();
		} catch (JMSException e) {
			throw new RuntimeException("cannot extract payload from request message.");
		}
		logger.info("printing request payload: " + payload);
	}
}
