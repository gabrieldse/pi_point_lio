#!/bin/bash

# Set variables
CONTAINER_NAME="unilio_arm"
LAUNCH_FILE="mapping_unilidar_record.launch"
ROS_PACKAGE="point_lio_unilidar"
REMOTE_USER="pi_lio"
REMOTE_HOST="=192.168.43.131"
REMOTE_PATH="/home/raw_lidar_data"
LOCAL_PATH="/home/Desktop"
OTHER_SCRIPT="./home/unilidar_sdk/unitree_lidar_sdk/bin/example_lidar"

# Function to clean up on exit
cleanup() {
  echo "Script interrupted. Stopping container and copying files..."
  echo "Calling the stop spinning script..."
  $OTHER_SCRIPT &
  OTHER_SCRIPT_PID=$!

  # Wait for 1 second and then send SIGINT to the other script
  sleep 1
  echo "Sending SIGINT to the other script..."
  kill -SIGINT $OTHER_SCRIPT_PID
	
  # Stop the Docker container
  echo "Stopping the Docker container..."
  docker stop $CONTAINER_NAME

  # Find the latest files in the local folder
  echo "Finding the latest files..."
  LATEST_FILES=$(ls -t $LOCAL_PATH | head -n 1) # Adjust as necessary

  # Copy the latest files to the remote computer
  echo "Copying the latest files to the remote computer..."
  for FILE in $LATEST_FILES; {
    scp "$LOCAL_PATH/$FILE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"
  }

  echo "Files copied successfully. Exiting script."
}

# Trap Ctrl+C (SIGINT) to run the cleanup function
trap cleanup SIGINT

# Step 1: Start the Docker container
echo "Starting the Docker container..."
docker run -d --name $CONTAINER_NAME -v $LOCAL_PATH:/workspace $IMAGE_NAME bash -c "while true; do sleep 1; done"

# Ensure the container started successfully
if [ $? -ne 0 ]; then
  echo "Failed to start the Docker container. Exiting."
  exit 1
fi

echo "Docker container started successfully."

# Step 2: Launch the ROS launch file inside the container
echo "Launching the ROS launch file inside the container..."
docker exec -d $CONTAINER_NAME bash -c "cd unilidar_sdk/unitree_lidar_ros && source devel/setup.bash && roslaunch unitree_lidar_ros run_without_rviz.launch  & cd catkin_point_lio_unilidar && source devel/setup.bash && roslaunch point_lio_unilidar mapping_unilidar_record.launch --wait && fg"

#docker exec -d $CONTAINER_NAME bash -c "source /opt/ros/noetic/setup.bash && cd /workspace && roslaunch $ROS_PACKAGE $LAUNCH_FILE"

# Wait for the user to interrupt the script
echo "ROS launch file started. Press Ctrl+C to stop and copy files."

# Wait indefinitely until the script is interrupted
while true; do
  sleep 1
done

