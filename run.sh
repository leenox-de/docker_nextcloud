#!/bin/bash

export PATH=/usr/bin:$PATH

if [[ -z "$RUN_AS" ]]; then
	RUN_AS=nextcloud
fi

if [[ -z "$RUN_AS_GROUP" ]]; then
	RUN_AS_GROUP=$RUN_AS
fi

echo -e "RUN_AS='$RUN_AS'\nRUN_AS_GROUP='$RUN_AS_GROUP'" > /run_as

sed -e "s/www-data/$RUN_AS/g" -i /etc/php/7.2/fpm/pool.d/www.conf
sed -e "s/user \+nginx;/user $RUN_AS;/" -i /etc/nginx/nginx.conf

#chown -R $RUN_AS.$RUN_AS /srv
while read a; do
	rm -rf /srv/www/$a
done <<< $(ls /srv/www | grep -Ev '(config|userapps)')

tar -xjf nextcloud.tar.bz2 --strip-components=1 --owner=nextcloud --group=nextcloud -C /srv/www
chown -R $RUN_AS.$RUN_AS_GROUP /srv

if [[ -f /srv/www/config/config.php ]]; then
	/usr/bin/occ upgrade
	if [[ $? -ne 0  && $? -ne 3 ]]; then
		echo "Trying ownCloud upgrade again to work around ownCloud upgrade bug..."
		/usr/bin/occ upgrade
		if [[ $? -ne 0 && $? -ne 3 ]]; then
			exit 1;
		fi
		/usr/bin/occ maintenance:mode --off
		echo "...which seemed to work."
	fi
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf
