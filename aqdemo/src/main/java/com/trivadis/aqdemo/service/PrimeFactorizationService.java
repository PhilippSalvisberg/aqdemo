package com.trivadis.aqdemo.service;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;

import javax.jms.JMSException;
import javax.jms.TextMessage;

import org.apache.log4j.Logger;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service("PrimeFactorizationService")
@Scope("prototype")
public class PrimeFactorizationService implements TextMessageService {

	private final Logger logger = Logger.getLogger(PrimeFactorizationService.class);

	// based on Robert Sedgewick and Kevin Wayne's algorithm published on
	// http://introcs.cs.princeton.edu/java/13flow/Factors.java.html
	public List<BigInteger> getPrimeFactors(BigInteger inputNumber) {
		List<BigInteger> primeFactors = new ArrayList<BigInteger>();
		BigInteger n = inputNumber;
		for (BigInteger i = new BigInteger("2"); i.multiply(i).compareTo(n) <=0; i = i.add(BigInteger.ONE)) {
			while (n.mod(i).compareTo(BigInteger.ZERO) == 0) {
				primeFactors.add(i);
				n = n.divide(i);
			}
		}
		if (BigInteger.ONE.compareTo(n) < 0) {
			primeFactors.add(n);
		}
		return primeFactors;
	}

	@Override
	public void process(TextMessage request, TextMessage response) {
		String inputNumber = null;
		try {
			inputNumber = request.getText();
		} catch (JMSException e) {
			throw new RuntimeException("cannot extract payload (Long number) from request message.");
		}
		String result = StringUtils.collectionToCommaDelimitedString(getPrimeFactors(new BigInteger(inputNumber)));
		try {
			response.setText(result);
		} catch (JMSException e) {
			throw new RuntimeException("cannot write result to response message.");
		}
		logger.info("prime factorization of "+inputNumber+ ": " + result);
	}
}
