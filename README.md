# Docker Nextcloud image

## Usage
Assumeing you have you created a directory for your data and put saved the path in `$STORAGE`. Create some subdirectories

```
mkdir -p $STORAGE/config
mkdir -p $STORAGE/data
mkdir -p $STORAGE/userapps
```
And copy your nextcloud `config.php` to `$STORAGE/config`.

```
docker run -p 80:80 -e RUN_AS=$USER \
    -v $STORAGE/config:/srv/www/config
    -v $STORAGE/data:/srv/data \
    -v $STORAGE/userapps:/srv/www/userapps \
    -v /dev/log:/dev/log \
    -v /var/run/systemd/journal/socket:/var/run/systemd/journal/socket \
    -v /etc/passwd:/etc/passwd:ro \
    -v /etc/group:/etc/group:ro \
    junkdna/nextcloud:latest
```

This would expose your nextcloud to the world without encryption. SO DO NOT DO THIS FOR PRODUCTION.
What you should do is use
https://github.com/jwilder/docker-gen
and
https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion
In order to get your nextcloud behind a https connection.
