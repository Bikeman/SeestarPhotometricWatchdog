# SeestarPhotometricWatchdog
A collection of simple scripts to perform on-the-fly photometry with the ZWO Seestar series telescopes in order to spot variabilities in real-time, e.g. for catching the erruption of T CrB.

For simplicity, this is intended to be run on a Raspberry Pi connected to the same network that the Seestar telescope is using, so that the code can access images generated by the Seestar via the SMB network share //Seestar/. 

This is work in progress. The intention was to get something up and running fast before T CrB errupts. The main usecase is to let the rtelescope record images as long as possible and even unattended. The code can be customized to then wake up the user or send messages out in case it detects a change in brightness that warrants human inspection.




