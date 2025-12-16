#!/bin/sh
GRADLE_APP_HOME="$(dirname "$0")"
exec java -classpath "$GRADLE_APP_HOME/gradle/wrapper/gradle-wrapper.jar" org.gradle.wrapper.GradleWrapperMain "$@"
