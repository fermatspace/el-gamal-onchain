# el-gamal-onchain
A test plutus implementation of El Gamal encryption in Plutus. This repository contains the the basic functionality to verify keys in the El gamal signature scheme. 
This is a proof of concept repository to see what the boundaries for this encryption method using the Cardano Blockchain. The current state is that this implementation
is limited to a keysize of 64 byte due to the limit the CBOR encoding has.

# Structure
This repository contains all the modules in the `/src/` directory. There you can find basic utilities for generating plutus core and the onchain code.

# TO DO
implement the encoding and decoding of arbitrary large integers into the onchain plutus types. Also do this for the generating the right datum and redeemer structure.
