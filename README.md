# el-gamal-onchain
A test plutus implementation of El Gamal encryption in Plutus. This repository contains the the basic functionality to verify keys in the El gamal signature scheme. 
This is a proof of concept repository to see what the boundaries for this encryption method using the Cardano Blockchain. The current state is a working El Gamal encryption scheme onchain.

# Structure
This repository contains all the modules in the `/src/` directory. There you can find basic utilities for generating plutus core, the onchain and offchain code and more. The code entails a basic give and grap script which locks funds with a public key. Only with an associated private key can the funds be unlocked. 

# TO DO (the order is not a priority indication)
1) Add PAB example
2) Add non-interacting proof of knowledge of a private key given a public key that can be used onchain
3) ...
