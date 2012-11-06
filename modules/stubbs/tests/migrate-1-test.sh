#!/usr/bin/env roundup
#
# This file contains the test plan for the migrate command.
# Execute the plan by invoking: 
#    
#     rerun stubbs:test -m stubbs -p migrate
#

if [[ -n $RERUN ]]
then
  alias rerun=$RERUN
fi

# The Plan
# --------

describe "migrate"

it_fails_without_arguments() {
    if ! rerun stubbs:migrate
    then
      echo "execution proceeded as expected!"
      exit 0
    fi
}
