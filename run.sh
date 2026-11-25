#!/bin/sh
# Compile and run PIZZA PRIZE (requires JDK 17 or newer)
cd "$(dirname "$0")"
rm -rf out
javac -encoding UTF-8 -d out $(find src -name "*.java") || exit 1
java -cp out com.pizzaprize.Main "${1:-8080}"
