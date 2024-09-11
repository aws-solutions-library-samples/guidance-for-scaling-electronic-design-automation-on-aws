#!/bin/bash

UUID=$(uuidgen)

# Make a working directory for the test. Use a UUID to avoid race conditions with other worker nodes.
if [ -d "/scratch" ]
then 
  WORKING_DIR=/scratch/${UUID}
  mkdir ${WORKING_DIR}
fi

# copy python tarbal from the flexcache onto our origin volume for building
cp /eda_tools/Python-3.8.4.tgz ${WORKING_DIR}

# cd into the working dorectory, untar the file and make python3.4 from source
cd ${WORKING_DIR}
tar xzf Python-3.8.4.tgz
cd Python-3.8.4
./configure --enable-optimizations --with-ensurepip=install
make

# Once that's done, write a success file to the root working directory and exit.
echo "Success!" > ../success.txt