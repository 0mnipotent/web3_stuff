#!/bin/bash

# Load Web3.js library
web3=`npm list --depth=0 | grep web3`
if [ -z "$web3" ]
then
    npm install web3
fi

# Set the contract address to query
contract_address="0x1234567890abcdef"

# Query the contract address using the web3.eth.getCode method
code=`node -p "web3.eth.getCode('$contract_address')"`

# Print the contract code
echo $code
