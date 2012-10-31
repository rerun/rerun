#
# Test function library
# 
# This file contains a collection of shell functions useful 
# for testing rerun.
#

die() {
    echo >&2 "$*"
    exit 1
}

# make_freddy --
#
#     Creates the freddy module containing commands: dance,study
#
make_freddy() {
    [ $# = 1 ] || { echo "usage: make_freddy <dir>"; return 1; }
    moddir=$1
    mkdir -p $moddir/freddy
    cat > $moddir/freddy/metadata <<EOF
NAME=freddy
DESCRIPTION="A dancer in a red beret and matching suspenders"
EOF
    # freddy:dance
    mkdir -p $moddir/freddy/commands/dance
    cat > $moddir/freddy/commands/dance/metadata <<EOF
NAME=dance
DESCRIPTION="tell freddy to dance"
EOF
    cat > $moddir/freddy/commands/dance/default <<EOF
#!/usr/bin/env bash
source  $moddir/freddy/commands/dance/options.sh || exit 2
echo "jumps (\$JUMPS)"
EOF
    # freddy:dance [-j|--jumps <>]
    cat > $moddir/freddy/commands/dance/jumps.option <<EOF
NAME=jumps
DESCRIPTION="jump #num times"
REQUIRED=false
DEFAULT=3
LONG=jumps
SHORT=j
ARGUMENTS=true
EOF
    # freddy:dance options parser
    cat > $moddir/freddy/commands/dance/options.sh <<EOF
rerun_option_usage() { 
    echo "\$USAGE" >&2 ; return 2 ; 
}
rerun_option_check() {  
    [ "\$1" -lt 2 ] && rerun_option_usage
}

while [ "\$#" -gt 0 ]; do
    OPT="\$1"
    case "\$OPT" in
          -j|--jumps) JUMPS="\$2" ; shift ;;
        # unknown option
        -?)
            rerun_option_usage
            ;;
        # end of options, just arguments left
        *)
          break
    esac
    shift
done
# Set defaultable options
[ -z "\$JUMPS" ] && JUMPS="3"
#
return 0
EOF
    # freddy:study
    mkdir -p $moddir/freddy/commands/study
    cat > $moddir/freddy/commands/study/metadata <<EOF
NAME=study
DESCRIPTION="tell freddy to study"
EOF
    cat > $moddir/freddy/commands/study/default <<EOF
#!/usr/bin/env bash
source  $moddir/freddy/commands/study/options.sh || exit 2
echo "studying (\$SUBJECT)"
EOF
    # freddy:study [-s|--subject <>]
    cat > $moddir/freddy/commands/dance/subject.option <<EOF
NAME=subject
DESCRIPTION="subject to study"
REQUIRED=false
DEFAULT=math
LONG=subject
SHORT=s
ARGUMENTS=true
EOF
    # freddy:study option parser
    cat > $moddir/freddy/commands/study/options.sh <<EOF
rerun_option_usage() { 
    echo "\$USAGE" >&2 ; return 2 ; 
}
rerun_option_check() {  
    [ "\$1" -lt 2 ] && rerun_option_usage 
}

while [ "\$#" -gt 0 ]; do
    OPT="\$1"
    case "\$OPT" in
          -s|--subject) SUBJECT="\$2" ; shift ;;
        # unknown option
        -?)
            rerun_option_usage
            ;;
        # end of options, just arguments left
        *)
          break
    esac
    shift
done
# Set defaultable options
[ -z "\$SUBJECT" ] && SUBJECT="math"
#
return 0
EOF
    # Done
}
