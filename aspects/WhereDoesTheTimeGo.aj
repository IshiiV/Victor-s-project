package com.load.sample;

import java.util.logging.*;
import java.io.IOException;
import java.io.StringWriter; 
import java.io.PrintWriter;

public aspect WhereDoesTheTimeGo {
	
	pointcut methodsOfInterest(): call(* java.util.HashMap.*(..)) && !within(WhereDoesTheTimeGo);
	
	private int nesting = 0;
	
	private Logger logger = null;
	
	
	/**
	 * singleton style initialisation for logging.
	 */
	private void initLogger(){
		if(logger == null){
			//Handler consoleHandler = null;
			Handler fileHandler = null;
			try{
				//consoleHandler = new ConsoleHandler();
				fileHandler = new FileHandler("test.txt", false);
				logger = Logger.getLogger("WhereDoesTheTimeGo");
				
			//	logger.addHandler(consoleHandler);
				logger.addHandler(fileHandler);
				//consoleHandler.setLevel(Level.ALL);
				fileHandler.setLevel(Level.ALL);
				logger.setLevel(Level.ALL);
			}
			catch(IOException exception){
				logger.log(Level.SEVERE, "Error occur in FileHandler.", exception);
			}
		}
	}
	
	Object around(): methodsOfInterest() {
		initLogger();
		nesting++;
		long stime=System.currentTimeMillis();
		Object o = proceed();
		long etime=System.currentTimeMillis();
		nesting--;
		StringBuilder info = new StringBuilder();
		for (int i=0;i<nesting;i++) {
			info.append(" ");
		}
		info.append(thisJoinPoint+" took "+(etime-stime)+"ms\n");
		
		StringWriter sw = new StringWriter();
		new Throwable().printStackTrace(new PrintWriter(sw));
		info.append(sw.toString());
		logger.log(Level.FINE,info.toString());
		//System.out.println(info.toString());
		return o;
	}
	/*
	
	
	pointcut methodsOfInterest(): execution(* java.util.HashMap.*(..)) && !within(WhereDoesTheTimeGo);
	
	after() returning() : methodsOfInterest() {
		System.out.println(" World!");
		
	
		
	}*/
	

}
