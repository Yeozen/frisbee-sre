#!/bin/bash

echo "Starting Dual-App Traffic Simulation... [CTRL+C] to stop."

# Targets
APP_SOURCE="http://localhost:30000/health"
APP_slow="http://localhost:30000/slow"
APP_crash="http://localhost:30000/crash"


while true; do

  BATCH_SIZE=$(( ( RANDOM % 10 ) + 1 ))
  
  for ((i=1; i<=BATCH_SIZE; i++)); do
    curl -s "$APP_SOURCE" > /dev/null &
    curl -s "$APP_slow" > /dev/null &
    curl -s "$APP_crash" > /dev/null &
  done
  wait 

  
done