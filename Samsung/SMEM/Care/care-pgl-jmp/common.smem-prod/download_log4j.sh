#!/bin/bash
cd /tmp
rm -rf /tmp/log4j;
rm -rf  /tmp/apache-log4j-2.17.0-bin;
rm -rf /tmp/apache-log4j-2.17.0-bin.zip;
wget https://downloads.apache.org/logging/log4j/2.17.0/apache-log4j-2.17.0-bin.zip;
unzip /tmp/apache-log4j-2.17.0-bin.zip
cd /tmp/apache-log4j-2.17.0-bin
SOLR_EXT_PATH=/tmp/log4j;
mkdir -p /tmp/log4j
cp -r $SOLR_EXT_PATH /tmp/solr-libs
rm -rf $SOLR_EXT_PATH/log4j-1.2-api-2.16.0.jar
rm -rf $SOLR_EXT_PATH/log4j-core-2.16.0.jar
rm -rf $SOLR_EXT_PATH/log4j-api-2.16.0.jar
rm -rf $SOLR_EXT_PATH/log4j-slf4j-impl-2.16.0.jar
mv /tmp/apache-log4j-2.17.0-bin/log4j-1.2-api-2.17.0.jar $SOLR_EXT_PATH
mv /tmp/apache-log4j-2.17.0-bin/log4j-core-2.17.0.jar $SOLR_EXT_PATH
mv /tmp/apache-log4j-2.17.0-bin/log4j-api-2.17.0.jar $SOLR_EXT_PATH
mv /tmp/apache-log4j-2.17.0-bin/log4j-slf4j-impl-2.17.0.jar $SOLR_EXT_PATH
