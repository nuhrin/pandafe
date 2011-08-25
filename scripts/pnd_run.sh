#!/bin/bash
# 
# This file is a modification of /usr/pandora/scripts/pnd_run.sh which runs a pnd without mounting first or unmounting after.
# 

#/etc/sudoers needs to be adjusted if you touch any of the sudo lines
 
# look at the comments in the CLOSE_X part, adjust 
#use "lsof /usr/lib/libX11.so.6 | awk '{print $1}'| sort | uniq > whitelist" with nothing running to generate the whitelist
 
#todo - no proper order
#validate params better
#make uid/pnd_name mandatory (and rename var, its confusing!)
#find a clean way of shutting down x without a fixed dm, mabye avoid nohup usage somehow
#add options to just mount iso without union and to mount the union later

SCRIPT_DIR="/usr/pandora/scripts"
. $SCRIPT_DIR/pnd_loging
PND_LogDateFormat=PND_Time

PND_MOUNT_DIR="/mnt/pnd"
UNION_MOUNT_DIR="/mnt/utmp"
CPUSPEEDSCRIPT=/usr/pandora/scripts/op_cpuspeed.sh

#=============================================================================
# Utility functions

showHelp() {
	cat <<endHELP
Usage:
  pnd_run.sh -p file.pnd -e cmd [-a args] [-b pndid] [-s path] [-c speed] [-d [path]] [-x] [-m] [-u]
    -p file.pnd	: Specify the pnd file to execute
    -e cmd	: Command to run
    -a args	: Arguments to the command
    -b pndid	: name of the directory mount-point ($UNION_MOUNT_DIR/pndid) (Default: name of the pnd file)
    -s path	: Directory in the union to start the command from
    -o speed	: Set the CPU speed
    -d [path]	: Use path as source of the overlay. (Default: pandora/appdata/pndid)
    -x		: Stop X before starting the apps
endHELP
}

#=============================================================================
# CPU speed functions
PND_getCPUSpeed() {
	cat /proc/pandora/cpu_mhz_max
}

PND_setCPUSpeed() {
	unset CURRENTSPEED
	if ! [ -f "$CPUSPEED_FILE" ] && [ ! -z "$PND_CPUSPEED" ]; then
		if [ ${PND_CPUSPEED} -gt $(PND_getCPUSpeed) ]; then 
		   CURRENTSPEED=$(PND_getCPUSpeed)
        	   case "$(zenity --title="set cpu speed" --height=350 --list --column "id" --column "Please select" --hide-column=1 \
			   	  --text="$PND_NAME suggests to set the cpu speed to $PND_CPUSPEED MHz to make it run properly.\n\n Do you want to change the cpu speed? (current speed: $(PND_getCPUSpeed) MHz)\n\nWarning: Setting the clock speed above 600MHz can be unstable and it NOT recommended!" \
				  "yes" "Yes, set it to $PND_CPUSPEED MHz" \
				  "custom" "Yes, select custom value" \
				  "yessave" "Yes, set it to $PND_CPUSPEED MHz and don't ask again" \
				  "customsave" "Yes, set it to custom speed and don't ask again" \
		   		  "no" "No, don't change the speed" \
				  "nosave" "No, don't chage the speed and don't ask again")" in
			"yes")
				sudo $CPUSPEEDSCRIPT $PND_CPUSPEED
				;;
	  	  	"custom")
				sudo $CPUSPEEDSCRIPT
				;;
		  	"customsave")
				sudo $CPUSPEEDSCRIPT
				zenity --info --title="Note" --text="Speed saved.\n\nTo re-enable this dialogue, please delete the file\n$CPUSPEED_FILE"
				PND_getCPUSpeed > $CPUSPEED_FILE
				;;
         	 	"yessave")
				zenity --info --title="Note" --text="Speed saved.\n\nTo re-enable this dialogue, please delete the file\n$CPUSPEED_FILE"
				sudo $CPUSPEEDSCRIPT $PND_CPUSPEED
				PND_getCPUSpeed > $CPUSPEED_FILE
				;;
                 	"nosave")
				unset CURRENTSPEED
				zenity --info --title="Note" --text="Speed will not be changed.\n\nTo re-enable this dialogue, please delete the file\n$CPUSPEED_FILE"
				echo 9999 > $CPUSPEED_FILE
				;;
			*)	unset CURRENTSPEED;;
 	 	  esac
	       fi
	elif [ "$PND_CPUSPEED" -lt "1500" ]; then
		CURRENTSPEED=$(PND_getCPUSpeed)
		echo Setting to CPU-Speed $PND_CPUSPEED MHz
		sudo $CPUSPEEDSCRIPT $PND_CPUSPEED
	fi
}

PND_resetCPUSpeed() {
	if [ ! -z "$CURRENTSPEED" ]; then
		sudo $CPUSPEEDSCRIPT $CURRENTSPEED
	fi
}

#=============================================================================
# Create the condition to run an app, run it and wait for it's end
runApp() {
	cd "$UNION_MOUNT_DIR/$PND_NAME"		# cd to union mount
	if [ "$STARTDIR" ] && [ -d "$STARTDIR" ]; then
		cd "$STARTDIR";			# cd to folder specified by the optional arg -s
	fi

	if [ -d $UNION_MOUNT_DIR/$PND_NAME/lib ];then
		export LD_LIBRARY_PATH="$UNION_MOUNT_DIR/$PND_NAME/lib:${LD_LIBRARY_PATH:-"/usr/lib:/lib"}"
	else
		export LD_LIBRARY_PATH="$UNION_MOUNT_DIR/$PND_NAME:${LD_LIBRARY_PATH:-"/usr/lib:/lib"}"
	fi

	if [ -d $UNION_MOUNT_DIR/$PND_NAME/bin ];then
		export PATH="$UNION_MOUNT_DIR/$PND_NAME/bin:${PATH:-"/usr/bin:/bin:/usr/local/bin"}"
	fi

	if [ -d $UNION_MOUNT_DIR/$PND_NAME/share ];then
	        export XDG_DATA_DIRS="$UNION_MOUNT_DIR/$PND_NAME/share:$XDG_DATA_DIRS:/usr/share"
	fi

	export XDG_CONFIG_HOME="$UNION_MOUNT_DIR/$PND_NAME"

	"./$EXENAME" $ARGUMENTS
	RC=$?

	#the app could have exited now, OR it went into bg, we still need to wait in that case till it really quits!
	PID=$(pidof -o %PPID -x \"$EXENAME\")	# get pid of app
	while [ "$PID" ];do			# wait till we get no pid back for tha app, again a bit ugly, but it works
		sleep 10s
		PID=`pidof -o %PPID -x \"$EXENAME\"`
	done
	PND_setReturn $RC
}


main() {
	case $ACTION in
	run)
		echo "running $PND..."
		if [ -e /proc/pandora/cpu_mhz_max ] && [ ! -z "$PND_CPUSPEED" ];then
			PND_BeginTask "Set CPU speed"
			PND_setCPUSpeed
			PND_EndTask
		fi
		oPWD=$(pwd)
		if [ -e "${APPDATADIR}/PND_pre_script.sh" ]; then
			PND_BeginTask "Starting user configured pre-script"
			. ${APPDATADIR}/PND_pre_script.sh # Sourcing so it can shared vars with post-script ;)
			PND_EndTask
		fi
		PND_BeginTask "Starting the application ($EXENAME $ARGUMENTS)"
		runApp
		PND_EndTask
		if [ -e "${APPDATADIR}/PND_post_script.sh" ]; then
			PND_BeginTask "Starting user configured post-script"
			. ${APPDATADIR}/PND_post_script.sh
			PND_EndTask
		fi
		cd $oPWD
		if [ ! -z "$CURRENTSPEED" ]; then
			PND_BeginTask "Reset CPU speed to $CURRENTSPEED"
			PND_resetCPUSpeed
			PND_EndTask
		fi
		;;
	esac
}

######################################################################################
####	Parsing the arguments :
##
ACTION=run
while [ "$#" -gt 0 ];do
	if [ "$#" -gt 1 ] && ( [[ "$(echo $2|cut -c 1)" != "-" ]] || [[ "$1" = "-a" ]] );then
        	case "$1" in
                -p) PND="$2";;
                -e) EXENAME="$2";;
                -b) PND_NAME="$2";;
                -s) STARTDIR="$2";;
                -j) append="$2";;
                -c) PND_CPUSPEED="$2";;
                -d) APPDATASET=1;APPDATADIR="$2";;
                -a) ARGUMENTS="$2";;
                *)	echo "ERROR while parsing arguments: \"$1 $2\" is not a valid argument"; 
			echo "Arguments were : $PND_ARGS"
			showHelp;
			exit 1 ;;
        	esac
		shift 2
	else # there's no $2 or it's an argument
        	case "$1" in
                -d) APPDATASET=1;;
                *)	echo "ERROR while parsing arguments: \"$1\" is not a valid argument"; 
			echo "Arguments were : $PND_ARGS"
			showHelp;
			exit 1 ;;
        	esac
		shift

	fi
done

#PND_NAME really should be something sensible and somewhat unique
#if -b is set use that as pnd_name, else generate it from PND
#get basename (strip extension if file) for union mountpoints etc, maybe  this should be changed to something specified inside the xml
#this should probably be changed to .... something more sensible
#currently only everything up to the first '.' inside the filenames is used.
PND_NAME=${PND_NAME:-"$(basename $PND | cut -d'.' -f1)"}

PND_LOG="/tmp/pndrun_${PND_NAME}.out"
PND_HEADER="PND_SCRIPT PND_ARGS PND PND_FSTYPE APPDATADIR APPDD_FSTYPE PND_CPUSPEED EXENAME ARGUMENTS"

if [ ! -e "$PND" ]; then #check if theres a pnd suplied, need to clean that up a bit more
	echo "ERROR: selected PND($PND) file does not exist!"
	showHelp
	exit 1
fi

if [ ! "$EXENAME" ] && [[ "$ACTION" = "run" ]]; then
	echo "ERROR: no executable name provided!"
	showHelp
	exit 1
fi

PND_FSTYPE=$(file -b "$PND" | awk '{ print $1 }')	# is -p a zip/iso or folder?
MOUNTPOINT=$(df "$PND" | tail -1|awk '{print $6}')	# find out on which mountpoint the pnd is
if [ $(df "$PND"|wc -l) -eq 1 ];then			# this is actually a bug in busybox
	MOUNTPOINT="/";
elif [ ! -d "$MOUNTPOINT" ]; then 
	MOUNTPOINT="";
fi
[ ! -z $APPDATASET ] || [ -z ${MOUNTPOINT} ] && APPDATADIR=${APPDATADIR:-$(dirname $PND)/$PND_NAME}
APPDATADIR=${APPDATADIR:-${MOUNTPOINT}/pandora/appdata/${PND_NAME}}
APPDD_FSTYPE=$(mount|awk '$3=="'${MOUNTPOINT}'"{print $5}')
CPUSPEED_FILE=${MOUNTPOINT}/pandora/appdata/${PND_NAME}/cpuspeed
if [ -f "$CPUSPEED_FILE" ]; then
	PND_CPUSPEED=$(cat "$CPUSPEED_FILE")
fi
export APPDATADIR PND PND_NAME

#Only logging when running
if [[ "$ACTION" == "run" ]];then
	PND_Start
	PND_Exec main
	PND_Stop
else
	main
fi
