package com.trivadis.aqdemo.service;

import javax.jms.TextMessage;

public interface TextMessageService {
	public void process(TextMessage request, TextMessage response);
}
