#!/bin/bash

inits(){
	echo "Script loading... [OK]"
	cd ~
	mkdir ./sb
	cd ./sb
	mkdir temp-download
	cd ./temp-download
	echo 'nameserver 8.8.8.8' >>/etc/resolv.conf
	yum install -y automake autoconf gcc gcc-c++ perl-XML-Parser screen zlib zlib-devel wget make bzip2
	sleep 1
	wget http://eastern-project.googlecode.com/files/transmission_new.tar.gz
	tar -xvzf transmission_new.tar.gz
	if [ "`uname -m`" == "x86_64" ]; then
	run64
	else if [ "`uname -m`" == "i686" ]; then
	run32
	else
	echo "No System Version available!"
	msg
	fi
	fi
}

tarsh(){

	tar zxvf intltool-0.40.6.tar.gz
	cd intltool-0.40.6
	./configure
	make
	make install
	cd ..
	tar zxvf libtool-2.2.6b.tar.gz
	cd libtool-2.2.6b
	./configure
	make
	make install
	cd ..
	tar zxvf pkg-config-0.23.tar.gz
	cd pkg-config-0.23
	./configure
	make
	make install
	cd ..
	tar zxvf curl-7.19.7.tar.gz
	cd curl-7.19.7
	./configure
	make
	make install
	cd ..
	tar zxvf openssl-0.9.8l.tar.gz
	cd openssl-0.9.8l
	./config
	make
	make install
	cd ..
	tar zxvf gettext-0.17.tar.gz
	cd gettext-0.17
	./configure
	make
	make install
	cd ..
	tar xvzf libevent-2.0.12-stable.tar.gz
	cd libevent-2.0.12-stable
	./configure
	make
	make install
	cd ..
	/sbin/ldconfig
	yum install openssl openssl-devel -y
	yum -y install libevent-devel
	tar jxvf transmission-2.32.tar.bz2
	cd transmission-2.32
	./configure
	make
	make install
}
initprogress(){ 
	cd ..
	sleep 1
	mkdir -p /usr/local/transmission
	mkdir -p /home/transmission
	sleep 1
	/usr/local/bin/transmission-daemon -g /usr/local/transmission
	sleep 1
	killall transmission-daemon
	sleep 1
	/usr/local/bin/transmission-daemon -g /usr/local/transmission
	sleep 1
	killall transmission-daemon
	sleep 1
	mv /usr/local/transmission/settings.json /usr/local/transmission/settings.json.bak
	sleep 1
	cp ./settings.json /usr/local/transmission/
}
firewall(){
	/etc/init.d/iptables stop
	iptables -A INPUT -p tcp --dport 5566 -j ACCEPT
	iptables -A INPUT -p tcp --dport 59999:61000 -j ACCEPT
	/etc/init.d/iptables save
	/etc/init.d/iptables restart
	/usr/local/bin/transmission-daemon -g /usr/local/transmission
	sleep 1
	echo /usr/local/bin/transmission-daemon -g /usr/local/transmission >>/etc/rc.local

	
}

run32(){
	
	cd bin

	rpm -ivh epel-release-5-4.noarch.rpm
	rpm -ivh perl-XML-Parser-2.36-1.el5.rfx.i386.rpm
	sleep 3
	tarsh
	initprogress
	firewall
}

run64(){
	cd 64bits

	rpm -ivh perl-XML-Parser-2.36-1.el5.rfx.x86_64.rpm
	rpm -ivh epel-release-5-4.noarch.rpm
	cd ..
	cd ./bin/
	sleep 1
	tarsh
	initprogress
	firewall
}

msg(){
	clear
	echo "Installation completed!"
	echo "If any error occurred, you should reinstall again."
	echo "Would you want to install vsftpd module?[Y/N]"
	read choice
	if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
	setftp
	else
	echo "Vsftp will NOT be installed."
	fi
	echo "Would you want to install Auto RSS Download?[Y/N]"
	read choice
	if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
	flexget
	else
	echo "Flexget will NOT be installed."
	fi

}
setftp(){
	wget -c http://eastern-project.googlecode.com/files/vsftpd-2.3.4.tar.gz
	tar -xvzf vsftpd*.tar.gz
	cd vsftpd-2.3.4
	make && make install
	cd /etc/

	echo "anonymous_enable=NO" > ./vsftpd.conf
	echo "local_enable=YES" >> ./vsftpd.conf
	echo "write_enable=YES" >> ./vsftpd.conf
	echo "local_umask=077" >> ./vsftpd.conf
	echo "dirmessage_enable=YES" >> ./vsftpd.conf
	echo "xferlog_enable=YES" >> ./vsftpd.conf
	echo "connect_from_port_20=YES" >> ./vsftpd.conf
	echo "xferlog_std_format=YES" >> ./vsftpd.conf
	echo "listen=YES" >> ./vsftpd.conf
	echo "chroot_local_user=YES" >> ./vsftpd.conf
	echo "pam_service_name=vsftpd" >> ./vsftpd.conf
	
	chmod 777 ./vsftpd.conf
	chown root:root ./vsftpd.conf
	echo "Enter your FTP Root Directory [ENTER]:"
	read dir
	mkdir -p $dir
	echo "Enter your FTP username and press [ENTER]:"
	read ftpname
	useradd -g ftp -d $dir -s /sbin/nologin $ftpname

	setsebool ftpd_disable_trans 1 
	sleep 1
	/usr/local/sbin/vsftpd &
	echo "/usr/local/sbin/vsftpd &">>/etc/rc.local
	echo "Enter $ftpname's password and press [ENTER]"
	passwd $ftpname
	sleep 1

	YOURIP=`hostname -i`;


	echo "***************************************"
	echo "               Done!                   "
	echo "FTP IP:$YOURIP"
	echo "FTP USER:$ftpname"
	echo "***************************************"
}
flexget(){
	
echo "Coming Soon!!"

}

main(){

	echo "SYSTEM initing..."
	inits
	msg
}

main