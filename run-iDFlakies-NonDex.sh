#! /bin/bash

repo=$1
commit=$2

git clone $repo
cd $(basename $repo .git)

git checkout $commit

mvn edu.illinois.cs:idflakies-maven-plugin:2.0.1-SNAPSHOT:detect -Ddetector.detector_type=random-class-method -Ddt.randomize.rounds=10 -Ddt.detector.original_order.all_must_pass=false -fn
for module in `find . -type f -wholename '*/.dtfixingtools/detection-results/flaky-lists.json'`; do jq -r --arg repo "$repo" --arg commit "$commit" --arg path "$(echo $module | sed 's|/.dtfixingtools/detection-results/flaky-lists.json||g;s|^./||g')" '.dts[] | [$repo, $commit, $path, .name, .type] | @csv' $module; done

mvn edu.illinois:nondex-maven-plugin:2.2.5-SNAPSHOT:nondex -fn
for module in `find . -type f -wholename '*/.nondex/LATEST'`; do for round in `cat $module`; do if [[ -s "${module%/LATEST}/$round/failures" ]]; then cat "${module%/LATEST}/$round/failures"; fi; done | sed 's|#|.|g;s|^|'"\"$repo\",\"$commit\",\"$(echo $module | sed 's|/.nondex/LATEST||g;s|./||g')\""',"|g;s|$|","ID"|g'; done | sort -u