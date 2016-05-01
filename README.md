# PureMVC Multicore with Pipes and Worker

This is multicore PureMVC where modules (or cores) communicate with each other by sending special messages throw pipe utilities. 

And you can create special module that run on separate worker instance (separated thread). If the worker feature does not supported this module will be running as regular PureMVC core. 

So that worker module can communicate with main application and other modules like regular module by using pipes - TOWRK and FROMWRK.

**This project is fully working example.**

It contains one main (shell) application and three modules (PureMVC cores):
- Main Application : this is a shell that controls and runs others cores, it has special pipe to receive message from any modules (STDMAIN), it also communicates with worker to get stage color (press 0) 
- Circle Button Module : this is dynamic PureMVC core that presented as a graphical interactive button, it instantiating in runtime (press SPACEBAR) and there may be multiple instance of it.
- Logger Module : this is a regular PureMVC core that contain a simple TextField and collect log information, it can receive messages from any other cores (single direction only) who are connected with him throw special pipe type (STDLOG)
- Calculator Module : this is a worker module (if worker is supported), it process data for other modules and communicate with them with special pipe type (TOWRK and FROMWRK)

###Main (shell) module application
The main core holds every module by registering special module mediators. Each module mediator must contains a reference to PipeAwareModule instance - the object that keeps module facade inside, and this facade is registered in static multitone storage-variable (by key). 

Every module must have special Junction that holds and register incomming pipes and tees, and also JunctionMediator which receives and processes notifications about pipe connections incoming from PipeAwareModule (who are sent from another modules mediators registered at main module). 
> **JunctionMediator is a entry point for incoming messages from others modules, this is a place where messages must be retranslated into internal notifications to be processed by that module.**

> **JunctionMediator is the place from where messages to others modules may be send by using junction.sendMessages(...). So to send back result you need to catch internal notification from module's entities and rework it to special Message (class).**

It starting with MainStartupCommand. First worker is being initialized and we are waiting for WorkerEvent.READY event, it fires any way if worker is supported or not. Then the rest of application is initialized.
