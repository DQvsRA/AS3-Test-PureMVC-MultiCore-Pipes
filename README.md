This is multicore PureMVC where modules (or cores) communicate with each other by sending special messages throw pipe utilities. 

And you can create special module that run on separate worker instance (separated thread). If the worker feature does not supported this module will be running as regular PureMVC core. 

So that worker module can communicate with main application and other modules like regular module by using pipes - TOWRK and FROMWRK.
