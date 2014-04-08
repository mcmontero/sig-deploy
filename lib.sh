# +---------------------------------------------------------------------------+
# | PUBLIC FUNCTIONS                                                          |
# +---------------------------------------------------------------------------+

function pid_lock
{
    pid_file=$1
    if [ -e $pid_file ]
    then
        pid=`/bin/cat $pid_file`
        if /bin/kill -0 $pid >& /dev/null;
        then
            /bin/echo "! ${0} is already running!"
            /bin/echo
            exit 1
        else
            /bin/rm $pid_file
        fi
    fi

    /bin/echo $$ > $pid_file
}

function send_alert
{
    /bin/hostname |
        /bin/mailx -s "** sig-deploy: $1 Caused Alert" \
                      $2
}

function file_to_array
{
    last_ifs="$IFS"
    IFS=$'\n'

    array=($(<$1))

    IFS="$last_ifs"

    return array
}
