#!/bin/bash


DAEMON_VERSION=1.4.1
CLI_VERSION=2.0.1

RELEASE_TYPE=production
APP_DIR=/opt/purevpn-cli
DAEMON_FILE_NAME=pured-linux-x64
DAEMON_COMPRESSED_NAME=$DAEMON_FILE_NAME.gz
DAEMON_URL=https://apps.purevpn-tools.com/cross-platform/linux-daemon/$DAEMON_VERSION/$DAEMON_COMPRESSED_NAME

CLI_FILE_NAME=purevpn-cli
CLI_COMPRESSED_NAME=$CLI_FILE_NAME.gz
CLI_APP_URL=https://apps.purevpn-tools.com/cross-platform/linux-cli/$RELEASE_TYPE/$CLI_VERSION/$CLI_COMPRESSED_NAME

ATOM_CONFIG_URL=https://apps.purevpn-tools.com/cross-platform/scripts/$RELEASE_TYPE/atom-update-dns
ATOM_CONFIG_OVPN_URL=https://apps.purevpn-tools.com/cross-platform/scripts/$RELEASE_TYPE/atom-update-resolve-conf
ATOM_CONFIG_WG_URL=https://apps.purevpn-tools.com/cross-platform/scripts/$RELEASE_TYPE/atom-update-resolve-conf-wg

CLI_INSTALLATION_DIR=$APP_DIR/bin

install_pre_requisites() {
    echo "Installing the prerequisites"
    apt install -y \
        wget \
        gzip \
        apt-transport-https \
        openvpn \
        openvpn-systemd-resolved \
        wireguard \
        wireguard-tools \
        net-tools
    apt install -y openresolv
}

setting_up_required_files() {

    echo "Configuring required files"

    rm -rf $APP_DIR/atom-update-dns
    wget --backups=0 --directory-prefix=$APP_DIR $ATOM_CONFIG_URL
    
    #adding execute permissions
    chmod +x $APP_DIR/atom-update-dns

    rm -rf $APP_DIR/atom-update-resolve-conf
    wget --backups=0 --directory-prefix=$APP_DIR $ATOM_CONFIG_OVPN_URL
    
    #adding execute permissions
    chmod +x $APP_DIR/atom-update-resolve-conf

    rm -rf $APP_DIR/atom-update-resolve-conf-wg
    wget --backups=0 --directory-prefix=$APP_DIR $ATOM_CONFIG_WG_URL 
    
    #adding execute permissions
    chmod +x $APP_DIR/atom-update-resolve-conf-wg
}

setting_up_daemon() {
    DAEMON_STATUS="$(systemctl is-active pured.service)"
    
    if [ "${DAEMON_STATUS}" = "active" ]; then
        echo "stopping daemon!"
        systemctl disable pured.service
        rm /etc/systemd/system/pured.service
        systemctl daemon-reload
        systemctl reset-failed
    fi

    rm -rf $APP_DIR/$DAEMON_FILE_NAME
    rm -rf $APP_DIR/$DAEMON_COMPRESSED_NAME
    wget --backups=0 --directory-prefix=$APP_DIR $DAEMON_URL 
    yes n | gzip -dvf $APP_DIR/$DAEMON_COMPRESSED_NAME

    chmod +x $APP_DIR/$DAEMON_FILE_NAME

    printf "[Unit]\nDescription=purevpn-deamon\nAfter=network.target\n\n[Service]\nExecStart=$APP_DIR/$DAEMON_FILE_NAME --start\nRestart=always\nEnvironment=PATH=/usr/bin:/usr/local/bin\nEnvironment=NODE_ENV=production\nWorkingDirectory=/\nStandardOutput=file:${APP_DIR}/access.log\nStandardError=file:${APP_DIR}/error.log\n        \n[Install]\nWantedBy=multi-user.target" \
            > /etc/systemd/system/pured.service

    systemctl daemon-reload
    systemctl start pured
    systemctl enable pured
}

setting_up_cli() {
    #downloading the installer
    echo $CLI_APP_URL
    
    rm -rf $APP_DIR/$CLI_FILE_NAME
    rm -rf $APP_DIR/$CLI_COMPRESSED_NAME
    wget --backups=0 --directory-prefix=$APP_DIR $CLI_APP_URL
    yes n | gzip -dvf $APP_DIR/$CLI_COMPRESSED_NAME

    rm -rf $CLI_INSTALLATION_DIR/
    mkdir $CLI_INSTALLATION_DIR/

    cp $APP_DIR/$CLI_FILE_NAME $CLI_INSTALLATION_DIR/
    chmod +x $CLI_INSTALLATION_DIR/$CLI_FILE_NAME

    if [[ $PATH != *"${CLI_INSTALLATION_DIR}"* ]]; then
        PATH=$PATH:$CLI_INSTALLATION_DIR/
    fi
}


install_pre_requisites
setting_up_required_files
setting_up_daemon
setting_up_cli

echo -e "\n\e[32mInstallation is completed, run the following command to load PureVPN CLI in your profile,"
echo -e "echo \"export PATH=\$PATH:$CLI_INSTALLATION_DIR\" >> ~/.bashrc && source ~/.bashrc\e[0m"

echo -e "\nRun command \"purevpn-cli --help\" after to get more information on how to use PureVPN CLI"