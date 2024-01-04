#!/bin/sh

HTTP="HTTP/1.1"
STATUS_OK="200 OK"
NL="\r\n"
LENGTH_HEADER="Content-Length"
TYPE_HEADER="Content-Type"
DISPOSITION_HEADER="Content-Disposition"

DROPFILE="image.png"
MIME="image/png"

PORTS_RANGE_START=8080
PORTS_RANGE_END=8080

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
	export MIME="plain/text"
}

function serve {
	file_content=$(cat $DROPFILE)
	content_length=$(wc -c < $DROPFILE | tr -d ' ')

	machine_ip=$(ifconfig | awk '$1 == "inet" && $2 !~ /^127./ {print $2}')
	port=$((RANDOM % ($PORTS_RANGE_END - $PORTS_RANGE_START + 1) + $PORTS_RANGE_START))
	url="http://$machine_ip:$port"

	# serving
	echo "Sending file on $url..." 
	qrencode -t UTF8 $url

	{
		echo -ne "$HTTP $STATUS_OK$NL"
		echo -ne "$LENGTH_HEADER: $content_length$NL"
		echo -ne "$TYPE_HEADER: $MIME$NL"
		echo -ne "$DISPOSITION_HEADER: attachment; filename=\"$DROPFILE\""
		echo -ne "$NL$NL"
		cat $DROPFILE
	} | nc -l $port > /dev/null

	#echo -ne "$HTTP $STATUS_OK$NL$HEADERS$NL$NL$file_content" | nc -l 8080
}

check $@
serve
