#! /bin/bash

parts=(part_aa part_ab part_ac part_ad part_ae part_af part_ag part_ah part_ai part_aj)

for part in "${parts[@]}"; do
    tmux new-session -d -s $part "/home/dx1/RIDE/Regression-Testing $part"
done