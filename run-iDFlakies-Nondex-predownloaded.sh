#! /bin/bash

foldername=$1
commit=$(echo $foldername | awk -F- '{print $NF}')

handle_error() {
    echo "An error occurred on line $1 for $foldername" | tee -a /home/dx1/RIDE/regtest/repos/errlist
}

cd /home/dx1/RIDE/regtest/repos/$foldername
repo=$(git config --get remote.origin.url)

git checkout $commit

nmcli connection up $(find /home/dx1/Downloads/Surfshark-configurations/ -type f -wholename '*tcp.ovpn' | shuf -n1 | xargs -I {} basename {} .ovpn)

sleep 15

mvn edu.illinois.cs:idflakies-maven-plugin:2.0.1-SNAPSHOT:detect -Ddetector.detector_type=random-class-method -Ddt.randomize.rounds=10 -Ddt.detector.original_order.all_must_pass=false -fn 2>&1 | tee iDFlakies.log
for module in `find . -type f -wholename '*/.dtfixingtools/detection-results/flaky-lists.json'`; do jq -r --arg repo "$repo" --arg commit "$commit" --arg path "$(echo $module | sed 's|/.dtfixingtools/detection-results/flaky-lists.json||g;s|^./||g')" '.dts[] | [$repo, $commit, $path, .name, .type] | @csv' $module; done | tee iDFlakies-results.csv

mvn edu.illinois:nondex-maven-plugin:2.2.5-SNAPSHOT:nondex -fn 2>&1 | tee NonDex.log
for module in `find . -type f -wholename '*/.nondex/LATEST'`; do for round in `cat $module`; do if [[ -s "${module%/LATEST}/$round/failures" ]]; then cat "${module%/LATEST}/$round/failures"; fi; done | sed 's|#|.|g;s|^|'"\"$repo\",\"$commit\",\"$(echo $module | sed 's|/.nondex/LATEST||g;s|./||g')\""',"|g;s|$|","ID"|g'; done | sort -u | tee NonDex-results.csv

nmcli connection show --active | grep surfshark | awk '{print $1}' | xargs -n 1 nmcli connection down

echo $folername | tee -a /home/dx1/RIDE/regtest/repos/completed