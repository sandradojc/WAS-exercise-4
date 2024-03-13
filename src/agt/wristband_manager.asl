// wristband manager agent

/* Initial beliefs */
sleep_data_counter(0). // the agent believes that no sleep data have been collected yet
trail_data_counter(0). // the agent believes that no running trail data have been collected yet

/* Initial goals */
!start. // the agent has an initial goal to start

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: true (the plan is always applicable)
 * Body: greets the world 
*/
@start_plan
+!start : true <-
    .print("Hello world").    

/* 
 * Plan for reacting to the addition of the belief available_container
 * Triggering event: addition of belief available_container
 * Context: true (the plan is always applicable)
 * Body: creates the goal to monitor user's sleep and training
*/
@available_container_plan
+available_container(ContainerName) : true <-
    !!monitor_sleep; // creates goal !monitor_sleep
    !!monitor_training. //creates goal monitor_training

/* 
 * Plan for reacting to the addition of the goal !monitor_sleep
 * Triggering event: addition of the goal !monitor_sleep
 * Context: the agent believes that it has collected sleep data in the past (Counter>0) or not (Counter=0)
 * Body: every 4000ms, simulates the monitoring of the user's sleep hours, and creates the goal of publising the sleep data to an LDP container
*/
@monitor_sleep_plan
+!monitor_sleep : sleep_data_counter(Counter) <-
    .random([5,6.5,7], HoursOfSleep); // performs an action that unifies HoursOfSleep with a random value in [5,6.5,7]
    .print("Monitored hours of sleep for day ", Counter, ": ", HoursOfSleep);
    !publish_sleep_data(HoursOfSleep, Counter); // creates goal !publish_sleep_data
    .wait(4000);
    -+sleep_data_counter(Counter+1); // updates the belief sleep_data_counter
    !!monitor_sleep. // creates goal !monitor_sleep

/* 
 * Plan for reacting to the addition of the goal !monitor_training
 * Triggering event: addition of the goal !monitor_training
 * Context: the agent believes that it has collected running trail data in the past (Counter>0) or not (Counter=0)
 * Body: every 4000ms, simulates the monitoring of the distances of the user's running trails, and creates the goal of publising the trail data to an LDP container
*/
@monitor_training_plan
+!monitor_training : trail_data_counter(Counter) <-
    .random([3,5.5], TrailKilometers); // performs an action that unifies TrailKilometers with a random value in [3,5.5]
    .print("Monitored kilometers of training for day ", Counter, ": ", TrailKilometers);
    !publish_trail_data(TrailKilometers, Counter); // creates goal !publish_trail_data
    .wait(4000);
    -+trail_data_counter(Counter+1); // updates the belief trail_data_counter
    !!monitor_training. // creates goal !monitor_training

/* 
 * Plan for reacting to the addition of the goal !publish_sleep_data
 * Triggering event: addition of the goal !publish_sleep_data
 * Context: the agent believes that it has collected and published sleep data in the past, and there is an available LDP container
 * Body: performs an action that updates sleep data in the LDP container within a file sleep.txt
*/
@publish_sleep_data_plan
+!publish_sleep_data(HoursOfSleep, Index) : Index>0 & available_container(ContainerName) <-
    .print("Publishing hours of sleep");
    updateData(ContainerName, "sleep.txt", [HoursOfSleep]). // performs an action that updates sleep data in the LDP container within a file sleep.txt

/* 
 * Plan for reacting to the addition of the goal !publish_sleep_data
 * Triggering event: addition of the goal !publish_sleep_data
 * Context: the agent believes that it has never collected and published sleep data in the past, and there is an available LDP container
 * Body: performs an action that publishes sleep data in the LDP container within a new file sleep.txt
*/
@publish_sleep_data_first_time_plan
+!publish_sleep_data(HoursOfSleep, Index) : available_container(ContainerName) <-
    .print("Publishing hours of sleep");
    publishData(ContainerName, "sleep.txt", [HoursOfSleep]). // performs an action that publishes sleep data in the LDP container within a new file sleep.txt

/* 
 * Plan for reacting to the addition of the goal !publish_trail_data
 * Triggering event: addition of the goal !publish_trail_data
 * Context: the agent believes that it has collected and published trail data in the past, and there is an available LDP container
 * Body: performs an action that updates trail data in the LDP container within a file trail.txt
*/
@publish_trail_data_plan
+!publish_trail_data(TrailKilometers, Index) : Index>0 & available_container(ContainerName) <-
    .print("Publishing trail kilometers");
    updateData(ContainerName, "trail.txt", [TrailKilometers]). // performs an action that updates trail data in the LDP container within a file trail.txt

/* 
 * Plan for reacting to the addition of the goal !publish_trail_data
 * Triggering event: addition of the goal !publish_trail_data
 * Context: the agent believes that it has never collected and published trail data in the past, and there is an available LDP container
 * Body: performs an action that publishes trail data in the LDP container within a new file trail.txt
*/
@publish_trail_data_first_time_plan
+!publish_trail_data(TrailKilometers, Index) : available_container(ContainerName) <-
    .print("Publishing trail kilometers");
    publishData(ContainerName, "trail.txt", [TrailKilometers]). // performs an action that publishes trail data in the LDP container within a new file trail.txt

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }