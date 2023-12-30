#!/bin/bash

source usages.sh

# User infor
user_info(){
    username=$2

    echo username : $username
    
    # Use getent command to get full name and home directory
    user_info=$(getent passwd $username)
    full_name=$(echo $user_info | cut -d':' -f5 | cut -d',' -f1)
    home_dir=$(echo $user_info | cut -d':' -f6)

    echo "Full Name: $full_name"

    # Use id command to get UID and GID
    id_info=$(id -u $username)
    uid=$(echo $id_info | cut -d' ' -f1)
    gid=$(echo $id_info | cut -d' ' -f2)

    echo "UID, GID: $uid, $gid"

    echo "Home Dir: $home_dir"

    # Use last command to get last login information

    last_log=$(last -n 1 -w $username | awk 'NR==1 {print $3, $4, $5, $6, $7, $8}')

    echo "Last Login: $last_log"
}

is_reachable(){
    local target="$1"
    if ping -c 1 -W 1 "$1" &> /dev/null; then
        echo "yes"
    else
        echo "no"
    fi
}

num_host(){

    target_ip="$2"
    # Get the routing information using ip route command
    route_info=$(ip route get $target_ip)

    # Extract the gateway and route from the output
    gateway=$(echo "$route_info" | awk '/via/ {print $3}')
    interface=$(echo "$route_info" | awk '/dev/ {print $5}')
    dev=$(echo "$route_info" | awk  '{print $4}')

    # Get the organization and country information using whois
    whois_result=$(whois $target_ip)

    # Extract organization and country information from whois result
    organisation=$(echo "$whois_result" | grep -i "organisation:" | awk '{print $2}')
    country=$(echo "$whois_result" | grep -i "country:" | awk '{print $2}')
        
    result=$(is_reachable $2)

    resolved_value=$(getent hosts "$2" | awk '{print $2}')
    echo Ip address : $2
    echo   Hostname : $resolved_value
    echo  Reachable :  "$result"

    echo Route/Gateway: $gateway $dev $interface
    echo Organization : $organisation
    echo Country : $country
}
string_host() {

    hostname=$(host "$2" | awk '/has address/ {print $4}')
    echo "hostname for ip address $2 : $hostname"
}

# host info
host_info(){

    if [[ "$2" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        num_host $1 $2 
    else
        string_host $1 $2 
    fi
}


# Navigate to method 

case "$1" in 
    "u")
        user_info $1 $2
        exit 1
        ;;
    "user")
        user_info $1 $2
        exit 1
        ;;
    "h")
        host_info $1 $2
        exit 1
        ;;
    "host")
        host_info $1 $2
        exit 1
        ;;

esac
#!/bin/bash

if [ "$#" -lt 2 ]; then

    case "$1" in
        "u")
            echo "Usage : $0 u <username>"
            exit 1
            ;;
        "user")
            echo "Usage : $0 user <username>"
            exit 1
            ;;

        "h")
            echo "Usage : $0 h <hostname>"
            exit 1
            ;;
        "host")
            echo "Usage : $0 host <hostname>"
            exit 1
            ;;
        "p")
            echo "Usage : $0 p <pathname>"
            exit 1
            ;;
        "path")
            echo "Usage : $0 path <pathname>"
            exit 1
            ;;
    esac
fi

