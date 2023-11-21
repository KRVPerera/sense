#!/usr/bin/env bash

echo "Starting"
output=$(iotlab-experiment get -l --state Running)

ids=$(echo "$output" | jq '.items[].id')

# Iterate over each ID and stop the corresponding job
for job_id in $ids; do
    echo "Stopping Job ID ${job_id}"
    iotlab-experiment stop -i ${job_id}
    echo "Stopped job with ID: $job_id"
done

echo "done"