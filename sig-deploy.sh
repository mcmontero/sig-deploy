#!/bin/bash

# +---------------------------------------------------------------------------+
# | USAGE                                                                     |
# |                                                                           |
# | Sends a signal that a new software version is ready for deployment.  The  |
# | configuration file indicates what commands to use and where to put        |
# | things.                                                                   |
# +---------------------------------------------------------------------------+

if [ -z "$1" ];
then
    /bin/echo "${0} usage: [Path to Config File] {Payload}"
    exit 0
fi

if [ ! -f $1 ];
then
    /bin/echo "Configuration file \"$1\" does not exist!"
    exit 1
fi

conf_file=$1
payload=$2
pid_file=/tmp/sig-deploy.pid

# +---------------------------------------------------------------------------+
# | INCLUDES                                                                  |
# +---------------------------------------------------------------------------+

source $conf_file

if [ ! -f $lib ];
then
    /bin/echo "Library file \"$lib\" does not exist!"
    exit 1
fi

source $lib

# +---------------------------------------------------------------------------+
# | INSTRUCTIONS                                                              |
# +---------------------------------------------------------------------------+

/bin/echo
/bin/echo "// +------------------------------------------------------------+"
/bin/echo "// | Sig Deploy                                                 |"
/bin/echo "// +------------------------------------------------------------+"
/bin/echo

pid_lock $pid_file

# +---------------------------------------------------------------------------+

/bin/echo "+ Preparing files and payload..."

/bin/date +%s > /tmp/$file_name
/bin/echo $payload >> /tmp/$file_name

# +---------------------------------------------------------------------------+

/bin/echo "+ Sending signal now..."

/bin/echo "    output from transfer command is:"
/bin/echo "--------------------"
command="$s3cmd -c $s3cfg put /tmp/$file_name s3://$bucket_name"
$command
if [ "$?" -ne 0 ];
then
    /bin/echo "--------------------"
    /bin/echo "    failed"
    exit 1
else
    /bin/echo "--------------------"
    /bin/echo "    succeeded"
fi

# +---------------------------------------------------------------------------+

/bin/echo "+ Cleaning up..."

/bin/rm -f $pid_file
/bin/rm -f /tmp/$file_name

# +---------------------------------------------------------------------------+

/bin/echo
/bin/echo "+ Deployment signal was sent successfully!"
/bin/echo

exit 0
