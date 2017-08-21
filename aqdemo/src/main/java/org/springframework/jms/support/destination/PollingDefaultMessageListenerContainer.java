package org.springframework.jms.support.destination;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;

import org.springframework.jms.listener.DefaultMessageListenerContainer;

/**
 * Overrides behaviour of {@link org.springframework.jms.support.destination.JmsDestinationAccessor}.
 * To solve blocked listeners after network failure. It looks like the receive(timeout) method of 
 * the Oracle AQ driver cannot recover form network failure. As a workaround receiveNoWait() is used.
 * To reduce the number of threads created in idle periods a noWaitIdlePollingInterval property is introduced.
 *
 * @author Philipp Salvisberg, Trivadis
 *
 */
public class PollingDefaultMessageListenerContainer extends DefaultMessageListenerContainer {
	
	public static final int NOWAIT_IDLE_POLLING_INTERVAL_IN_MILLISECONS = 1000;
	
	private int noWaitIdlePollingInterval = NOWAIT_IDLE_POLLING_INTERVAL_IN_MILLISECONS;

	public int getNoWaitIdlePollingInterval() {
		return noWaitIdlePollingInterval;
	}

	public void setNoWaitIdlePollingInterval(int noWaitIdlePollingInterval) {
		this.noWaitIdlePollingInterval = noWaitIdlePollingInterval;
	}

	@Override
	protected Message receiveFromConsumer(MessageConsumer consumer, long timeout) throws JMSException {
		if (timeout > 0) {
			return consumer.receive(timeout);
		}
		else if (timeout < 0) {
			// default was: return consumer.receiveNoWait();
			final Message message = consumer.receiveNoWait();
			if (message == null) {
				try {
					Thread.sleep(noWaitIdlePollingInterval);
				} catch (InterruptedException e) {
					// ignore
				}
			}
			return message;
		}
		else {
			return consumer.receive();
		}
	}

}
