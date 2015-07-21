package com.load.sample;

/**
 * Heuristics used to select
 * how data store operations
 * are forgotten.
 *
 * Heuristics implemented in
 * {@link HashAspect} and
 * {@link ListAspect}
 * 
 * @author jsinger
 */
public class ForgetfulHeuristic {

  /**
   * NONE - allow all put operations to occur properly
   */
  public static final int NONE = 2;
  
  /**
   * RANDOM_DROP_CURRENT - randomly prevent a 
   * put operation from occurring
   */
  public static final int RANDOM_DROP_CURRENT = 0;

  /**
   * RANDOM_DROP_OTHER - randomly null a different 
   * value when a put operation occurs
   */
  public static final int RANDOM_DROP_OTHER = 1;
  
  /**
   * turn a property String into the appropriate int
   * constant value.
   * @arg prop the property String specified with -Dforgetful.property
   * @return the equivalent int constant value, or NONE if no matching
   *               property found.
   */
  public static int fromString(String prop) {
    if (prop.equals("random"))
      return RANDOM_DROP_CURRENT;
    //if (prop.equals(""))
    //  return FOO;

    // default
    return NONE;
  }
}