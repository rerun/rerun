# 
# Shell functions for @MODULE@ commands
#


# Read rerun's public functions
. $RERUN || {
    echo >&2 "ERROR: Failed sourcing rerun function library: \"$RERUN\""
    return 1
}


# ----------------------------
# Your functions declared here.
#


