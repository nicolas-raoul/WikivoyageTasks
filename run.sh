#!/bin/bash
# Download new dump if available, and build OxygenGuide/wikivoyage2osm if needed.

EXIT_IF_PRESENT=NO # Afters tests switch this to YES, otherwise regenerates every day.
OXYGENGUIDE=NO
WIKIVOYAGE2OSM=YES
OSMANDMAPCREATOR=YES

################################################################################
# Download the latest dump from the Wikivoyage server
################################################################################

cd ../OxygenGuide

# Find latest available dump at dumps.wikimedia.org
wget http://dumps.wikimedia.org/enwikivoyage/ -O /tmp/dump-dates.txt
LAST_DUMP_LINE=`grep Directory /tmp/dump-dates.txt | grep -v latest | tail -n 1`
LAST_DUMP_DATE=`echo $LAST_DUMP_LINE | sed -e "s/<\/a>.*//g" -e "s/.*>//g"`
echo "Last dump date: $LAST_DUMP_DATE"
DUMP=enwikivoyage-$LAST_DUMP_DATE-pages-articles.xml

# Check if already downloaded.
if [ -f $DUMP ];
then
  echo "Already present. Exiting."
  if [[ $EXIT_IF_PRESENT == "YES" ]]
    then
    exit
  fi
else
   echo "Not present yet. Generating."
fi

# Download.
wget http://dumps.wikimedia.org/enwikivoyage/$LAST_DUMP_DATE/$DUMP.bz2
bunzip2 $DUMP.bz2

################################################################################
# OxygenGuide
################################################################################

if [[ $OXYGENGUIDE == "YES" ]]
then

# Clean.
rm index.html
rm -rf articles
mkdir articles

# Run.
./generate_html_guide.py $DUMP

# Zip.
PRETTY_DATE=`echo $LAST_DUMP_DATE | sed 's/^\(.\{4\}\)/\1-/' | sed 's/^\(.\{7\}\)/\1-/'`
mkdir OxygenGuide_$PRETTY_DATE-a
mv index.html articles OxygenGuide_$PRETTY_DATE-a/
ZIPNAME="OxygenGuide_$PRETTY_DATE-a.zip"
zip -r $ZIPNAME OxygenGuide_$PRETTY_DATE-a/
echo "Done: $ZIPNAME"

# Upload to Sourceforge.
rsync -e ssh $ZIPNAME wvuploader,wikivoyage@frs.sourceforge.net:/home/frs/project/w/wi/wikivoyage/OxygenGuide/

fi

################################################################################
# wikivoyage2osm
################################################################################

if [[ $WIKIVOYAGE2OSM == "YES" ]]
then

# Put the dump (actually just a link) in the local directory.
ln -s ../$DUMP $DUMP

# Run.
cd ../wikivoyage2osm
./wikivoyage2osm.sh ../

# Rename.
CSV=enwikivoyage-$PRETTY_DATE-listings.csv
OSM=enwikivoyage-$PRETTY_DATE-listings.osm
mv $DUMP.csv $CSV
mv $DUMP.osm $OSM

# Upload to Sourceforge.
rsync -e ssh $CSV wvuploader,wikivoyage@frs.sourceforge.net:/home/frs/project/w/wi/wikivoyage/Listings-as-CSV/
rsync -e ssh $OSM wvuploader,wikivoyage@frs.sourceforge.net:/home/frs/project/w/wi/wikivoyage/Listings-as-OSM/

# Upload lists of invalid fields to http://en.wikivoyage.org/wiki/User:Nicolas1981/Syntax_checks
# TODO

fi

################################################################################
# OsmAndMapCreator
################################################################################

# Transform the OSM file to the OBF format for use in OsmAnd.
# TODO
