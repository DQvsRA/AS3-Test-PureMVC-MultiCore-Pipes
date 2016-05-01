# PureMVC Multicore with Pipes and Worker

This is multicore PureMVC where modules (or cores) communicate with each other by sending special messages throw pipe utilities. 

And you can create special module that run on separate worker instance (separated thread). If the worker feature does not supported this module will be running as regular PureMVC core. 

So that worker module can communicate with main application and other modules like regular module by using pipes - TOWRK and FROMWRK.

**This project is fully working example.**

It contains one main (shell) application and three modules (PureMVC cores):
- *Main Application* : this is a shell that controls and runs others cores, it has special pipe to receive message from any modules (STDMAIN), it also communicates with worker to get stage color (press 0) 
- *Circle Button Module* : this is dynamic PureMVC core that presented as a graphical interactive button, it instantiating in runtime (press SPACEBAR) and there may be multiple instance of it.
- *Logger Module* : this is a regular PureMVC core that contain a simple TextField and collect log information, it can receive messages from any other cores (single direction only) who are connected with him throw special pipe type (STDLOG)
- *Calculator Module* : this is a worker module (if worker is supported), it process data for other modules and communicate with them with special pipe type (TOWRK and FROMWRK)

###Main (shell) module application and short description
The main core holds every module by registering special module mediators. Each module mediator must contains a reference to PipeAwareModule instance - the object that keeps module facade inside, and this facade is registered in static multitone storage-variable (by key). 

Every module must have special Junction that holds and register incomming pipes and tees, and also JunctionMediator which receives and processes notifications about pipe connections incoming from PipeAwareModule (who are sent from another modules mediators registered at main module). 
> **JunctionMediator is a entry point for incoming messages from others modules, this is a place where messages must be retranslated into internal notifications to be processed by that module.**

> **JunctionMediator is the place from where messages to others modules may be send by using junction.sendMessages(...). So to send back result you need to catch internal notification from module's entities and rework it to special Message (class).**

This messages will also be received only by JunctionMediator of others modules whoes junction have appropriate pipes and tees. 

For *single connections* Junction must have a simple pipe and for *multiple connection* Junction must have special tees - TeeMerge for input or TeeSplit for output.
- **TeeMerge** is extend regular Pipe and may connect multiple incoming pipes to themself by using .connectInput(IPipeFitting) method or connect themself to pipe with .connect method (from Pipe).
- **TeeSplit** is implementing IPipeFitting interface and does collect all output pipes into array in which messages will be writing. 

Instead of using Tees you can use simple Pipes for one way communications for each sides. **We recommend you to use TeeMerge and TeeSplit.** And the use of pipes is very depends on methods of their connection. 

**Each pipe must have a channelID.** This is necessary for sending individual messages if output tee has a lot of connections.

Junction is registering this pipes with special names (or "channel") and appropriate type for Junction.INPUT or Junction.OUTPUT. And then this "channels" is used to catch messages by appling (or connecting) a listener to them (PipeListener which is like a pipe also implementing IPipeFitting). So Junction is adding listener for "channel" and listening for incoming messages on it (actually this listener is a final "pipe" where message is will be finally written).

**_Application starting with MainStartupCommand_**. First we register worker module mediator (CalculatorModuleMediator) where worker is being initialized and we are waiting for WorkerEvent.READY event from WorkerModule, it fires any way if worker is supported or not. 

Then the rest of the application is initialized and we are registering others modules, for example LoggerModuleMediator and MainJunctionMediator.

**_MainJunctionMediator_** is registering two input pipes - STDIN for standart input from any modules and separated "channel" for listening messages from worker module FROMWRK. Also it can send output messages to STDLOG, TOWRK and standart STDOUT for any modules who has same input "channel". When it has all the neccessary pipes and tees then it connects themself to WorkerModule and LoggerModule with:
>*sendNotification( MainFacade.CONNECT_MAIN_TO_LOGGER, junction );<br>
sendNotification( MainFacade.CONNECT_MAIN_TO_WORKER, junction );*

Which is handled by WorkerModuleMediator (CalculatorModuleMediator) and LoggerModuleMediator appropriate.

After Main is ready for action it send two notifications that will be rewriten to Messages inside MainJunctionMediator who is sending these messages to the modules for processing:
>*facade.sendNotification( MainFacade.GET_MODULE_LOGGER );<br>
facade.sendNotification( MainFacade.WORKER_GET_MAIN_COLOR );*

MainJunctionMediator is also waiting for responce (results of messages processing) by listening for incoming messages. Then it will apply the result internally.

You can manually run process of sending message (MainFacade.WORKER_GET_MAIN_COLOR) to worker by pressing 0 key on keyboard.

Also Main can run special command (try to press SPACEBAR): CreateCircleButtonModuleCommand.
This command will create CircleButtonModule and connect it to LoggerModule, to Main and to WorkerModule at runtime. And then CircleButtonModuleMediator ask that module to get visual entity to Main, by sending special message (see onRegister inside Mediator).

###CircleButtonModule
This module is creating core PureMVC who is working around interactive shape - circle button. It has his own Proxy for keeping data and Mediator to process action from that object. It's all initialized inside StartupCircleButtonCommand.
After it had been created his module (from CircleButtonModuleMediator to CircleButtonModule) is asking them to get this interactive shape which is then transfering to the Main where it is added to the stage. But before that action (send to Main) is launched CircleButtonJunctionMediator make request to the worker to get parameters for that button, it's done from CircleButtonMediator who is responsable for that button. And after WorkerModule finished calculation and send back message with results and it will be applyed to button only then this button will be send to Main throw pipe message. After message from WorkerModule has been processed this module (CircleButtonModule) will be disconnected from WorkerModule. But this module still can communicate with LoggerModule and send them messages, so when you click on CircleButton it send message to LogModule with click's statistics. 

LoggerJunctionMediator is registering two input pipes - one TeeMerge for regular messages from any modules (STDIN "channel") and another TeeMerge for messages from worker (FROMWRK "channel")

