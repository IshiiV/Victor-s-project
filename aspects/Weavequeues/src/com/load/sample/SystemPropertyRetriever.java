package com.load.sample;

public class SystemPropertyRetriever {
	
	public static final String PROB_KEY = "forgetful.probability_drop";
	
	public static float getProbDrop() {
		
		String probability = null;
		
		try {
			probability = System.getProperty(PROB_KEY);
		} catch (Exception propertyException) {
			System.err.println("Error reading system property.");
			System.err.println(propertyException);
			propertyException.printStackTrace();
			System.exit(-1);
		}
		
		if (probability == null) {
			System.err.println("Could not find probability system property.");
			System.exit(-1);
		}
		
		return Float.parseFloat(probability);
		
	}

}