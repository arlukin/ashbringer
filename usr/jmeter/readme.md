# Using jMeter from a workstation, connecting to a remote node inside
# of a tet environment. The test node does the tests to real servers.

# On server node

## Install jmeter 3.2

    jmeter.sh 3.2

## Run jmeter server that can be controlled from a remote gui.

    jmeter-server -Djava.rmi.server.hostname=`ip route get 1 | awk '{print $NF;exit}'`


# On workstation:

## Install jmeter 3.2 on a server node

    jmeter.sh 3.2

## Control the jMeter server from system console

    jmeter -n -t script.jmx -R server1,server2,…

## Control the jMeter server from GUI

    # First change the remotehost in
    vi /opt/apache-jmeter-3.2/bin/user.properties

    jmeter