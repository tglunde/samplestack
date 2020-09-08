#!/bin/bash

if [ -z ${TIMEZONE+x} ]; then
  export TIMEZONE="Europe/Zurich"
fi
# set the timezone of the container
sudo /opt/datavaultbuilder/bin/update_timezone.sh ${TIMEZONE}

chmod a+w /files

if [ -n "$DAV_USER" ]; then
  if [ -n "$DAV_PASSWORD" ]; then
    rm -f /etc/nginx/.htpasswd
    htpasswd -bc /etc/nginx/htpasswd "$DAV_USER" "$DAV_PASSWORD"
  else
    echo "DAV_USER was set, but not DAV_PASSWORD."
  fi
fi

if [ "${DISABLE_IPV6:-}" = "true" ]; then
  sed -i 's/^\s*listen \[::\]/#        listen [::]/' /etc/nginx/sites-available/default.conf
  sed -i 's/^\s*listen \[::\]/#        listen [::]/' /etc/nginx/sites-available/default-ssl.conf
else
  sed -i 's/^#\s*listen \[::\]/        listen [::]/' /etc/nginx/sites-available/default.conf
  sed -i 's/^#\s*listen \[::\]/        listen [::]/' /etc/nginx/sites-available/default-ssl.conf
fi



if [ -f /etc/secrets/ssl_fullchain ] && [ -f /etc/secrets/ssl_private_key ]; then
  ln -sf /etc/nginx/sites-available/default-ssl.conf /etc/nginx/sites-enabled/default.conf
else
  ln -sf /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf
fi
  
nginx -g "daemon off;"
