#!/bin/bash
# Install jMeter on mac

# Set from cmd line parameter
JMETER_VERSION="$*"
if [ ! "${JMETER_VERSION}" == "3.1" ]  && [ ! "${JMETER_VERSION}" == "3.2" ] && [ ! "${JMETER_VERSION}" == "3.3" ] ; then
    echo "Need argument with version 3.1, 3.2 or 3.2"
    exit 1
fi

# Get dir of jmeter script folder
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

JMETER_OPTS=""

TEST_FILE=test.jmx
TEST_OUTPUT=jmeter-results.csv

USER_PROPERTIES=${SCRIPT_DIR}/user.properties
JMETER_HOME=/opt/apache-jmeter-${JMETER_VERSION}
JMETER_DOWNLOAD_URL=https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
JMETER_PLUGINS_URL=https://repo1.maven.org/maven2/kg/apc/

if [ ! -d "${JMETER_HOME}" ]; then
    echo "Download apache-jmeter-${JMETER_VERSION}.tgz"
    mkdir -p ${JMETER_HOME}
    curl -L --silent ${JMETER_DOWNLOAD_URL} | tar -xz --strip=1 -C ${JMETER_HOME}
fi

if [ -d "${JMETER_HOME}" ]; then
    if [ ! -f "${JMETER_HOME}/lib/ext/plugins-manager.jar" ]; then
        echo "Install jmeter plugins"
        # https://jmeter-plugins.org/install/Install/
        # https://jmeter-plugins.org/wiki/PluginsManagerAutomated/

        curl -L --silent -o ${JMETER_HOME}/lib/ext/plugins-manager.jar https://jmeter-plugins.org/get/
        curl -L --silent -o ${JMETER_HOME}/lib/cmdrunner-2.0.jar http://search.maven.org/remotecontent?filepath=kg/apc/cmdrunner/2.0/cmdrunner-2.0.jar
        java -cp ${JMETER_HOME}/lib/ext/plugins-manager.jar org.jmeterplugins.repository.PluginManagerCMDInstaller


        cd ${JMETER_HOME}/bin
        ${JMETER_HOME}/bin/PluginsManagerCMD.sh status
        ${JMETER_HOME}/bin/PluginsManagerCMD.sh install jpgc-standard=2.0
        ${JMETER_HOME}/bin/PluginsManagerCMD.sh install jpgc-json=2.6
        ${JMETER_HOME}/bin/PluginsManagerCMD.sh install jpgc-autostop
        ${JMETER_HOME}/bin/PluginsManagerCMD.sh install jpgc-sense
        ${JMETER_HOME}/bin/PluginsManagerCMD.sh status
    fi
fi

# Setup symbolic link
[ -f "/usr/local/bin/jmeter" ] && rm /usr/local/bin/jmeter
echo "Configure symbolic link /usr/local/bin/jmeter"
ln -s ${JMETER_HOME}/bin/jmeter /usr/local/bin/jmeter

[ -f "/usr/local/bin/jmeter-server" ] && rm /usr/local/bin/jmeter-server
echo "Configure symbolic link /usr/local/bin/jmeter-server"
ln -s ${JMETER_HOME}/bin/jmeter-server /usr/local/bin/jmeter-server

[ -f "/usr/local/bin/jmeter${JMETER_VERSION}" ] && rm /usr/local/bin/jmeter${JMETER_VERSION}
echo "Configure symbolic link /usr/local/bin/jmeter${JMETER_VERSION}"
ln -s ${JMETER_HOME}/bin/jmeter /usr/local/bin/jmeter${JMETER_VERSION}

[ -f "/usr/local/bin/jmeter-server${JMETER_VERSION}" ] && rm /usr/local/bin/jmeter-server${JMETER_VERSION}
echo "Configure symbolic link /usr/local/bin/jmeter-server${JMETER_VERSION}"
ln -s ${JMETER_HOME}/bin/jmeter /usr/local/bin/jmeter-server${JMETER_VERSION}

echo "Create user.properties file"
cp ${USER_PROPERTIES} ${JMETER_HOME}/bin/user.properties

jmeter -n -t /opt/ashbringer/usr/jmeter/test.jmx
rm results.csv
rm jmeter.log
