#!/usr/bin/env bash

GETH=$HOME/projects/ethereum/go-ethereum/build/bin/geth
GETHOPTS="--dev --genesis ${PWD}/testnet/genesis.json --datadir ./testnet --mine --rpc --ipcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3"
$GETH $GETHOPTS console 2>> /tmp/digix_testnet.out

