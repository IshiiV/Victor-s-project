package com.load.sample;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;
import java.io.StringWriter; 
import java.io.PrintWriter;
import org.pmw.tinylog.Logger;

aspect ListAspect perthis(addCall(List,Object)) {

  private final static int SEED = 1234;
  // private final static int currentHeuristic = ForgetfulHeuristic.RANDOM_DROP_CURRENT;
  private static int currentHeuristic;
  
  static {
    // set current forgetfulness policy
    String prop = System.getProperty("forgetful.policy", "none");
    Logger.info("********** current forgetfulness policy: " + prop);
    currentHeuristic = ForgetfulHeuristic.fromString(prop);
    Logger.info("************** current ListAspect heuristic val: " + currentHeuristic);
  }

    pointcut addCall(List list, Object e):
    call(boolean List.add(Object))
	&& target(list)
	&& args(e)
;

    private int nesting = 0;
    // One aspect instance is created for each target object, so we keep track of the following on a per-object basis.
    private long numCalls = 0;


    
    
    private void dropRandomOther(List list, Object e) {
        for (Object o : list.toArray()) {
            if (o.equals(e)) {
                continue;
            } else {
                // found a different key, so
                // null its corresponding value            
                list.remove(o);
                break;
            }
        }	   
    }


    boolean around(List list, Object e): addCall(list, e) {
    	
		nesting++;
		//long stime=System.currentTimeMillis();
    	
        boolean retVal = true; // always returns true
	boolean dataForgotten = false;  // do we forget any info?
        numCalls++;
        /*
        System.out.println(numCalls);
        System.out.println(totalSize);
        totalSize ++;
        System.out.println(totalSize);
        */
        //totalSize += ObjectSizeFetcher.getObjectSize(e);
        Logger.info("Add invocation count: " + numCalls + "\t");
        //Logger.info("Object to add: " + e + " total size of datastructure: " + totalSize);
        switch(currentHeuristic) {
        case ForgetfulHeuristic.RANDOM_DROP_CURRENT:
            if (!randomlyForget()) {
		retVal = proceed(list,e);
		dataForgotten = false;
	    }
	    else {
		dataForgotten = true;
	    }
            break;
        case ForgetfulHeuristic.RANDOM_DROP_OTHER:
            if (randomlyForget()) {
		dropRandomOther(list,e);
		dataForgotten = true;
	    }
	    else {
		dataForgotten = false;
	    }
            retVal = proceed(list,e);         
        case ForgetfulHeuristic.NONE:
        default:
	    dataForgotten = false;
            retVal = proceed(list, e);
        }
        
        //long etime=System.currentTimeMillis();
		nesting--;
		StringBuilder info = new StringBuilder();
		for (int i=0;i<nesting;i++) {
			info.append(" ");
		}
		//info.append(thisJoinPoint+" took "+(etime-stime)+"ms\n");

		StringWriter sw = new StringWriter();
		new Throwable().printStackTrace(new PrintWriter(sw));
		
		String [] methods = sw.toString().split("at ");
		ArrayList<String> methodsList = new ArrayList<String>(Arrays.asList(methods));
		methodsList.remove(0);
		methodsList.remove(0);
		for(String s : methodsList){
			info.append(s);
		}

		info.append("DATA FORGOTTEN: " + (dataForgotten?1:0));
		
		//info.append(sw.toString());
		Logger.info(info);

        return retVal;

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
      return (numCalls%1000)==0;
    }
}

/* Local Variables:  */
/* mode: java         */
/* End:                   */
