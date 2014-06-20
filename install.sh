#!/bin/bash
prepare() {
    rm -f $2
    while read -r p; do
        if ! [[ "$p" == "" ]] && ! [[ ${p:0:1} == "#" ]] && ! [[ ${p:0:3} == "if " ]] && ! [[ ${p:0:2} == "fi" ]] && ! [[ ${p:0:4} == "for " ]] && ! [[ ${p:0:4} == "else" ]] && ! [[ ${p:0:4} == "done" ]]; then
            echo  "until $p; do" >> $2
            echo -e "\tmess -q \"Eror occured. Retry? (y/n)\"\n\tread ans" >> $2
            echo '    if [ "$ans" == "n" ] || [ "$ans" == "N" ]; then' >> $2
            echo -e "\t\tbreak\n\tfi\ndone" >> $2
        else
            echo $p >> $2
        fi
    done <$1
}

prepare heal.sh herr.sh
prepare eal.sh err.sh
prepare peal.sh perr.sh
