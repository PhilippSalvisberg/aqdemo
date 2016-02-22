package com.trivadis.aqdemo.service;

import javax.jms.JMSException;
import javax.jms.TextMessage;

import org.apache.log4j.Logger;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;

@Service("SlowPrintTextService")
@Scope("prototype")
public class SlowPrintTextService implements TextMessageService {

	private final Logger logger = Logger.getLogger(SlowPrintTextService.class);

	@Override
	public void process(TextMessage request, TextMessage response) {
		String payload = null;
		try {
			payload = request.getText();
		} catch (JMSException e) {
			throw new RuntimeException("cannot extract payload from request message.");
		}
		final int minWait = 500;
		final int maxWait = 5000;
		int wait = minWait + (int) (Math.random() * (maxWait - minWait));
		try {
			Thread.sleep(wait);
		} catch (InterruptedException e) {
			throw new RuntimeException("cannot sleep.");
		}
		logger.info("printing request payload: " + payload + " (after " + (((float) wait) / 1000) + " seconds).");
	}
}
