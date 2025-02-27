#!/bin/sh

if [ -f "/init" ]; then
    /init &
fi

wget -O agent.jar $DOCKER_SWARM_PLUGIN_JENKINS_AGENT_JAR_URL && java -jar agent.jar -jnlpUrl $DOCKER_SWARM_PLUGIN_JENKINS_AGENT_JNLP_URL -secret $DOCKER_SWARM_PLUGIN_JENKINS_AGENT_SECRET -noReconnect -workDir /home/jenkins
