#!/bin/sh

HTTP="HTTP/1.1"
STATUS_OK="200 OK"
NL="\r\n"
LENGTH_HEADER="Content-Length"
TYPE_HEADER="Content-Type"
DISPOSITION_HEADER="Content-Disposition"

PORTS_RANGE_START=8080
PORTS_RANGE_END=8100

function check {
	if [ $# -ne 1 ]; then
		echo "Error: Requires 1 file as argument" >&2
		exit 1
	fi

	if [ ! -f $1 ]; then
		echo "Error: $1 is not file" >&2
		exit 1
	fi

	if [ ! -r $1 ]; then
		echo "Error: No read permissions to $1" >&2
		exit 1
	fi

	export DROPFILE=$1
	export MIME=$(file --mime $1 | cut -d : -f 2 | tr -d ' ')
}

function read_config {
	if [ ! -r $1 ]; then
		return
	fi
	
	. $1
	
	if [ -n $PORTS_RANGE_START ]; then export PORTS_RANGE_START=$PORTS_RANGE_START; fi
	if [ -n $PORTS_RANGE_END ]; then export PORTS_RANGE_END=$PORTS_RANGE_END; fi
	if [ -n $USE_FILENAME_URL ]; then export USE_FILENAME_URL=$USE_FILENAME_URL; fi
	if [ -n $USE_QR ]; then export USE_QR=$USE_QR; fi
}

function get_port {
	port=$((RANDOM % ($PORTS_RANGE_END - $PORTS_RANGE_START + 1) + $PORTS_RANGE_START))

	if [ -z "$(netstat -an | grep "LISTEN" | grep "*.$port")" ]; then
		echo $port;
	else
		echo $(get_port)
	fi
}


function serve {
	file_name=$(basename $DROPFILE)
	file_content=$(cat $DROPFILE)
	content_length=$(wc -c < $DROPFILE | tr -d ' ')

	machine_ip=$(ifconfig | awk '$1 == "inet" && $2 !~ /^127./ {print $2}')
	port=$((RANDOM % ($PORTS_RANGE_END - $PORTS_RANGE_START + 1) + $PORTS_RANGE_START))
	url="http://$machine_ip:$port"

	if [ $USE_FILENAME_URL -eq 1 ]; then
		url="$url/$file_name"
	fi

	# serving
	echo "Sending file on $url..." 

	if [ $USE_QR -eq 1 ]; then
		qrencode -t UTF8 $url
	fi

	{
		echo -ne "$HTTP $STATUS_OK$NL"
		echo -ne "$LENGTH_HEADER: $content_length$NL"
		echo -ne "$TYPE_HEADER: $MIME$NL"
		echo -ne "$DISPOSITION_HEADER: attachment; filename=\"$file_name\""
		echo -ne "$NL$NL"
		cat $DROPFILE
	} | nc -l $port > /dev/null
}

check $@
read_config /etc/shelldrop/config
read_config ~/.config/shelldrop/config
#serve

port=$(get_port)

echo $port
