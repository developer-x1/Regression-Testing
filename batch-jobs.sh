#! /bin/bash

parts=(new_part_aa new_part_ab new_part_ac new_part_ad new_part_ae new_part_af new_part_ag new_part_ah new_part_ai new_part_aj)

for part in "${parts[@]}"; do
    echo "$part"
    tmux new-session -d -s $part "/home/dx1/RIDE/Regression-Testing/runner.sh $part"
    echo "$part started!"
    sleep 10m
done
