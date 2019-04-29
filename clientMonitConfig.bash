#!/bin/bash
#Client Monit Script
#CIT 470, Project 3, Group 2
#Members: Ashlee Craig, Mark Hans, Ian West, Daniel Loschiavo, Kevin Howell
#

## Functions:
#
#init function
function init {
	load_functions set_logFile		#set log recording
	load_functions setup_by_cmdline	
	load_functions check_services	#check syslog, LDAP, NFS are operating
	load_functions check_ldap
	load_functions check_nfs
	load_functions check_syslog
	load_functions monit_install	#install/config monit
	load_functions monit_config
	
	need_root_priv
}

function setup_by_cmdline {
	#functions call
	set_logFile			#set log recording
	check_services		#check syslog, LDAP, NFS are operating 
	monit_install		#install/config monit
	monit_config
	
}

##rsyslog.conf
#send all syslog messages to the server: *.* @ipaddress:port
#
##monitrc
#monit local monitoring on itself
#monit verify local critical services by processes
#if processes not running, restart
#monitor local resources CPU usage, disk capacity each file system, memory 
#
#notification through at least two channels (email, Syslog, Web)
# email: cit470.sp2019.team.2@gmail.com

#set log recording to include Stnderr and Stndout
function set_logFile{
	exec > >(tee -ia install_log3.log)
	>install_log3.log
	pwd
}

#check services
function check_services {
	check_syslog
	check_ldap
	check_nfs
}

function check_syslog {
	service=rsyslog
	if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 ))
		then echo "$service is running!!!"
	else
		/etc/init.d/$service start
		echo "$service started"
	fi
}

function check_ldap {
	service=ldap
	if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 ))
		then echo "$service is running!!!"
	else
		/etc/init.d/$service start
		echo "$service started"
	fi
}

function check_nfs {
	service=nfs
	if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 ))
		then echo "$service is running!!!"
	else
		/etc/init.d/$service start
		echo "$service started"
	fi
}

#monit install
function monit_install {
	yum install -y sendmail
	systemctl start sendmail
	systemctl enable sendmail
	yum install -y epel-release
	yum install -y monit
	monit -h
}

#monit config backup and wget preset config file
function monit_config {
	cp -p /etc/monitrc /etc/monitrc.BAK
	wget --directory-prefix=/usr/local/etc/ http://www.github.com/project3/client/monitrc >> monitrc
	monit -v
	monit reload
	monit summary
	monit status
}

#firewall to allow traffic
function set_firewall {
	firewall-cmd --zone=public --add-port=514/udp --permanent
	firewall-cmd --zone=public --add-port=514/tcp --permanent
	firewall-cmd --reload
}

## End of Functions
#
#start script
init
setup_by_cmdline