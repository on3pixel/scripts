#!/bin/bash
# Small script developed to check website automatically and deactivate one plugin by time to see which one is causing trouble
WEBSITE="domain.com"

LIST="PLUGIN LIST 1 BY one"

for i in $LIST; do
wp plugin deactivate $i
RESULT=$(curl -si $WEBSITE | head -1)

echo $RESULT | grep "HTTP/1.1 500 Internal Server Error" > /dev/null 2>&1

if [[ $? != 0 ]]; then
   echo "Different result when deactivating plugin $i"
   echo $RESULT
   break
else
   echo "Same 500 Internal error"
   wp plugin activate $i
fi
done
