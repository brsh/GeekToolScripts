#!/bin/bash
curl -silent http://www.quotedb.com/quote/quote.php?action=random_quote | tail -2 | sed -e :a -e 's/<[^>]*>//g;/</N;//ba' | cut -d \' -f2 | sed s/More\ quotes\ from\ /$(printf "\e[0;37m")\-\ /g | sed s/\`/\'/g
