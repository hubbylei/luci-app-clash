#!/bin/sh 

enable=$(uci get clash.config.enable 2>/dev/null)
yaml_path=$(uci get clash.config.use_config 2>/dev/null)

if [ ${enable} -eq 1 ];then
	if [ ! $(pidof clash) ]; then
		if [ ! -f ${yaml_path} ];then
			/usr/share/clash/update.sh 2>/dev/null &
		fi
		if [ ! -f /etc/clash/clash ] && [ ! -f /etc/clash/clashtun/clash ] && [ ! -f /etc/clash/dtun/clash ];then
			/usr/share/clash/core_download.sh 2>/dev/null &
		fi
		/etc/init.d/clash restart 2>&1 &
	fi
fi





