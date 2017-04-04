#!/bin/bash

# +---------------------------------------------------------------------------+
# | USAGE                                                                     |
# |                                                                           |
# | Reads the deployment configuration and executes the necessary steps to    |
# | deploy the new software.  This can run out of cron on a regular schedule. |
# +---------------------------------------------------------------------------+

if [ -z "$1" ];
then
    /bin/echo "${0} usage: [Path to Config File]"
    exit 0
fi

if [ ! -f $1 ];
then
    /bin/echo "Configuration file \"$1\" does not exist!"
    exit 1
fi

conf_file=$1
pid_file=/tmp/exec-deploy.pid
conf_base_name=$(/bin/basename $conf_file)
local_revision=$HOME/.sig-deploy/last-revision-$config_file
deploy_revision=$HOME/.sig-deploy/deploy-revision

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
# | PRIVATE FUNCTIONS                                                         |
# +---------------------------------------------------------------------------+

function shutdown
{
    /bin/echo
    /bin/echo "+ Deployment executed successfully!"
    /bin/echo

    exit 0
}

function clean_up
{
    /bin/echo "+ Cleaning up..."

    /bin/rm -f $deploy_revision
    /bin/rm -f $pid_file
}

# +---------------------------------------------------------------------------+
# | INSTRUCTIONS                                                              |
# +---------------------------------------------------------------------------+

/bin/echo
/bin/echo "// +------------------------------------------------------------+"
/bin/echo "// | Exec Deploy                                                |"
/bin/echo "// +------------------------------------------------------------+"
/bin/echo

pid_lock $pid_file

# +---------------------------------------------------------------------------+

/bin/echo "+ Setting up..."

/bin/mkdir -p $HOME/.sig-deploy
if [ "$?" -ne 0 ];
then
    /bin/echo "    failed"
    send_alert "Set Up" $alert
    exit 1
fi

local_revision_num=1
if [ -f $local_revision ];
then
    local_revision_num=$(/bin/cat $local_revision)
fi

# +---------------------------------------------------------------------------+

/bin/echo "+ Pulling signal file..."

/bin/rm -f $deploy_revision > /dev/null 2>&1

/bin/echo "    output from transfer command is:"
/bin/echo "--------------------"
command="$s3cmd -c $s3cfg --force \
            get s3://$bucket_name/$file_name \
            $deploy_revision"
$command
if [ "$?" -ne 0 ];
then
    /bin/echo "--------------------"
    /bin/echo "    failed"
    send_alert "Pulling Signal File" $alert
    exit 1
else
    /bin/echo "--------------------"
    /bin/echo "    succeeded"
fi

last_ifs="$IFS"
IFS=$'\n'
contents=($(<$deploy_revision))
IFS="$last_ifs"
content_len=${#contents[@]}

# +---------------------------------------------------------------------------+

/bin/echo "Comparing revisions..."
/bin/echo "    local revision #$local_revision_num"
/bin/echo "    deploy revision #${contents[0]}"

if [[ $local_revision_num -eq ${contents[0]} ]];
then
    /bin/echo "    revision # has not changed, nothing to do"
    clean_up
    shutdown
fi

# +---------------------------------------------------------------------------+

paths=(${repos//:/ })
if [ ${#paths[@]} -ne 0 ];
then
    /bin/echo "+ Updating git repositories..."

    as_user=''
    if [ ! -z $user ];
    then
        as_user="su - $user -c"
    fi

    for path in "${paths[@]}"
    do
        /bin/echo "    $path"
        /bin/echo "    output from git pull command is:"
        /bin/echo "--------------------"
        (${as_user}"cd $path; /usr/bin/git pull")
        if [ "$?" -ne 0 ];
        then
            /bin/echo "--------------------"
            /bin/echo "    failed"
            send_alert "Pulling $path" $alert
            exit 1
        else
            /bin/echo "--------------------"
            /bin/echo "    succeeded"
        fi
    done
fi

# +---------------------------------------------------------------------------+

if [ -n "$post_action" ];
then
    if [ $content_len -eq 2 ];
    then
        command="$post_action ${contents[1]}"
    else
        command="$post_action"
    fi

    /bin/echo "Executing post action..."
    /bin/echo "    output from post action is:"
    /bin/echo "--------------------"
    $command
    if [ "$?" -ne 0 ];
    then
        /bin/echo "--------------------"
        /bin/echo "    failed"
        send_alert "Post Action" $alert
        exit 1
    else
        /bin/echo "--------------------"
        /bin/echo "    succeeded"
    fi
fi

# +---------------------------------------------------------------------------+

/bin/echo ${contents[0]} > $local_revision

# +---------------------------------------------------------------------------+

clean_up

# +---------------------------------------------------------------------------+

shutdown
