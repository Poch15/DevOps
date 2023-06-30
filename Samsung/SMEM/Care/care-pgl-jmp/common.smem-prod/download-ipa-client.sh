#!/bin/bash
#version 0.0.1
ipa_env="prod"
url="https://ipa-client.samsungsre.com"
IPA_PATH=/opt/ipa-client
rm -rf /etc/ipa
mkdir -p /etc/ipa
if [ "$(id -u)" != "0" ]; then
    echo "download-ipa-client.sh: this script must be run as root" 1>&2
    return 1
fi

if [ $(bash --help | grep Usage | wc -l) -lt 1 ]; then
    echo "download-ipa-client.sh: bash shell is required"
    return 1
fi

if [ $# -eq 0 ]; then
    echo "download-ipa-client.sh: Missing options!"
    echo "download-ipa-client.sh aws|gcp|azure|idc ipa_servicename"
    return
fi

IPA_INFRA_TYPE=$1
IPA_SERVICENAME=$2
IPA_ANSIBLE=$3
IPA_INSTANCE_PROJECT_ID=$3
if [ "$(echo ${IPA_ANSIBLE} | tr '[:upper:]' '[:lower:]')" == "ansible" ]; then
    IPA_INSTANCE_PROJECT_ID=$4
else
    IPA_ANSIBLE=""
fi

if [ "${IPA_INFRA_TYPE}" = "" ]; then
    echo "download-ipa-client.sh: infra type is required"
    return 1
fi
if [ "${IPA_INFRA_TYPE}" != "aws" ] && [ "${IPA_INFRA_TYPE}" != "gcp" ] && [ "${IPA_INFRA_TYPE}" != "azure" ] && [ "${IPA_INFRA_TYPE}" != "idc" ] && [ "${IPA_INFRA_TYPE}" != "spc" ]; then
    echo "download-ipa-client.sh: invalid infra type: aws,gcp,azure,spc,idc"
    return 1
fi
if [ "${IPA_SERVICENAME}" = "" ]; then
    echo "download-ipa-client.sh: ipa_servicename is required (please contact PL or admin of IPA)"
    return 1
fi
if [ "${IPA_ANSIBLE}" != "" ] && [ "${IPA_ANSIBLE}" != "ansible" ]; then
    echo "if 3rd param is defined , it should be set ansible"
    return 1
fi

IPA_FREESPACE=$(df / | grep -v 'Avail' | awk '{print $4}')
IPA_FREESPACE_H=$(df -h / | grep -v 'Avail' | awk '{print $4}')
echo "download-ipa-client.sh: freespace: ${IPA_FREESPACE} [${IPA_FREESPACE_H}]"
if [ ${IPA_FREESPACE} -lt 921600 ]; then # 900Mb
    echo "download-ipa-client.sh: error less than 900Mb"
    func_end "Error less than 900Mb"
    return 1
fi
mkdir -p ${IPA_PATH}/backup
cd ${IPA_PATH}
rm -f "${IPA_PATH}/.host_mod"
rm -f "${IPA_PATH}/.disable"
rm -f "${IPA_PATH}/ipa_check_result"
rm -f "${IPA_PATH}/.check_firewall"

# find original time sync mode before install ipa
if [ -f "${IPA_PATH}/.timesync_mode" ]; then
    . "${IPA_PATH}/.timesync_mode"
fi
if [ -z ${timesync_mode} ]; then
    timesync_list="chrony chronyd ntp ntpd"
    for timetmp in ${timesync_list}; do
        if [ $(service ${timetmp} status | grep -i "(running)\|is running" | wc -l) -gt 0 ]; then
            timesync_mode=${timetmp}
            echo "timesync_mode=${timesync_mode}" >"${IPA_PATH}/.timesync_mode"
            echo "download-ipa-client.sh: timesync_mode=${timesync_mode} (original)"
            break
        fi
    done
fi
if [ -z ${timesync_mode} ]; then
    echo "download-ipa-client.sh: timesync_mode=none (original)"
else # backup time sync config files
    if [[ "${timesync_mode}" =~ "ntp" ]]; then
        timeconfigfile="ntp.conf ntp/ntp.conf"
    elif [[ "${timesync_mode}" =~ "chrony" ]]; then
        timeconfigfile="chrony.conf chrony/chrony.conf"
    fi
    if [ ! -z "${timeconfigfile}" ]; then
        for cnfile in ${timeconfigfile}; do
            if [ -f "/etc/${cnfile}" ]; then
                newname=$(echo "${cnfile}" | sed 's/\//_/g')
                if [ ! -f "${IPA_PATH}/backup/${newname}.original" ]; then
                    echo "download-ipa-client.sh: Backup /etc/${cnfile} file to ${IPA_PATH}/backup/${newname}.original"
                    cp "/etc/${cnfile}" "${IPA_PATH}/backup/${newname}.original"
                fi
            fi
        done
    fi
fi

if [ ! -f "${IPA_PATH}/backup/cacerts.original" ] && [ -f /etc/pki/ca-trust/extracted/java/cacerts ]; then
    echo "download-ipa-client.sh: backup /etc/pki/ca-trust/extracted/java/cacerts"
    cp /etc/pki/ca-trust/extracted/java/cacerts ${IPA_PATH}/backup/cacerts.original
fi
if [ ! -f "${IPA_PATH}/backup/pam.d.original.tar.gz" ]; then
    echo "download-ipa-client.sh: backup /etc/pam.d/*"
    tar cvfz ${IPA_PATH}/backup/pam.d.original.tar.gz /etc/pam.d/*
fi
if [ ! -f "${IPA_PATH}/backup/passwd.original" ]; then
    echo "download-ipa-client.sh: backup /etc/passwd"
    cp /etc/passwd ${IPA_PATH}/backup/passwd.original
fi
if [ ! -f "${IPA_PATH}/backup/nsswitch.original.conf" ]; then
    echo "download-ipa-client.sh: backup /etc/nsswitch.conf"
    cp /etc/nsswitch.conf ${IPA_PATH}/backup/nsswitch.original.conf
fi
if [ ! -f "${IPA_PATH}/backup/krb5.original.conf" ] && [ -f "/etc/krb5.conf" ]; then
    echo "download-ipa-client.sh: backup krb5.conf"
    cp /etc/krb5.conf ${IPA_PATH}/backup/krb5.original.conf
fi
if [ ! -f "${IPA_PATH}/backup/sshd_config.original" ]; then
    echo "download-ipa-client.sh: backup /etc/ssh/sshd_config"
    cp /etc/ssh/sshd_config ${IPA_PATH}/backup/sshd_config.original
fi
if [ -f "/etc/security/pwquality.conf" ] && [ ! -f "${IPA_PATH}/backup/pwquality.conf.original" ]; then
    echo "download-ipa-client.sh: backup /etc/security/pwquality.conf"
    cp /etc/security/pwquality.conf ${IPA_PATH}/backup/pwquality.conf.original
fi

if [ ! -f "${IPA_PATH}/backup/sudoers.original" ]; then
    echo "download-ipa-client.sh: backup /etc/sudoers"
    cp /etc/sudoers ${IPA_PATH}/backup/sudoers.original
fi

if [ -f .ipa_env ] && [ "${IPA_INFRA_TYPE}" != "idc" ] && [ "${IPA_INFRA_TYPE}" != "spc" ]; then
    touch -d '-1 day' ./.ipa_env
fi
echo IPA_SERVICENAME="${IPA_SERVICENAME}" >.ipa_servicename
echo IPA_INFRA_TYPE=${IPA_INFRA_TYPE} >.ipa_infra_type
if [ -f "/etc/os-release" ]; then
    IPA_LINUX_TYPE=$(cat /etc/os-release | grep PRETTY_NAME | awk -F "=" '{print $2}' | tr -d '"')
elif [ -f "/etc/issue" ]; then
    IPA_LINUX_TYPE=$(cat /etc/issue | head -n 1)
fi
echo "download-ipa-client.sh: IPA_LINUX_TYPE=${IPA_LINUX_TYPE}"

if [ "${LC_ALL}" == "" ]; then
    if [ $(locale -a | grep -e "^C" | head -n 1 | wc -l) -gt 0 ]; then # C , C.UTF-8
        export LC_ALL="$(locale -a | grep -e "^C" | head -n 1)"
    else
        export LC_ALL="$(locale -a | head -n 1)"
    fi
fi

# check whether ssh service is working well
echo "download-ipa-client.sh: restart service ssh(d)"
if [[ "${IPA_LINUX_TYPE}" == *"Ubuntu 14"* ]]; then
    SSH_TYPE="ssh"
    service ssh restart
else
    SSH_TYPE="sshd"
    service sshd restart
fi
sleep 2
if [ $(service ${SSH_TYPE} status | grep -i "is running\|active (running)\|start/running" | wc -l) -gt 0 ]; then
    echo "download-ipa-client.sh: ${SSH_TYPE} service is running"
else
    echo "download-ipa-client.sh: ${SSH_TYPE} service is NOT running"
    service ${SSH_TYPE} status 2>&1
    echo "download-ipa-client.sh: please check and restart ssh(d) service first"
    return 1
fi

if [[ "${IPA_LINUX_TYPE}" =~ "Amazon Linux AMI" ]]; then
    # update releasever
    releasever=$(cat /etc/yum.conf | grep releasever= | cut -d "=" -f 2)
    if [ ! -z $releasever ] && [ $releasever != "latest" ]; then
        sed -i 's,releasever='"$releasever"',releasever=latest,' /etc/yum.conf
    fi
    ipa_package_arr=("libini_config" \
                    "sssd" \
                    "krb5-workstation" \
                    "openldap-clients" \
                    "jq" \
                    "bc" \
                    "lsof" \
                    "strace" \
                    "which" \
                    "curl" \
                    "oddjob oddjob-mkhomedir" \
                    "sudo" \
                    "nss-pem")
    if [[ -z ${IPA_PACKAGE_UPDATE} ]] || [[ ${IPA_PACKAGE_UPDATE} != "false" ]]; then
        for package in ${ipa_package_arr[*]}; do
            yum update -y ${package}
        done
    fi
    for package in ${ipa_package_arr[*]}; do
        yum install -y ${package}
    done
    service oddjobd start
else
    if [ -f /usr/bin/apt ]; then
        if [ -f "/etc/security/pwquality.conf" ] && [ ! -f "/etc/security/pwquality.conf.ipa" ]; then #workaround patch
            mv -f /etc/security/pwquality.conf /etc/security/pwquality.conf.ipa
        fi
        if [[ "${IPA_LINUX_TYPE}" == *"Debian GNU/Linux 9"* ]] && [ -f "/etc/apt/sources.list" ]; then
            if [ $(cat /etc/apt/sources.list | grep "deb http://httpredir.debian.org/debian/ sid main" | wc -l) -lt 1 ]; then
                echo "download-ipa-client.sh: set Debian GNU/Linux 9"
                echo "deb http://httpredir.debian.org/debian/ sid main" >>/etc/apt/sources.list
            fi
        fi
        ipa_package_arr=("sssd" \
                        "krb5-workstation" \
                        "openldap-clients" \
                        "oddjob-mkhomedir" \
                        "jq" \
                        "ntpdate" \
                        "cron" \
                        "bc" \
                        "gzip" \
                        "curl" \
                        "dnsutils" \
                        "dbus" \
                        "libpam-cracklib" \
                        "certmonger")
        if [[ -z ${IPA_PACKAGE_UPDATE} ]] || [[ ${IPA_PACKAGE_UPDATE} != "false" ]]; then
            DEBIAN_FRONTEND=noninteractive /usr/bin/apt update -y
        fi
        for package in ${ipa_package_arr[*]}; do
            DEBIAN_FRONTEND=noninteractive /usr/bin/apt install -y ${package}
        done
        DEBIAN_FRONTEND=noninteractive /usr/bin/apt --only-upgrade install -y sudo
    elif [ $(which yum | grep /yum | wc -l) -gt 0 ] && [ $(yum list 2>/dev/null | wc -l) -gt 0 ]; then
        ipa_package_arr=("sssd" \
                        "krb5-workstation" \
                        "openldap-clients" \
                        "jq" \
                        "bc" \
                        "ntpdate" \
                        "cronie" \
                        "lsof" \
                        "strace" \
                        "which" \
                        "curl" \
                        "oddjob-mkhomedir" \
                        "sudo" \
                        "certmonger" \
                        "bind-utils")
        if [[ -z ${IPA_PACKAGE_UPDATE} ]] || [[ ${IPA_PACKAGE_UPDATE} != "false" ]]; then
            for package in ${ipa_package_arr[*]}; do
                yum update -y ${package}
            done
        fi
        for package in ${ipa_package_arr[*]}; do
            yum install -y ${package}
        done
    fi
    if [ "${IPA_INFRA_TYPE}" = "idc" ]; then
        msg="please set ${IPA_PATH}/.ipa_env like below\n
IPA_INSTANCE_PROJECT_ID=\"projectname\"\n
IPA_INSTANCE_ID=\"instanceid\"\n
IPA_REGION=\"region\"\n
IPA_LOCALIPV4=\"127.0.0.1\"\n
IPA_PORT=\"22\"\n
IPA_BASTION_IP=\"127.0.0.1\"\n
IPA_BASTION_PORT=\"22\"\n
IPA_HOSTNAME=\"ipa-centos-test-ip-127-0-0-1-us-west-1.${IPA_SERVICENAME}\"
IPA_SERVICENAME=\"${IPA_SERVICENAME}\"\n
IPA_TAG_NAME=\"ipa-centos-test\"\n
IPA_DESCRIPTION=\"SERVICE=${IPA_SERVICENAME},PROVIDER=idc,ACCOUNT=${IPA_SERVICENAME},IP=127.0.0.1,IPA_PUBLICIPV4=127.0.0.1,PORT=22,BASTION_IP=127.0.0.1,BASTION_PORT=22,TAG_NAME=ipa-centos-test,OS=Ubuntu 16.04,TAG=${IPA_SERVICENAME}-centos,\""
    fi
    if [ "${IPA_INFRA_TYPE}" = "spc" ]; then
        msg="please set ${IPA_PATH}/.ipa_env like below\n
IPA_INSTANCE_PROJECT_ID=\"projectname\"\n
IPA_INSTANCE_ID=\"instanceid\"\n
IPA_REGION=\"region\"\n
IPA_LOCALIPV4=\"127.0.0.1\"\n
IPA_PORT=\"22\"\n
IPA_BASTION_IP=\"127.0.0.1\"\n
IPA_BASTION_PORT=\"22\"\n
IPA_HOSTNAME=\"ipa-centos-test-ip-127-0-0-1-us-west-1.${IPA_SERVICENAME}\"
IPA_SERVICENAME=\"${IPA_SERVICENAME}\"\n
IPA_TAG_NAME=\"ipa-centos-test\"\n
IPA_DESCRIPTION=\"SERVICE=${IPA_SERVICENAME},PROVIDER=spc,ACCOUNT=${IPA_SERVICENAME},IP=127.0.0.1,IPA_PUBLICIPV4=127.0.0.1,PORT=22,BASTION_IP=127.0.0.1,BASTION_PORT=22,TAG_NAME=ipa-centos-test,OS=Ubuntu 16.04,TAG=${IPA_SERVICENAME}-centos,\""
    fi
fi

if [ $(which wget | grep "/wget" | wc -l) -lt 1 ]; then
    if [ -f /usr/bin/apt ]; then
        /usr/bin/apt install -y wget
    elif [ $(which yum | grep /yum | wc -l) -gt 0 ] && [ $(yum list 2>/dev/null | wc -l) -gt 0 ]; then
        yum install -y wget
    fi
fi
if [ $(which kinit | grep "/kinit" | wc -l) -lt 1 ]; then
    if [ -f /usr/bin/apt ]; then
        DEBIAN_FRONTEND=noninteractive /usr/bin/apt install -y krb5-user # ubuntu 14.x
    elif [ $(which yum | grep /yum | wc -l) -gt 0 ] && [ $(yum list 2>/dev/null | wc -l) -gt 0 ]; then
        echo "download-ipa-client.sh: kinit is required"
    fi
fi
if [ $(which jq | grep "/jq" | wc -l) -lt 1 ]; then
    curl -sL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /usr/bin/jq
    chmod a+x /usr/bin/jq
fi

if [ $(which sestatus | grep "/sestatus" | wc -l) -gt 0 ] && [ $(sestatus | grep -i "SELinux status" | grep -i "enabled" | wc -l) -gt 0 ]; then
    if [ $(which semanage | grep "/semanage" | wc -l) -gt 0 ]; then
        echo "download-ipa-client.sh: semanage permissive -a oddjob_mkhomedir_t"
        semanage permissive -a oddjob_mkhomedir_t
        semanage permissive -l
    else
        echo "download-ipa-client.sh: semanage not found"
    fi
fi
if [ $(which pip | grep "/pip" | wc -l) -gt 0 ]; then
    pip install 'pyasn1-modules>=0.2.1' 'pyasn1>=0.4.2'
    pip freeze | grep pyasn1
fi
echo "download-ipa-client.sh: update ipa-client running ... as env:${ipa_env} url:${url}"
timestamp=$(date +%Y%m%d%H%M)
remote=$(curl -H 'Cache-Control: no-store' -s "${url}/version.txt?${timestamp}")
id_remote=$(echo $remote | jq -r .id)
md5_remote=$(echo $remote | jq -r .md5)
wget --no-cache -q ${url}/${id_remote}_ipa-client.tar.gz -O ./ipa-client.tar.gz
wget --no-cache -q ${url}/${id_remote}_version.txt -O ./version
tar xvfz ./ipa-client.tar.gz
#tar -xvf ./python-virtualenv.tar.gz

if [ $(cat /etc/ssh/sshd_config | grep -i Banner | grep -iv "#Banner" | wc -l) -lt 1 ]; then
    . ./setup-banner.sh 2>&1
fi

if [ "${IPA_INFRA_TYPE}" != "idc" ] && [ "${IPA_INFRA_TYPE}" != "spc" ] && [ -f "./install-ipa-client.sh" ] && [ "${IPA_ANSIBLE}" != "ansible" ]; then
    . ./install-ipa-client.sh
else
    echo "##################################"
    echo -e ${msg}
    echo "please run :"
    echo "cd ${IPA_PATH}"
    echo ". ./install-ipa-client.sh"
    echo "##################################"
fi
