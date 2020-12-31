---
title: Android Dev
linktitle: Android Dev
description: Setup Android for development of B00M app.
date: 2020-19-01
publishdate: 2020-19-01
lastmod: 2020-19-01
categories: [developer tools]
keywords: [android, tools]
menu:
  docs:
    parent: "tools"
    weight: 50
weight: 50
sections_weight: 50
draft: false
aliases: []
toc: true
---

B00M uses an Android app for provisioning of devices and display of data.  Get started with Android development for B00M. 

## Brief 
Setup Android & Gradle for development without Android Studio or any other IDE. 

## Download

```bash
tools/android/sdk // brings up sdk manager to install platform, build-tools and support libraries.
```
## Create

The following command creates a new android project named trackgrpc with package name org.trackgrpc.app with path ./trackgrpc with an Activity called Track using Android Gradle Plugin version 2.3.0 (which requires minimum Gradle version 3.3) for a target Android SDK version 25.  

```
tools/android create project -n tracapp -k org.trac.app -p ./tracapp -a Trac -g -v 3.3.0 -t android-28 
```
For more information on Android create try:
```
tools/android [global options] create [action options]
tools/android create -h // HELP!!
```
Need to add Google's maven repo to build.gradle like so:

{{< code file=build.gradle >}}
allprojects {
      repositories {
         google()
         jcenter()
      }
  }
{{< /code >}}
See [Google's maven repo](https://stackoverflow.com/questions/50279792/could-not-find-com-android-tools-buildaapt23-2-0)

Comment out `sdk.dir` in `local.properties`.

Offline:
maven-metadata.xml
```
    > Failed to list versions for io.grpc:grpc-core.
         > Unable to load Maven meta-data from https://jcenter.bintray.com/io/grpc/grpc-core/maven-metadata.xml.
            > Could not HEAD 'https://jcenter.bintray.com/io/grpc/grpc-core/maven-metadata.xml'.
               > jcenter.bintray.com
    > Failed to list versions for io.grpc:grpc-core.
         > Unable to load Maven meta-data from https://dl.google.com/dl/android/maven2/io/grpc/grpc-core/maven-metadata.xml.
            > Could not get resource 'https://dl.google.com/dl/android/maven2/io/grpc/grpc-core/maven-metadata.xml'.
               > Could not GET 'https://dl.google.com/dl/android/maven2/io/grpc/grpc-core/maven-metadata.xml'.
                  > dl.google.com
```

## Gradle


### settings.gradle 

Include sub-projects in the build using an entry in settings.gradle:
  include app

### build.gradle 

Each project/subproject has it's own build.gradle file. Place each application (sub-project) dependencies where they belong - in the individual sub-project build.gradle files

### plugins

Binary plugins that have been published as external jar files can be added to a project by adding the plugin to the build script classpath and then applying the plugin. 

{{< code file="build.gradle" >}}
buildscript {
  repositories {
    jcenter()
  }
  dependencies {
         classpath 'me.tatarka:gradle-retrolambda:3.4.0'
         classpath 'me.tatarka.retrolambda.projectlombok:lombok.ast:0.2.3.a2'
     }
     // Exclude the version that the android plugin depends on.
     configurations.classpath.exclude group: 'com.android.tools.external.lombok'
}

apply plugin: 'me.tatarka.retrolambda'
{{< /code >}}

### gradlew

```bash
./gradlew -v // looks at ./gradle/wrapper/gradle-wrapper.properties for distributionURL field - will download if not already in cache ~/.gradle/wrapper/dists/
./gradlew assembleDebug
./gradlew assembleBuild

./gradlew build -PskipCodegen=true -p okhttp/
./gradlew build -p protobuf-lite/
./gradlew build -p grpc-stub/
```

### gomobile

```bash
go get golang.org/x/mobile/cmd/gomobile
gomobile init --ndk=/home/sridhar/dev/android/ndk-bundle
gomobile build -target=android golang.org/x/mobile/example/basic

~/dev/android/platform-tools/adb install -rsg basic.apk
```

## grpc-java

```bash
git clone github.com/grpc/grpc-java
git checkout v1.19.0 // release tag - matches with grpc releases
./gradlew build // use --stacktrace option to diagnose errors
cd examples/android/routeguide
./gradlew build // creates generated files and apk

Generated files:
app/build/generated/source/proto/debug/grpc/io/grpc/routeguideexample/

```
Must use java-8 as java-11 will throw this error: 

> A problem occurred configuring project ':app'.
   > Failed to notify project evaluation listener.
   > Could not initialize class com.android.sdklib.repository.AndroidSdkHandler

when trying to run:
```
cd examples/android/routeguide
../../gradlew build
```
Changing to java-8 will fix this problem:
```
echo $JAVA_HOME // /usr/lib/jvm/java-8-openjdk-amd64
```
examples/android/routeguide/app/build.gradle lists compileSdkVersion / targetSdkVersion 27 but needs Android SDK Build Tools 26.0.2. Since Android Gradle plugin 3.0.0 onwards the buidtools version is automatically selected. If you don't have the automatically selected version of buildtools, may get error:

> You have not accepted the license agreements of the following SDK components:
  [Android SDK Build-Tools 26.0.2].

Once above errors are rectified, output app-debug.apk can be found in examples/android/routeguide/build/outputs/apk/debug

## gmaps

In `src/main/AndroidManifest.xml`:

```

```

## Gotchas 
The protobuf runtime (protobuf-java) should never be older than the protoc version. Old generated code works with newer protobuf runtimes, but newer generated code may use features not present in old protobuf runtimes.

[Duplicate dependencies](https://stackoverflow.com/questions/49837344/program-type-already-present-android-support-v4-app-backstackrecord/49837806)

## References ## 
+ [Gradle plugin for Android](https://developer.android.com/studio/releases/gradle-plugin.html)
+ [Proguard shrink code](https://developer.android.com/studio/build/shrink-code.html) 
+ [Gradle organzing build](https://docs.gradle.org/current/userguide/organizing_build_logic.html#sec:build_script_external_dependencies)
+ [Gradle multi-project builds](https:/https://docs.gradle.org/current/userguide/multi_project_builds.html/)
+ [Android Support Library](https://developer.android.com/topic/libraries/support-library/setup)
+ [Android Gradle Plugin](https://developer.android.com/studio/releases/gradle-plugin)


## Version Table

| App | Java | Gradle | Android Gradle Plugin | Android Build Tools | Android Platform | Protobuf Gradle Plugin |
|------------|---------|-------|-------|--------|----|-------|
| routeguide | java-10 | 4.9.0 | 3.0.1 | 26.0.2 | 27 | 0.8.5 |
| simplelink | java-10 | 4.6.0 | 3.1.4 | 28.0.3 | 26 |
| trac | java-10 | 4.9 | 3.0.1 | 26.0.2 | 27 | 0.8.5 |
