#!/bin/bash
jobs=`cat test.log`

echo $jobs

while read -r a b; do
    echo $a -- $b
action="unknown"
		if [ "$a" = 'M' ];
		then
				action="Modified"
		fi
		if [ "$a" = 'A' ];
		then
				action="added"
		fi
		if [ "$a" = 'D' ];
		then
				action="deleted"
		fi

		echo "{\"action\":\"$action\", \"uri\":\"$b\" }"
		

		
done <<<  "$jobs"

