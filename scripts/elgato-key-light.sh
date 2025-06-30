#! /bin/bash

ip="$1"

state="$(curl --location -s --request GET "http://$ip:9123/elgato/lights" | jq '.lights[0].on')"

curl --location --request PUT "http://$ip:9123/elgato/lights" \
--silent \
--header 'Content-Type: application/json' \
--data "{\"numberOfLights\": 1,\"lights\": [{\"on\": $((1 - $state)),\"brightness\": 80,\"temperature\": 180}]}" | jq '.lights[0].on'