#!/bin/bash
check ()
{
NAME=`echo $IP |awk -F ";" '{print $1}' | sed 's/NODE=//g'`
IPN=`echo $IP | awk -F ";" '{print $2}'`
for (( ITERATION=1; ITERATION<=$ITERATIONS; ITERATION++ )); do
        INITIAL=`curl --insecure --connect-timeout 6 -s -H 'Content-Type: application/json' -d '{"jsonrpc": "2.0", "method": "icx_getLastBlock", "id": 1234}' http://$IPN/api/v3 | jq .result.height`
        if [ -z $INITIAL ]; then
                continue
        fi
        sleep 180;
        BLOCK=`curl --insecure --connect-timeout 6 -s -H 'Content-Type: application/json' -d '{"jsonrpc": "2.0", "method": "icx_getLastBlock", "id": 1234}' http://$IPN/api/v3 | jq .result.height`
        if [ -z $BLOCK ]; then
                continue
        else
                break
        fi
done
if [ -z $INITIAL ]; then
        echo "Node is down"
        curl -s -X POST https://api.telegram.org/bot$BOTNUMBER/sendMessage -d chat_id=$CHATID -d text="☠️ Node $NAME $IPN doesn't work. Please check http://$IPN/api/v1/status/peer"
else
        if [ -z $BLOCK ]; then
                echo "Node is down"
                curl -s -X POST https://api.telegram.org/bot$BOTNUMBER/sendMessage -d chat_id=$CHATID -d text="☠️ Node $NAME $IPN doesn't work. Please check http://$IPN/api/v1/status/peer"
        else
                if [ "$INITIAL" -eq "$BLOCK" ]; then
                        echo "Node is stop"
                        curl -s -X POST https://api.telegram.org/bot$BOTNUMBER/sendMessage -d chat_id=$CHATID -d text="☠️ Node $NAME $IPN stopped at block $BLOCK. Please check http://$IPN/api/v1/status/peer"
                fi
        fi
fi
}

CHATID=`cat ${PWD}/config.ini | grep -v "#" | grep "CHATID" | awk -F "=" '{print $2}'`
BOTNUMBER=`cat ${PWD}/config.ini | grep -v "#" | grep "BOTNUMBER" | awk -F "=" '{print $2}'`
PWD=$PWD
STATE=0
ITERATIONS=3
while true; do
	NODEIP=`cat ${PWD}/config.ini | grep -v "#" | grep "NODE"`
	for IP in $NODEIP
	do
		check $IP
	done
	sleep 180;
done


