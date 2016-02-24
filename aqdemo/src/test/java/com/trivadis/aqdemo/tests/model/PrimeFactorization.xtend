package com.trivadis.aqdemo.tests.model

import java.math.BigInteger
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder

@Accessors
class PrimeFactorization {
	private BigInteger inputNumber
	private String primeFactorization

	override toString() {
		new ToStringBuilder(this).addAllFields.toString
	}

}