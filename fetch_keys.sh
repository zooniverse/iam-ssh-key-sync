#!/bin/bash -e

if [ -z "$1" ]
then
    echo "Error: No IAM group specified" >&2
    exit 1
fi

if [ -z "$3" ]
then
    DAEMONIZE=false
else
    DAEMONIZE=true
    UPDATE_DELAY=$3
fi

if [ ! -z "$4" ]
then
    OUTPUT_UID=$4
fi

function _echo {
    if [ -z "$OUTPUT" ]
    then
        echo $1
    else
        echo $1 >> $OUTPUT
    fi
}

AWS="$(which aws || echo /usr/local/bin/aws)"

while true
do
    if [ -z "$2" ]
    then
        OUTPUT=""
    else
        OUTPUT="$(mktemp)"
    fi

    if [ ! -z "$EXTRA_KEYS" ]
    then
        _echo "$EXTRA_KEYS"
    fi

    USER_LIST=$($AWS iam get-group --group-name $1 | \
        jshon -e Users -a -e UserName -u
    )

    for USER_NAME in $USER_LIST
    do
        KEY_IDS=$($AWS iam list-ssh-public-keys --user-name $USER_NAME | \
            jshon -e SSHPublicKeys -a -e Status -u -p -e SSHPublicKeyId -u | \
            grep -A1 Active | grep -v Active | grep -E "[A-Z0-9]+"
        )

        for KEY_ID in $KEY_IDS
        do
            KEY_BODY=$($AWS iam get-ssh-public-key --encoding SSH \
                --user-name $USER_NAME \
                --ssh-public-key-id $KEY_ID | \
                jshon -e SSHPublicKey -e SSHPublicKeyBody -u
            )
            _echo "$KEY_BODY $USER_NAME"
        done
    done

    if [ ! -z "$OUTPUT" ]
    then
        if [ ! -z "$OUTPUT_UID" ]
        then
            chown $OUTPUT_UID $OUTPUT
        fi
        mv -f $OUTPUT $2
    fi

    $DAEMONIZE || break

    sleep $UPDATE_DELAY
done
