#! /bin/bash

commit=$(echo $PWD | awk -F- '{print $NF}')
repo=$(awk -F, -v commit=$commit '$2 == commit {print $1}' /home/dx1/Downloads/pr-data.csv | sort -u | xargs basename -a | head -n1)

git clean -fd
git checkout $commit

mvn edu.illinois.cs:idflakies-maven-plugin:2.0.1-SNAPSHOT:detect -Ddetector.detector_type=random-class-method -Ddt.randomize.rounds=10 -Ddt.detector.original_order.all_must_pass=false -fn -X -e 2&>1 | tee iDFlakies.log
for module in `find . -type f -wholename '*/.dtfixingtools/detection-results/flaky-lists.json'`; do jq -r --arg repo "$repo" --arg commit "$commit" --arg path "$(echo $module | sed 's|/.dtfixingtools/detection-results/flaky-lists.json||g;s|^./||g')" '.dts[] | [$repo, $commit, $path, .name, .type] | @csv' $module; done | tee iDFlakies-results.csv

mvn edu.illinois:nondex-maven-plugin:2.2.5-SNAPSHOT:nondex -X -e -fn 2>&1 | tee NonDex.log
for module in `find . -type f -wholename '*/.nondex/LATEST'`; do for round in `cat $module`; do if [[ -s "${module%/LATEST}/$round/failures" ]]; then cat "${module%/LATEST}/$round/failures"; fi; done | sed 's|#|.|g;s|^|'"\"$repo\",\"$commit\",\"$(echo $module | sed 's|/.nondex/LATEST||g;s|./||g')\""',"|g;s|$|","ID"|g'; done | sort -u | tee NonDex-results.csv
