FROM ros:noetic-ros-base

# install ros packages
# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-ros-core=1.5.0-1* \
    ros-noetic-pcl-conversions \
    ros-noetic-pcl-ros \
    pcl-tools \
    ros-noetic-eigen-conversions \
    libeigen3-dev \
    git \
    wget \
    ros-noetic-eigen-conversions \
    ros-noetic-rviz \
    build-essential \
    unzip \
    nano \
    && rm -rf /var/lib/apt/lists/*

RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
RUN echo "source /home/unilidar_sdk/unitree_lidar_ros/devel/setup.bash" >> ~/.bashrc
RUN echo "source /home/catkin_point_lio_unilidar/devel/setup.bash" >> ~/.bashrc

# setup entrypoint
COPY ./ros_entrypoint.sh /

WORKDIR /home

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

