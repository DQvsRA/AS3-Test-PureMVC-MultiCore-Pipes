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

Each pipe must have a channelID.

Junction is registering this pipes with special names (or "channel") and appropriate type for Junction.INPUT or Junction.OUTPUT. And then this "channels" is used to catch messages by appling (or connecting) a listener to them (PipeListener which is like a pipe also implementing IPipeFitting). So Junction is adding listener for "channel" and listening for incoming messages on it (actually this listener is a final "pipe" where message is will be finally written).

Application starting with MainStartupCommand. First we register worker module mediator (CalculatorModuleMediator) where worker is being initialized and we are waiting for WorkerEvent.READY event from WorkerModule, it fires any way if worker is supported or not. 

Then the rest of the application is initialized and we are registering others modules, for example LoggerModuleMediator and MainJunctionMediator.

MainJunctionMediator is registering two input pipes - STDIN for standart input from any modules and separated "channel" for listening messages from worker module FROMWRK. Also it can send output messages to STDLOG, TOWRK and standart STDOUT for any modules who has same input "channel".

LoggerJunctionMediator is registering two input pipes - one TeeMerge for regular messages from any modules (STDIN "channel") and another TeeMerge for messages from worker (FROMWRK "channel")

