#!/bin/bash

display_help() {
    echo "Usage: $0 -r realm -u user"
    echo
    echo "   -r, --realm    Specify the realm (e.g., domain.net)"
    echo "   -u, --user     Specify the user (e.g., administrator)"
    echo
    exit 1
}

if [ "$#" -ne 4 ]; then
    display_help
fi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -r|--realm) realm="$2"; shift ;;
        -u|--user) user="$2"; shift ;;
        *) display_help ;;
    esac
    shift
done

if [ -z "$realm" ] || [ -z "$user" ]; then
    display_help
fi

echo "Installing prerequisites..."
sudo apt install -y sssd-ad sssd-tools realmd adcli

echo "Discovering the domain..."
sudo realm -v discover "$realm"

echo "Joining the domain..."
sudo realm join -v -U "$user" "$realm"

echo "Enabling homedir creation..."
sudo pam-auth-update --enable mkhomedir

echo "Configuring SSSD for UID/GID mapping..."
sudo sed -i '/use_fully_qualified_names/s/True/False/' /etc/sssd/sssd.conf
sudo sed -i 's|fallback_homedir = /home/%u@%d|fallback_homedir = /home/%u|' /etc/sssd/sssd.conf
sudo sed -i '/ldap_id_mapping/s/True/False/' /etc/sssd/sssd.conf
sudo sed -i '/\[domain\/'"$realm"'\]/a ad_schema = rfc2307' /etc/sssd/sssd.conf
sudo sed -i '/\[domain\/'"$realm"'\]/a ldap_idmap_range_min = 10000' /etc/sssd/sssd.conf
sudo sed -i '/\[domain\/'"$realm"'\]/a ldap_idmap_range_max = 999999' /etc/sssd/sssd.conf
sudo sed -i '/\[domain\/'"$realm"'\]/a ldap_user_uid_number = uidNumber' /etc/sssd/sssd.conf
sudo sed -i '/\[domain\/'"$realm"'\]/a ldap_user_gid_number = gidNumber' /etc/sssd/sssd.conf
sudo sed -i '/\[domain\/'"$realm"'\]/a ldap_group_gid_number = gidNumber' /etc/sssd/sssd.conf

echo "Restarting SSSD..."
sudo systemctl restart sssd

echo "Clearing SSSD cache..."
sudo sss_cache -E

echo "Verifying the user is available..."
sudo getent passwd "$user"
sudo id "$user"

echo "Configuration complete. Please check the output above for any errors."
