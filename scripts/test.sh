#!/bin/sh

JAVAOPTS="-Ddebug=true -Dorg.slf4j.simpleLogger.defaultLogLevel=info -Dxspec.version=${xspec.version}"

CP=$CLASSPATH
for j in ${project.build.directory}/lib/*.jar; do
    CP=$CP:$j
done

# use the catalog which maps external resources used in tests to local documents

java $JAVAOPTS -cp $CP -Dcatalog=${project.basedir}/test/catalog.xml org.apache.tools.ant.Main $@
