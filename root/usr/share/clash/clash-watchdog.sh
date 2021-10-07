#!/bin/sh 

enable=$(uci get clash.config.enable 2>/dev/null)
CORETYPE=$(uci get clash.config.core 2>/dev/null)
CONFIG_YAML=$(uci get clash.config.use_config 2>/dev/null)
url=$(uci get clash.config.clash_url)
MODELTYPE=$(uci get clash.config.download_core)

if [ $CORETYPE -eq 1 ];then
	CORE_PATH="/etc/clash/clash"
elif [ $CORETYPE -eq 3 ];then
	CORE_PATH="/etc/clash/clashtun/clash"
elif [ $CORETYPE -eq 4 ];then
	CORE_PATH="/etc/clash/dtun/clash"
fi

dcore(){
	echo '' >/tmp/clash_update.txt 2>/dev/null

	if [ -f /usr/share/clash/core_down_complete ];then 
		rm -rf /usr/share/clash/core_down_complete 2>/dev/null
	fi

	if [ $CORETYPE -eq 4 ];then
		if [ -f /usr/share/clash/download_dtun_version ];then 
			rm -rf /usr/share/clash/download_dtun_version
		fi

		new_clashdtun_core_version=`wget -qO- "https://hub.fastgit.org/Dreamacro/clash/releases/tag/premium"| grep "/download/premium/"| head -n 1| awk -F " " '{print $2}'| awk -F "-" '{print $4}'| sed "s/.gz\"//g"`

		if [ $new_clashdtun_core_version ]; then
			echo $new_clashdtun_core_version > /usr/share/clash/download_dtun_version 2>&1 & >/dev/null
		elif [ $new_clashdtun_core_version =="" ]; then
			echo 0 > /usr/share/clash/download_dtun_version 2>&1 & >/dev/null
		fi

		sleep 5

		if [ -f /usr/share/clash/download_dtun_version ];then
			CLASHDTUNC=$(sed -n 1p /usr/share/clash/download_dtun_version 2>/dev/null) 
		fi
	fi

	if [ $CORETYPE -eq 3 ];then
		if [ -f /usr/share/clash/download_tun_version ];then 
			rm -rf /usr/share/clash/download_tun_version
		fi
	
		new_clashtun_core_version=`wget -qO- "https://hub.fastgit.org/comzyh/clash/tags"| grep "/comzyh/clash/releases/"| head -n 1| awk -F "/tag/" '{print $2}'| sed 's/\">//g'`

		if [ $new_clashtun_core_version ]; then
			echo $new_clashtun_core_version > /usr/share/clash/download_tun_version 2>&1 & >/dev/null
		elif [ $new_clashtun_core_version =="" ]; then
			echo 0 > /usr/share/clash/download_tun_version 2>&1 & >/dev/null
		fi

		sleep 5

		if [ -f /usr/share/clash/download_tun_version ];then
			CLASHTUN=$(sed -n 1p /usr/share/clash/download_tun_version 2>/dev/null) 
		fi
	fi

	if [ $CORETYPE -eq 1 ];then
		if [ -f /usr/share/clash/download_core_version ];then
			rm -rf /usr/share/clash/download_core_version
		fi

		new_clashr_core_version=`wget -qO- "https://hub.fastgit.org/Dreamacro/clash/tags"| grep "/Dreamacro/clash/releases/"| head -n 1| awk -F "/tag/" '{print $2}'| sed 's/\">//g'`

		if [ $new_clashr_core_version ]; then
			echo $new_clashr_core_version > /usr/share/clash/download_core_version 2>&1 & >/dev/null
		elif [ $new_clashr_core_version =="" ]; then
			echo 0 > /usr/share/clash/download_core_version 2>&1 & >/dev/null
		fi

		sleep 5

		if [ -f /usr/share/clash/download_core_version ];then
			CLASHVER=$(sed -n 1p /usr/share/clash/download_core_version 2>/dev/null) 
		fi
	fi

	if [ -f /tmp/clash.gz ];then
		rm -rf /tmp/clash.gz >/dev/null 2>&1
	fi

	if [ $CORETYPE -eq 1 ];then
		wget --no-check-certificate  https://hub.fastgit.org/Dreamacro/clash/releases/download/"$CLASHVER"/clash-"$MODELTYPE"-"$CLASHVER".gz -O 2>&1 >1 /tmp/clash.gz
	elif [ $CORETYPE -eq 3 ];then 
		wget --no-check-certificate  https://hub.fastgit.org/comzyh/clash/releases/download/"$CLASHTUN"/clash-"$MODELTYPE"-"$CLASHTUN".gz -O 2>&1 >1 /tmp/clash.gz
	elif [ $CORETYPE -eq 4 ];then 
		wget --no-check-certificate  https://hub.fastgit.org/Dreamacro/clash/releases/download/premium/clash-"$MODELTYPE"-"$CLASHDTUNC".gz -O 2>&1 >1 /tmp/clash.gz
	fi

	if [ "$?" -eq "0" ] && [ "$(ls -l /tmp/clash.gz |awk '{print int($5)}')" -ne 0 ]; then
	    gunzip /tmp/clash.gz >/dev/null 2>&1\
		&& rm -rf /tmp/clash.gz >/dev/null 2>&1\
		&& chmod 755 /tmp/clash\
		&& chown root:root /tmp/clash 
		  
		if [ $CORETYPE -eq 1 ];then
			rm -rf /etc/clash/clash >/dev/null 2>&1
			mv /tmp/clash /etc/clash/clash >/dev/null 2>&1
			rm -rf /usr/share/clash/core_version >/dev/null 2>&1
			mv /usr/share/clash/download_core_version /usr/share/clash/core_version >/dev/null 2>&1
		elif [ $CORETYPE -eq 3 ];then
			rm -rf /etc/clash/clashtun/clash >/dev/null 2>&1
			mv /tmp/clash /etc/clash/clashtun/clash >/dev/null 2>&1
			rm -rf /usr/share/clash/tun_version >/dev/null 2>&1
			mv /usr/share/clash/download_tun_version /usr/share/clash/tun_version >/dev/null 2>&1
			tun=$(sed -n 1p /usr/share/clash/tun_version 2>/dev/null)
			sed -i "s/${tun}/v${tun}/g" /usr/share/clash/tun_version 2>&1
		elif [ $CORETYPE -eq 4 ];then
			rm -rf /etc/clash/dtun/clash >/dev/null 2>&1
			mv /tmp/clash /etc/clash/dtun/clash >/dev/null 2>&1
			rm -rf /usr/share/clash/dtun_version >/dev/null 2>&1
			mv /usr/share/clash/download_dtun_version /usr/share/clash/dtun_version >/dev/null 2>&1
			dtun=$(sed -n 1p /usr/share/clash/dtun_version 2>/dev/null)
			sed -i "s/${dtun}/v${dtun}/g" /usr/share/clash/dtun_version 2>&1leep 2
		fi
		touch /usr/share/clash/core_down_complete >/dev/null 2>&1
		sleep 2
		rm -rf /var/run/core_update >/dev/null 2>&1
		echo "" > /tmp/clash_update.txt >/dev/null 2>&1
	fi	
}

if [ ${enable} -eq 1 ];then
	if [ ! $(pidof clash) ]; then
		if [ ! -f ${CONFIG_YAML} ] || [ "$(ls -l $CONFIG_YAML|awk '{print int($5)}')" -eq 0 ];then
			wget --no-check-certificate --user-agent="Clash/OpenWRT" $url -O 2>&1 >1 $CONFIG_YAML
		fi
		if [ ! -f $CORE_PATH ];then
			dcore
		fi
		/etc/init.d/clash restart
	fi
fi





