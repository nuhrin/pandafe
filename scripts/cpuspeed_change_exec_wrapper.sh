#!/bin/bash
# 
# execute command with temporary cpuspeed change via op_cpuspeed

if [[ $1 =~ "/" ]]; then
	echo "Cpu speed not specified or not an integer."
	exit 1
fi
declare -i CPUSPEED
CPUSPEED=$1
if (( CPUSPEED <= 0 )); then
	echo "Cpu speed not specified or not an integer."
	exit 1
fi
shift

CMD="$1"
if [[ ! -x "$CMD" ]]; then
	echo "Cannot be executed: $CMD"
	exit 1
fi
cd "$(dirname $CMD)" # change working directory to dirname of command
shift

# get current speed. complexity here is for the benefit of testing when /proc/pandora/cpu_mhz_max is unavailable
declare -i CURRENT_CPUSPEED
CURRENT_CPUSPEED=$(cat /proc/pandora/cpu_mhz_max 2>/dev/null)
if (( CURRENT_CPUSPEED == 0 )); then
	CURRENT_CPUSPEED=$(cat /etc/pandora/conf/cpu.conf | grep 'default:' | awk -F\: '{print $2}')
fi

if (( CPUSPEED == CURRENT_CPUSPEED )); then
	# no speed change needed. just execute the command
	"$CMD" "$@"
	exit
fi

# set requested cpu speed
/usr/pandora/scripts/op_cpuspeed.sh $CPUSPEED

# execute the command
"$CMD" "$@"
result=$?

# reset original cpu speed
/usr/pandora/scripts/op_cpuspeed.sh $CURRENT_CPUSPEED

exit $result
