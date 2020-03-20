#!/bin/bash

#terminal colors
greenColour="\e[0;32m\033[1m"
yellowColour="\e[0;33m\033[1m"
redColour="\e[0;31m\033[1m"
endColour="\033[0m\e[0m"

#functions
trap ctrl_c INT

function ctrl_c(){
	echo -e "\n${redColour}[*]Process canceled, Exiting...${endColour}"
  tput cnorm; exit 0
}

function banner() {
  echo -e """${yellowColour}
  +-------------------------------------------------+
  |              simplePortScanner                  |
  |         by: github.com/AlejandroMoraG           |
  +-------------------------------------------------+
  ${endColour}"""
}

function helpPanel() {
  echo -e "\n${yellowColour} [*] Usage:${endColour} ./simplePortScanner.sh -t ${yellowColour}<host-to-scan>${endColour} -p ${yellowColour}<ports>${endColour}"
  echo -e "\n    -t [host to scan(IP or hostname)]"
  echo -e "\n    -p [ports(default=0-65535)] example=('22,80,8080' or '100-1000' or '80')\n"
  tput cnorm; exit 0
}

function get_os() {
	ttl=$(timeout 1 bash -c "ping -c 1 $targetHost")
	case $ttl in
	*ttl=6*)
		echo -e "[*] OS detected: ${greenColour}linux${endColour}"
		;;
	*ttl=1*)
		echo -e "[*] OS detected: ${greenColour}Windows${endColour}"
		;;
	*ttl=2*)
		echo -e "[*] OS detected: Solaris/Other(ttl=$ttl)"
		;;
	esac
}
function create_list_port() {
  listPorts=()
  case $ports in
    *-*)
      IFS=- read start end <<< "$ports"
      for ((port=start; port <= end; port++)); do
        listPorts+=($port)
      done
      ;;
    *,*)
      IFS=, read -ra listPorts <<< "$ports"
      ;;
    *)
      listPorts+=($ports)
      ;;
  esac
}

function scaning_process() {
  timeout 1 bash -c "echo > /dev/tcp/$targetHost/$port" 2> /dev/null && echo -e "${greenColour}[+]${endColour}Port $port -> ${greenColour}OPEN${endColour}\n" &
}

function separator() {
	echo "-----------------------"
}

function process_complete() {
	echo "-----------------------"
	echo -e "${yellowColour}** Scan completed **${endColour}\n"
}
#Main
tput civis
banner

#check parameters
declare -i parameter_counter=0; while getopts ":t:p:h:" arg; do
		case $arg in
			t) targetHost=$OPTARG; let parameter_counter+=1 ;;
			p) ports=$OPTARG; let parameter_counter+=1;;
			h) helpPanel;;
		esac
	done


if [ $parameter_counter -lt 1 ]; then
		helpPanel
fi
echo -e "[*] Scaning Host: $targetHost"
get_os
if [ $parameter_counter -lt 2 ]; then
    echo -e "[*] Ports: Default=0-65535\n"
		separator
    for port in $(seq 1 65535); do
      scaning_process
    done; wait; tput cnorm; process_complete
fi
if [ $parameter_counter == 2 ]; then
    create_list_port
    echo -e "[*] Ports: $ports\n"
		separator
    for port in ${listPorts[@]}; do
      scaning_process
    done; wait; tput cnorm; process_complete
fi
