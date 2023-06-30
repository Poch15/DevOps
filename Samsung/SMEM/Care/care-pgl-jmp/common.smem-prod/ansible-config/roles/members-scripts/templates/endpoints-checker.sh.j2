#!/bin/bash

# Set the timeout to 10 seconds
timeout=10

# Initialize an array to store the success and failure counts for each application
counts=()

# Retrieve the health check URLs and application names from the Eureka server
response=$(curl -H "Accept: application/json" -m $timeout http://discovery.memberscare.internal:8761/eureka/apps)

# Parse the JSON response to extract the health check URLs and application names

urls=$(echo "$response" | jq -r '.applications.application[].instance[].healthCheckUrl')
names=$(echo "$response" | jq -r '.applications.application[].instance[].app')

# Split the URLs and names into arrays
urls_array=($urls)
names_array=($names)

echo $names_array
# Iterate over the list of URLs and application names
for ((i=0; i<${#urls_array[@]}; i++)); do
  name=${names_array[i]}
  url=${urls_array[i]}
  echo -e "Connecting to endpoint for application '$name': $url \n"
  # Make a request to the URL, storing the result in the 'response' variable
  response=$(curl -m $timeout $url)
  # If the response is empty, consider the health check a failure
  if [ -z "$response" ]; then
    # Increment the failure count for the current application
    counts+=("$name" "failure")
    echo -e "Failed\n"
  else
    # Increment the success count for the current application
    counts+=("$name" "success")
    echo -e "Success\n"
  fi
done

# Group the counts by application name
declare -A app_counts
for ((i=0; i<${#counts[@]}; i+=2)); do
  name=${counts[i]}
  result=${counts[i+1]}
  if [ "$result" == "success" ]; then
    if [ -z "${app_counts[$name]}" ]; then
      app_counts[$name]="success:1,failure:0"
    else
      success=$(echo "${app_counts[$name]}" | grep -o "success:[0-9]*" | grep -o "[0-9]*")
      app_counts[$name]="success:$((success+1)),failure:${app_counts[$name]##*failure:}"
    fi
  else
    if [ -z "${app_counts[$name]}" ]; then
      app_counts[$name]="success:0,failure:1"
    else
      failure=$(echo "${app_counts[$name]}" | grep -o "failure:[0-9]*" | grep -o "[0-9]*")
    fi
  fi
done

# Print the success and failure counts for each application
for key in "${!app_counts[@]}"; do
  echo "$key: ${app_counts[$key]}"
done