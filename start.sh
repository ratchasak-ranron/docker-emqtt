#!/bin/bash

if [ "$NODE_IP" = "localhost" ]; 
then
	HOSTNAME="$(hostname)"
	NODE_IP="$(awk '/'$HOSTNAME'/ {print $1}' /etc/hosts)"
fi
sed -i 's/127.0.0.1/'"$NODE_IP"'/g' /emqttd/etc/vm.args
/emqttd/bin/emqttd start
sleep 5
if [ -z ${MASTER+x} ]; then
	echo '$MASTER' is not set.
else
	MASTER_IP="$(awk '/'$MASTER'/ {print $1}' /etc/hosts)"

	if [ "$MASTER_IP" != "" ]; then
		MASTER=$MASTER_IP
	fi
	/emqttd/bin/emqttd_ctl cluster join emqttd@$MASTER;
fi
sleep 10 && tail -f --retry /emqttd/log/*
