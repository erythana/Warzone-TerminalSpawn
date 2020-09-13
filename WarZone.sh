#!/bin/bash
#REGION VARIABLES - you can change these!
titlename="WARZONE"

#NO TOUCHY DA FISH BELOW THIS LINE
#----------------------------------------
version=0.1
#FUNCTIONS
ValidateArgument () {
    argument="$1"
    if [[ $argument != \-* ]]
    then
        echo "The argument '$argument' doesn't start with a dash. Skipping this one!"
        return 255;
    elif [[ ${argument} == \-k ]]
    then
        echo "Found the argument to exit the first window! The split mode of the first valid argument can't get processed properly!"
        return 122;
    elif [[ ${argument:1:1} != "v" && ${argument:1:1} != "h" ]]
    then
        echo "The second char in the string '$argument' doesn't specify the splitting layout. Skipping this one!"
        return 254;
    elif [[ "${argument:2}" == "" ]]
    then
        echo "No command for the new window found - spawning an empty one"
        return 123;
    fi
}
#----------------------------------------

#Argument parser
if [ $# -eq 0 ]; then
    echo "No arguments supplied."
    echo "Type --help for more information on how to use this script"
    exit
elif [[ "$1" == '-help' || "$1" == '--help' ]]; then
    echo
    echo "The sequence of arguments control how the sub-windows get spawned."
    echo "The first terminal will be kept empty so you have something to quickly start typing (this will get killed if you specify '-k'"
    echo "If you spawn a 'Split Left to Right' Terminal and afterwards a 'Split Top to Bottom' Terminal the right terminal (the one from the first argument) will get splitted into the bottom one."
    echo "Each argument supplied consists of two characters (dash('-') not included):"
    echo "First part: The Split part. [v]ertical or [h]orizontal"
    echo "Second part: The tool you want to run in there, just don't type anything to spawn an empty window"
    echo "Each argument has to be surrounded by single quotes (')"
    echo "Example: $0 '-hecho test' ------ This line prints test to the spawned window"
    exit
else
    echo "You started the script (version $version) with the following arguments:"
    echo "$0 ${@@Q}" #variable expension to also get quotes

    validArguments=()
    for i in "$@"; do
        ValidateArgument "$i"
        returnCode=$?

        if [[ $returnCode -eq 0 || $returnCode -eq 123 ]]; then
            validArguments=("${validArguments[@]}" "$i") # Add item to array
        elif [[ $returnCode -eq 122 ]]; then
            exitFirstWindow="true"
        else
            continue #Bad argument, skipping this one.
        fi
    done
fi

if [[ ${#validArguments[*]} -eq 0 ]]; then
    echo "Did not find any valid argument. Exiting..."
    exit 99
fi

/usr/bin/yakuake & # This line is needed in case Yakuake does not accept fcitx inputs.
sleep 1 # gives Yakuake a second before sending dbus commands

echo 
yakuake_sess_id=$(qdbus org.kde.yakuake /yakuake/sessions org.kde.yakuake.addSession)
echo "Creating a new Yakuake-Session with ID $yakuake_sess_id and set title to $titlename"
qdbus org.kde.yakuake /yakuake/tabs org.kde.yakuake.setTabTitle $yakuake_sess_id $titlename 

for ((i = 0; i < ${#validArguments[@]}; i++)); do
    argument=${validArguments[$i]}
    splitDirection=${argument:1:1}
    commandToRun=${argument:2}

    if [[ $splitDirection == "h" ]]; then #split vertical
        terminalId=$(qdbus org.kde.yakuake /yakuake/sessions org.kde.yakuake.splitSessionLeftRight $yakuake_sess_id)
    else #split horizontal
        terminalId=$(qdbus org.kde.yakuake /yakuake/sessions org.kde.yakuake.splitSessionTopBottom $yakuake_sess_id)
    fi
    qdbus org.kde.yakuake /yakuake/sessions runCommandInTerminal $terminalId "$commandToRun"
done

if [[ $exitFirstWindow != "" ]]; then
    firstTerminalId=(`qdbus org.kde.yakuake /yakuake/sessions terminalIdsForSessionId $yakuake_sess_id | tr , \ `)
    qdbus org.kde.yakuake /yakuake/sessions org.kde.yakuake.removeTerminal ${firstTerminalId[0]}
fi
