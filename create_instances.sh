#! /bin/bash
image="CC7 Base - x86_64 [2015-06-12]"
keypair="timslaptop"

# Only argument is the list of hostname extensions
# to use when starting instances. Usually use a number
# like 2 3 4 5 6 to start five instances.
for i in $*; do
    nova boot --flavor m1.medium --image "$image" --key-name "$keypair" --availability-zone cern-geneva-a --user-data "configure-workers.sh" thead-everware$i
done;
