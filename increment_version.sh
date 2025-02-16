#!/bin/bash
VERSION_FILE="version.txt"
VERSION=$(cat $VERSION_FILE)
NEW_VERSION=$(echo $VERSION | awk -F. -v OFS=. '{$NF += 1 ; print}')
echo $NEW_VERSION > $VERSION_FILE
echo $NEW_VERSION
