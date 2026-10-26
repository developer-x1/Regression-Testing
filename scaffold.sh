#! /bin/bash

tail -n+2 pr-data.csv | awk -F, '{print $1 " " $2}' | sort -u | while read -r repo commit; do 
    sed "s|REPO|$repo|g;s|FOLDERNAME|$(basename $repo .git)|g;s|COMMIT|$commit|g" Dockerfile | tee Dockerfile-Scaffold/$(dirname $repo | xargs basename):$(basename $repo .git):$commit:Dockerfile
done