#!/bin/bash
set -e

# setup ros environment
source "/opt/ros/$ROS_DISTRO/setup.bash" --
exec "$@"

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

