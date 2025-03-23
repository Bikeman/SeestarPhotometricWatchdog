#!/bin/bash

echo "you should hear some klaxon sound now, "
echo "if not, check your sound output configuation"
echo "(HDMI, ext speaker jack) and volume settings"

ogg123 snd/klaxon.ogg snd/klaxon.ogg snd/klaxon.ogg
