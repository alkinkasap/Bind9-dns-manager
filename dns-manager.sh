#!/bin/bash

# Variables
ZONEFILE="/etc/bind/db.local"

# Function to add a domain
add_domain() {
    echo -e "\e[31m\e[1mAdd Domains\e[0m\n"
    read -p "Enter domain name (or enter to cancel): " DOMAIN
    if [[ -z "$DOMAIN" ]]; then return; fi
    read -p "Enter IP address: " IPADDR

    # Check if domain already exists
    if grep -q "$DOMAIN" "$ZONEFILE"; then
        echo -e "\e[31mError: $DOMAIN already exists.\e[0m"
        return
    fi

    # Add new domain to zone file
    echo "$DOMAIN IN A $IPADDR" >> "$ZONEFILE"

    # Restart BIND9 service
    sudo systemctl restart bind9

    echo "$DOMAIN is added with IP address $IPADDR"
}

# Function to edit a domain
edit_domain() {
    echo -e "\e[31m\e[1mEdit Domains\e[0m\n"
    # Display existing domains
    view_domains

    read -p "Enter domain number to edit (or enter to cancel): " NUM
    if [[ -z "$NUM" ]]; then return; fi
    read -p "Enter new IP address: " IPADDR

    DOMAIN=$(sed -n "${NUM}p" <(grep -P '^\S+.*IN\s+A' "$ZONEFILE" | grep -v '@' | awk '{print $1}'))

    # Check if domain exists
    if [[ -z "$DOMAIN" ]]; then
        echo -e "\e[31mError: No such domain number.\e[0m"
        return
    fi

    # Edit the domain
    sed -i "/$DOMAIN/c\\$DOMAIN IN A $IPADDR" "$ZONEFILE"

    # Restart BIND9 service
    sudo systemctl restart bind9

    echo "$DOMAIN is updated with IP address $IPADDR"
}

# Function to remove a domain
remove_domain() {
    echo -e "\e[31m\e[1mRemove Domains\e[0m\n"
    # Display existing domains
    view_domains

    read -p "Enter domain number to remove (or enter to cancel): " NUM
    if [[ -z "$NUM" ]]; then return; fi

    DOMAIN=$(sed -n "${NUM}p" <(grep -P '^\S+.*IN\s+A' "$ZONEFILE" | grep -v '@' | awk '{print $1}'))

    # Check if domain exists
    if [[ -z "$DOMAIN" ]]; then
        echo -e "\e[31mError: No such domain number.\e[0m"
        return
    fi

    # Remove the domain
    sed -i "/$DOMAIN/d" "$ZONEFILE"

    # Restart BIND9 service
    sudo systemctl restart bind9

    echo "$DOMAIN is removed."
}

# Function to view all domains
view_domains() {
    echo -e "\e[31m\e[1mList Domains\e[0m\n"
    grep -P '^\S+.*IN\s+A' "$ZONEFILE" | grep -v '@' | cat -n
}

# Function to check Bind9 service status
check_status() {
    echo -e "\e[31m\e[1mBind9 Service Status\e[0m\n"
    sudo systemctl status bind9 --no-pager
}

# Function to restart Bind9 service
restart_service() {
    echo -e "\e[31m\e[1mRestarting Bind9 Service\e[0m\n"
    sudo systemctl restart bind9
    echo -e "\e[32mBind9 service restarted successfully\e[0m"
}

# Main menu
while true; do
    echo
    echo "1. Add a domain"
    echo "2. Edit a domain"
    echo "3. Remove a domain"
    echo "4. List all domains"
    echo "5. Check Bind9 status"
    echo "6. Restart Bind9 service"
    echo "7. Exit program"
    echo
    read -p "Choose an option: " CHOICE

    case $CHOICE in
        1) add_domain ;;
        2) edit_domain ;;
        3) remove_domain ;;
        4) view_domains ;;
        5) check_status ;;
        6) restart_service ;;
        7) break ;;
        *) echo -e "\n\e[31mInvalid option.\e[0m\n" ;;
    esac
done
