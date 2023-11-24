#!/usr/bin/env bash

create_stopper_script() {
    local script_name=$(basename "$0")
    local stopper_name="${script_name}_stopper.sh"
    local stopper_path="${SENSE_STOPPERS_HOME}/${stopper_name}"

    echo "Creating '${stopper_path}' script"
    echo "# Stopper script generated by ${script_name}" >"${stopper_path}"

    for job_id in "$@"; do
        echo "JOB_STATE=\$(iotlab-experiment wait --timeout 30 --cancel-on-timeout -i ${job_id} --state Running,Finishing,Terminated,Stopped,Error)" >>"${stopper_path}"
        echo "if [ \"\$JOB_STATE\" = '\"Running\"' ]; then" >>"${stopper_path}"
        echo "    echo \"Stopping Job ID ${job_id}\"" >>"${stopper_path}"
        echo "    iotlab-experiment stop -i ${job_id}" >>"${stopper_path}"
        echo "else" >>"${stopper_path}"
        echo "    echo \"Job ID ${job_id} is not in 'Running' state. Current state: \$JOB_STATE\"" >>"${stopper_path}"
        echo "fi" >>"${stopper_path}"
        echo "" >>"${stopper_path}" # Adds a newline for readability
    done
}

submit_border_router_job() {
    local border_router_node="$1"

    local border_router_job_json=$(iotlab-experiment submit -n ${BORDER_ROUTER_EXE_NAME} -d ${EXPERIMENT_TIME} -l ${SENSE_SITE},m3,${border_router_node},${SENSE_FIRMWARE_HOME}/${BORDER_ROUTER_EXE_NAME}.elf)

    # Extract job ID from JSON output
    local border_router_job_id=$(echo $border_router_job_json | jq -r '.id')

    echo $border_router_job_id
}

submit_coap_server_job() {
    local coap_server_node="$1"

    local coap_server_job_json=$(iotlab-experiment submit -n ${COAP_SERVER_EXE_NAME} -d ${EXPERIMENT_TIME} -l ${SENSE_SITE},m3,${coap_server_node},${SENSE_FIRMWARE_HOME}/${COAP_SERVER_EXE_NAME}.elf)

    # Extract job ID from JSON output
    local coap_server_job_id=$(echo $coap_server_job_json | jq -r '.id')

    echo $coap_server_job_id
}

submit_sensor_node_job() {
    local sensor_connected_node="$1"

    iotlab-profile del -n group12
    iotlab-profile addm3 -n group12 -voltage -current -power -period 8244 -avg 4

    local n_connected_sensor=$(iotlab-experiment submit -n ${SENSOR_CONNECTED_EXE_NAME} -d ${EXPERIMENT_TIME} -l ${SENSE_SITE},m3,${sensor_connected_node},${SENSE_FIRMWARE_HOME}/${SENSOR_CONNECTED_EXE_NAME}.elf,group12)
    local n_connected_sensor_job_id=$(echo $n_connected_sensor | jq '.id')

    echo $n_connected_sensor_job_id
}

wait_for_job() {
    local n_node_job_id="$1"

    echo "iotlab-experiment wait --timeout ${JOB_WAIT_TIMEOUT} --cancel-on-timeout -i ${n_node_job_id} --state Running"
    iotlab-experiment wait --timeout "${JOB_WAIT_TIMEOUT}" --cancel-on-timeout -i "${n_node_job_id}" --state Running
}

create_tap_interface() {
    local node_id="$1"
    echo "Create tap interface ${TAP_INTERFACE}"
    echo "nib neigh"
    echo "Creating tap interface..."
    sudo ethos_uhcpd.py m3-${node_id} ${TAP_INTERFACE} ${BORDER_ROUTER_IP}
    sleep 5
    echo "Done creating tap interface..."
}

create_tap_interface_bg() {
    local node_id="$1"
    echo "Create tap interface ${TAP_INTERFACE}"
    echo "nib neigh"
    echo "Creating tap interface..."
    sudo ethos_uhcpd.py m3-${node_id} ${TAP_INTERFACE} ${BORDER_ROUTER_IP} &
    sleep 5
    echo "Done creating tap interface..."
}

stop_jobs() {
    for job_id in "$@"; do
        # Check the state of the job
        JOB_STATE=$(iotlab-experiment wait --timeout 30 --cancel-on-timeout -i ${job_id} --state Running,Terminated,Stopped,Error)

        echo "Job ID ${job_id} State: $JOB_STATE"

        # Stop the job only if it is in 'Running' state
        if [ "$JOB_STATE" = '"Running"' ]; then
            echo "Stopping Job ID ${job_id}"
            iotlab-experiment stop -i ${job_id}
        else
            echo "Job ID ${job_id} is not in 'Running' state. Current state: $JOB_STATE"
        fi

        sleep 1
    done
}

build_wireless_firmware() {

    local firmware_source_folder="$1"
    local exe_name="$2"

    if are_files_new "${firmware_source_folder}/bin/${ARCH}/${exe_name}.elf" "${firmware_source_folder}"; then
        echo "No need to build"
        return 0 # Exit the function successfully
    fi

    echo "Build firmware ${firmware_source_folder}"
    echo "make ETHOS_BAUDRATE=${ETHOS_BAUDRATE} DEFAULT_CHANNEL=${DEFAULT_CHANNEL} BOARD=${ARCH} -C ${firmware_source_folder}"
    make ETHOS_BAUDRATE="${ETHOS_BAUDRATE}" DEFAULT_CHANNEL="${DEFAULT_CHANNEL}" -C "${firmware_source_folder}"

    # Capture the exit status of the make command
    local status=$?

    # Optionally, you can echo the status for logging or debugging purposes
    if [ $status -eq 0 ]; then
        echo "Build succeeded"
    else
        echo "Build failed with exit code $status"
    fi

    # Return the exit status
    return $status
}

build_wireless_firmware_forced() {

    local firmware_source_folder="$1"
    local exe_name="$2"

    echo "Build firmware ${firmware_source_folder}"
    echo "make ETHOS_BAUDRATE=${ETHOS_BAUDRATE} DEFAULT_CHANNEL=${DEFAULT_CHANNEL} BOARD=${ARCH} -C ${firmware_source_folder}"
    make ETHOS_BAUDRATE="${ETHOS_BAUDRATE}" DEFAULT_CHANNEL="${DEFAULT_CHANNEL}" BOARD="${ARCH}" -C "${firmware_source_folder}"

    # Capture the exit status of the make command
    local status=$?

    # Optionally, you can echo the status for logging or debugging purposes
    if [ $status -eq 0 ]; then
        echo "Build succeeded"
    else
        echo "Build failed with exit code $status"
    fi

    # Return the exit status
    return $status
}

build_wireless_firmware_cached() {

    local firmware_source_folder="$1"
    local exe_name="$2"

    if are_files_new "${firmware_source_folder}/bin/${ARCH}/${exe_name}.elf" "${firmware_source_folder}"; then
        echo "No need to build"
        return 0 # Exit the function successfully
    fi

    echo "Build firmware ${firmware_source_folder}"
    echo "make ETHOS_BAUDRATE=${ETHOS_BAUDRATE} DEFAULT_CHANNEL=${DEFAULT_CHANNEL} BOARD=${ARCH} -C ${firmware_source_folder}"
    make ETHOS_BAUDRATE="${ETHOS_BAUDRATE}" DEFAULT_CHANNEL="${DEFAULT_CHANNEL}" BOARD="${ARCH}" -C "${firmware_source_folder}"

    # Capture the exit status of the make command
    local status=$?

    # Optionally, you can echo the status for logging or debugging purposes
    if [ $status -eq 0 ]; then
        echo "Build succeeded"
    else
        echo "Build failed with exit code $status"
    fi

    # Return the exit status
    return $status
}

build_firmware() {
    local firmware_source_folder="$1"
    local exe_name="$2"
    if are_files_new "${firmware_source_folder}/bin/${ARCH}/${exe_name}.elf" "${firmware_source_folder}"; then
        echo "No need to build"
        return 0 # Exit the function successfully
    fi

    echo "Build firmware ${firmware_source_folder}"
    echo "make BOARD=${ARCH} -C ${firmware_source_folder}"
    make BOARD="${ARCH}" -C "${firmware_source_folder}" clean all

    local status=$?

    # Optionally, you can echo the status for logging or debugging purposes
    if [ $status -eq 0 ]; then
        echo "Build succeeded"
    else
        echo "Build failed with exit code $status"
    fi

    # Return the exit status
    return $status
}

is_first_file_newer() {
    local first_file="$1"
    local second_file="$2"

    if [[ ! -e "$first_file" ]] || [[ ! -e "$second_file" ]]; then
        echo "One or both files do not exist."
        echo "$first_file"
        echo "$second_file"
        return 2 # Return 2 for error due to non-existent files
    fi

    local first_file_mod_time=$(stat -c %Y "$first_file")
    local second_file_mod_time=$(stat -c %Y "$second_file")

    if [[ $first_file_mod_time -gt $second_file_mod_time ]]; then
        return 0 # First file is newer
    elif [[ $first_file_mod_time -le $second_file_mod_time ]]; then
        return 1 # First file is equal or older
    fi
}

are_files_new() {
    local first_file="$1"
    local directory="$2"

    if [[ ! -e "$first_file" ]]; then
        echo "The first file does not exist."
        return 2 # Return 2 for error due to non-existent first file
    fi

    if [[ ! -d "$directory" ]]; then
        echo "The provided directory does not exist."
        return 2 # Return 2 for error due to non-existent directory
    fi

    local first_file_mod_time=$(stat -c %Y "$first_file")
    local newer_found=0

    # Iterate over .c and .h files in the directory
    for file in "$directory"/*.{c,h} "$directory/Makefile"; do
        if [[ -e $file ]]; then
            local file_mod_time=$(stat -c %Y "$file")
            if [[ $first_file_mod_time -le $file_mod_time ]]; then
                echo "$first_file"
                echo "$file"
                return 1
                break
            fi
        fi
    done

    return 0
}

extract_ip() {
    local server_ip="$1"
    local ip

    # Extracting IP address, assuming it ends 6 characters before the end
    ip="${server_ip:1:${#server_ip}-7}"
    echo "$ip"
}
