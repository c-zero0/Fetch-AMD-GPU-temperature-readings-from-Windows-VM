#!/bin/bash

GUEST_NAME="win11" # Replace with your VM name
OUTPUT_FILE="C:\\get-temps\\output.txt"

# Run the scheduled task
#echo "Running Task Scheduler task via QEMU-agent..."
exec_result=$(virsh -c qemu:///system qemu-agent-command "$GUEST_NAME" '{"execute": "guest-exec", "arguments": { "path": "C:\\Windows\\System32\\schtasks.exe", "arg": ["/run", "/tn", "Run Fetch"], "capture-output": true }}')

exec_pid=$(echo "$exec_result" | jq ".return.pid")

# Wait for the task to complete
job_exited="false"
#echo "Waiting for the task to complete..."
while [ "$job_exited" == "false" ]; do
    exec_job_data=$(virsh -c qemu:///system qemu-agent-command "$GUEST_NAME" \
    '{"execute": "guest-exec-status", "arguments": { "pid": '"${exec_pid}"' }}')
    
    job_exited=$(echo "$exec_job_data" | jq '.return.exited')
    
    if [ "$job_exited" == "false" ]; then
        sleep 0.1s
        continue
    fi
    break
done

# Fetch the contents of output.txt
#echo "Fetching contents of output.txt..."

sleep 1s

file_open_result=$(virsh -c qemu:///system qemu-agent-command "$GUEST_NAME" \
'{"execute": "guest-file-open", "arguments": { "path": "C:\\get-temps\\output.txt", "mode": "r" }}')

file_fd=$(echo "$file_open_result" | jq ".return")

file_content=""

file_read_result=$(virsh -c qemu:///system qemu-agent-command "$GUEST_NAME" \
'{"execute": "guest-file-read", "arguments": { "handle": '"${file_fd}"' }}')

#echo "$file_read_result"
data=$(echo "$file_read_result" | jq -r '.return."buf-b64"')
#echo $data

if [ "$data" == "null" ]; then
    break
fi

decoded_data=$(echo "$data" | base64 --decode)
file_content+="$decoded_data"


# Close the file descriptor
virsh -c qemu:///system qemu-agent-command "$GUEST_NAME" \
'{"execute": "guest-file-close", "arguments": { "handle": '"${file_fd}"' }}' > /dev/null

# Print the output
#echo "Contents of output.txt (JSON formatted):"
echo "$file_content"
