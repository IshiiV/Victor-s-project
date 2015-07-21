package com.load.sample;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.PriorityQueue;
import java.util.Random;

import org.pmw.tinylog.Logger;

// if remove perthis, it works, but we can't store per-object data
aspect QueueAspect { // perthis(addCall(PriorityQueue, Object)) {

    private static final int SEED = 1234;
    private static final boolean ENABLED = true;
    private static final long MIN_OBJECTS_ADDED = 100;
    // NB -- race conditions
    private static Random rng = new Random(SEED);
    private static HashMap<PriorityQueue,Long> queueCounters = new HashMap<PriorityQueue,Long>();
    private static float probDropped;
    
    static {
        Logger.info("PriorityQueueAspect loaded.");
        probDropped = SystemPropertyRetriever.getProbDrop();
    }
    
    pointcut addCall(PriorityQueue priorityQueue, Object e):
    call(boolean PriorityQueue.add(Object))
	&& target(priorityQueue)
	&& args(e);

    /**
     * Intercept an add to the PriorityQueue, and discard it stochastically, 
     * provided there exists a suitable replacement within the PriorityQueue.
     * @param priorityQueue
     * @param e
     * @return
     */
    boolean around(PriorityQueue priorityQueue, Object e): 
    												addCall(priorityQueue, e){

        boolean discard = false;
        Object actualObjectToInsert = e;

        if (!queueCounters.containsKey(priorityQueue)) {
        	queueCounters.put(priorityQueue, 0L);
        }
        long numberAdded = queueCounters.get(priorityQueue);
        numberAdded++;
        queueCounters.put(priorityQueue, numberAdded);
        
    	Logger.info("[" + this.getClass().getName() + "] Number of inserted objects " + numberAdded);

        if (ENABLED && !priorityQueue.isEmpty()) {
            discard = randomlyForget(numberAdded);
        }

        if (discard) {
        	
            Object[] queueAsArray = priorityQueue.toArray();
            List queueAsList = Arrays.asList(queueAsArray);
            Collections.shuffle(queueAsList,rng);
            
            for (Object o : queueAsList) {

            	if (o.getClass() == e.getClass()) {
            		actualObjectToInsert = o;
            		Logger.info("[QueueAspect] Item replaced. Replaced: " + e + " with: " + o);
            		break;
            	}
            	
            }
            
        } 
        
        return proceed(priorityQueue, actualObjectToInsert);
        
    }
    

    /**
     * @return true If this item is to be discarded.
     */
    public boolean randomlyForget(long numberAdded) {
	    if (numberAdded > MIN_OBJECTS_ADDED) {
	      return rng.nextFloat() < probDropped;
	    } else {
	        return false;
	    }
    }

}