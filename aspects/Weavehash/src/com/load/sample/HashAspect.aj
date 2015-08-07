package com.load.sample;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;
import java.util.Random;

import org.pmw.tinylog.writers.FileWriter;
import org.pmw.tinylog.*;

aspect HashAspect perthis(putCall(Map, Object, Object)) {

    private static final int SEED = 1234;
    private static final long MIN_BYTES_INSERTED = 1000;
    private static final float PROBABILITY_DROPPED = 0.1f;
    private static Random rng = new Random(SEED);

    // what is our forgetfulness policy right now?
    private static int currentHeuristic;
    private int nesting = 0;

    // Bytes inserted in the datastructure, used as a threshold for enabling forgetting
    private long totalBytesInserted = 0;

    static {
	String prop = System.getProperty("forgetful.policy", "random");
	Logger.info("********** current forgetfulness policy: " + prop);
	currentHeuristic = ForgetfulHeuristic.fromString(prop);
	Logger.info("************** current HashAspect heuristic val: " + currentHeuristic);
    }

    pointcut putCall(Map hm, Object key, Object value):
    call(Object Map.put(Object, Object))
	&& target(hm) 
	&& args(key, value);

    pointcut getCall(Map hm, Object key):
    call(Object Map.get(Object))
	&& target(hm)
	&& args(key);

    /** 
	Intercept put call to hashmap.
    **/
    Object around(Map hm, Object key, Object value): putCall(hm, key, value){
	    return proceed(hm, key, value);
	
    }

    // advice to insert 'instead of' get calls
    Object around(Map hm, Object key): getCall(hm, key) {
    nesting ++;
	Logger.info("[HashAspect] Get call invoked.");
	
	
	
	 //long etime=System.currentTimeMillis();
	nesting--;
	StringBuilder info = new StringBuilder();
	for (int i=0;i<nesting;i++) {
		info.append(" ");
	}
	//info.append(thisJoinPoint+" took "+(etime-stime)+"ms\n");
	
	StringWriter sw = new StringWriter();
	new Throwable().printStackTrace(new PrintWriter(sw));
	
	String [] methods = sw.toString().split("at");
	ArrayList<String> methodsList = new ArrayList<String>(Arrays.asList(methods));
	methodsList.remove(0);
	methodsList.remove(0);
	for(String s : methodsList){
		info.append(s);
	}
	
	//info.append(sw.toString());
	Logger.info(info);
	
		
	
	return proceed(hm, key);
    }

    /**
     * @return true if this put call should be
     *         intercepted
     * Uses some kind of pseudo-random decision-making
     * (ideally) - or perhaps it looks at VM memory level
     * right now, and is more likely to forget if
     * we are running low on heap memory?
     */
    public boolean randomlyForget() {
	if (totalBytesInserted > MIN_BYTES_INSERTED) {
	    return rng.nextFloat() < PROBABILITY_DROPPED;
	} else {
	  return false;
	}
    }
}