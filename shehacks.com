##
# You should look at the following URL's in order to grasp a solid understanding
# of Nginx configuration files in order to fully unleash the power of Nginx.
# https://www.nginx.com/resources/wiki/start/
# https://www.nginx.com/resources/wiki/start/topics/tutorials/config_pitfalls/
# https://wiki.debian.org/Nginx/DirectoryStructure
#
# In most cases, administrators will remove this file from sites-enabled/ and
# leave it as reference inside of sites-available where it will continue to be
# updated by the nginx packaging team.
#
# This file will automatically load configuration files provided by other
# applications, such as Drupal or Wordpress. These applications will be made
# available underneath a path with that package name, such as /drupal8.
#
# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
##

# Default server configuration
#
server {
#
#	root /var/www/html;
#
#	index index.html index.htm index.nginx-debian.html;
	server_name shehacks.thomasszyd.com;
#
	location / {
		include proxy_params;
		proxy_pass http://127.0.0.1:5000;
	}
#
#	location /static {
#		alias <path-to-your-application>/static;
#		expires 30d;
#	}
#
	location /socket.io {
		include proxy_params;
		proxy_http_version 1.1;
#		proxy_buffering off;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection "Upgrade";
		proxy_pass http://127.0.0.1:5000;
		proxy_cache_bypass $http_upgrade;
	}

#	location / {
#		proxy_pass http://127.0.0.1:5000;
#		try_files $uri $uri/ =404;
#	}


	listen [::]:443 ssl ipv6only=on; # managed by Certbot
	listen 443 ssl; # managed by Certbot
	ssl_certificate /etc/letsencrypt/live/shehacks.thomasszyd.com/fullchain.pem; # managed by Certbot
	ssl_certificate_key /etc/letsencrypt/live/shehacks.thomasszyd.com/privkey.pem; # managed by Certbot
	include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
	ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

server {
	if ($host = shehacks.thomasszyd.com) {
		return 301 https://$host$request_uri;
	} # managed by Certbot

	listen 80 default_server;
	listen [::]:80 default_server;

	server_name shehacks.thomasszyd.com;
	return 404; # managed by Certbot

}
