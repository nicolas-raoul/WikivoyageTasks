#!/bin/bash
#
# Install the Wikivoyage transformation scripts.
# Intended to be run by Nicolas on a Wikimedia Labs server.

sudo apt-get install realpath # Package necessary for wikivoyage2osm

cd
git clone https://github.com/nicolas-raoul/WikivoyageTasks
git clone https://github.com/nicolas-raoul/OxygenGuide
git clone https://github.com/nicolas-raoul/wikivoyage2osm

CRONSCRIPT=`mktemp`
echo '#!/bin/sh
#
# Run OxygenGuide daily.
# Most of the time it will detect that there is no new dump, and exit.
#
cd /home/nicolas-raoul/WikivoyageTasks/
./run.sh' \
> $CRONSCRIPT
sudo cp $CRONSCRIPT /etc/cron.daily/wikivoyage
