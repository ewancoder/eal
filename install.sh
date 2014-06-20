#!/bin/bash

#prepare new file
touch hexec.sh
while read p; do
    if ! [[ ${p:0:1} == "#" ]] && ! [[ ${p:0:3} == "if " ]] && ! [[ ${p:0:3} == "fi " ]] && ! [[ ${p:0:4} == "for " ]] && ! [[ ${p:0:4} == "else" ]] && ! [[ ${p:0:4} == "done" ]]; then
        echo -e "until $p; do\n\tmess -w \"Error occured while executing command '$p'. Retry? [RETURN / Ctrl+C]\"\ndone" >> herr.sh
    fi
done <heal.sh
