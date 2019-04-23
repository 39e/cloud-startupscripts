#!/bin/bash
# Install Caddy server
# doc: https://github.com/mholt/caddy/tree/master/dist/init/linux-systemd

curl https://getcaddy.com | bash -s personal
chown root:root /usr/local/bin/caddy
chmod 755 /usr/local/bin/caddy
setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy


groupadd --system --gid 48 caddy
useradd \
  --gid caddy --no-user-group \
  --home-dir /var/www --no-create-home \
  --shell /bin/false \
  --system --uid 48 caddy

mkdir -p /etc/caddy
chown -R root:root /etc/caddy
mkdir -p /etc/ssl/caddy
chown -R root:caddy /etc/ssl/caddy
chmod 770 /etc/ssl/caddy

cat <<EOL > /etc/caddy/Caddyfile
http:// {
  gzip
  root /var/www/html
}
EOL


mkdir -p /var/www/html
cat <<EOL > /var/www/html/index.html
<h1>Hello World!</h1>
EOL
chown -R caddy:caddy /var/www
chmod 555 /var/www


curl -s https://raw.githubusercontent.com/39e/cloud-startupscripts/master/caddy/caddy.service -o /etc/systemd/system/caddy.service
chown root:root /etc/systemd/system/caddy.service
chmod 644 /etc/systemd/system/caddy.service
systemctl daemon-reload
systemctl start caddy.service
systemctl enable caddy.service
