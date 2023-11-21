#!/usr/bin/env bash

echo "Starting"
experiment_output=$(iotlab-experiment get -e)

id_list=$(echo "$experiment_output" | jq '.Running[]')

# Iterate over each ID and stop the corresponding job
for job_id in $id_list; do
    echo "Stopping Job ID ${job_id}"
    iotlab-experiment stop -i ${job_id}
    echo "Stopped job with ID: $job_id"
done

echo "done"