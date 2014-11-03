#!/bin/bash
ScriptLoc="$(dirname $0)/lib"
source ${ScriptLoc}/lib_colors.sh

curl -silent http://www.quotedb.com/quote/quote.php?action=random_quote | tail -2 | sed -e :a -e 's/<[^>]*>//g;/</N;//ba' | cut -d \' -f2 | sed s/More\ quotes\ from\ /$(printf "${White}")\-\ /g | sed s/\`/\'/g
