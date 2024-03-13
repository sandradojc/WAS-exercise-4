// personal assistant agent

/* Initial goals */
!start. // the agent has an initial goal to start

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: true (the plan is always applicable)
 * Body: creates the goal to create a personal-data LDP container, and the goal to suggest an activity to the user
*/
@start_plan
+!start : true <-
    .print("Hello world");
    !createPersonalDataContainer; // creates goal !createPersonalDataContainer
    !suggest_activity. // creates goal !suggest_activity

/* 
 * Plan for reacting to the addition of the goal !createPersonalDataContainer
 * Triggering event: addition of goal !createPersonalDataContainer
 * Context: true (the plan is always applicable)
 * Body: performs an action that creates an LDP container "personal-data", and informs all agents about it
*/
@create_container_plan
+!createPersonalDataContainer : true <-
    .print("Creating personal data container");
    createContainer("personal-data"); // performs an action that creates an LDP container "personal-data" using the Pod artifact
    .broadcast(tell, available_container("personal-data")). // broadcasts that there is an LDP container "personal-data"

/* 
 * Plan for reacting to the addition of the goal !suggest_activity
 * Triggering event: addition of goal !suggest_activity
 * Context: true (the plan is always applicable)
 * Body: reads the user's movie, running trail, and sleep data, and creates the goal to make a personalized activity suggestion
*/
@suggest_activity_plan
+!suggest_activity : true <-
    .wait(10000);
    readData("personal-data", "watchlist.txt", Movies); // performs an action that unifies Movies with an array of movies from the "personal-data" container
    .print("Read watchlist data");
    readData("personal-data", "trail.txt", TrailKilometers); // performs an action that unifies TrailKilometers with an array of running trails from the "personal-data" container
    .print("Read training data");
    readData("personal-data", "sleep.txt", HoursOfSleep); // performs an action that unifies HoursOfSleep with an array of sleep data from the "personal-data" container
    .length(HoursOfSleep, SleepLogsNum); // performs an action that unifies SleepLogsNum with the length of the array HoursOfSleep
    .nth(SleepLogsNum-1, HoursOfSleep, LastSleepLogStr); // performs an action that unifies LastSleepLogStr with the last element of the array HoursOfSleep
    .print("Read hours of sleep of last night: ", LastSleepLogStr);
    .term2string(LastSleepLog, LastSleepLogStr); // performs an action that unifies LastSleepLog with the numeric value of LastSleepLogStr
    !suggest_activity(LastSleepLog, TrailKilometers, Movies); // creates goal !suggest_activity(LastSleepLog, TrailKilometers, Movies)
    !suggest_activity. // creates goal !suggest_activity

/* 
 * Plan for reacting to the addition of the goal !suggest_activity(LastSleepLog, TrailKilometers, Movies)
 * Triggering event: addition of goal !suggest_activity(LastSleepLog, TrailKilometers, Movies)
 * Context: the user has slept for 7 hours or more
 * Body: suggests the longest known running trail for training
*/
@suggest_activity_high_sleep_quality_plan
+!suggest_activity(LastSleepLog, TrailKilometers, Movies) : LastSleepLog >= 7 <-
    .max(TrailKilometers, SuggestedTrail); // performs action that unifies SuggestedTrail with the greatest element in the array TrailKilometers
    .print("You are well-rested. Today you can run for ", SuggestedTrail, "km!").

/* 
 * Plan for reacting to the addition of the goal !suggest_activity(LastSleepLog, TrailKilometers, Movies)
 * Triggering event: addition of goal !suggest_activity(LastSleepLog, TrailKilometers, Movies)
 * Context: the user has slept for 5 hours or less
 * Body: suggests a movie to watch
*/
@suggest_activity_low_sleep_quality_plan
+!suggest_activity(LastSleepLog, TrailKilometers, Movies) : LastSleepLog <= 5 <-
    .nth(0, Movies, SuggestedMovie); // performs action that unifies SuggestedMovie with the first element in the array Movies
    .print("You could relax more. Today you can watch ", SuggestedMovie, "!").

/* 
 * Plan for reacting to the addition of the goal !suggest_activity(LastSleepLog, TrailKilometers, Movies)
 * Triggering event: addition of goal !suggest_activity(LastSleepLog, TrailKilometers, Movies)
 * Context: true (the plan is always applicable)
 * Body: suggests the shortest known running trail for training
*/
@suggest_activity_medium_sleep_quality_plan
+!suggest_activity(LastSleepLog, TrailKilometers, Movies) : true <-
    .min(TrailKilometers, SuggestedTrail); // performs action that unifies SuggestedTrail with the smallest element in the array TrailKilometers
    .print("You can train, but don't overdo it. Today you can run for ", SuggestedTrail, "km!").

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }