#!/bin/sh
# Requires wget and curl

# Download starkiller
URL=$(curl https://github.com/BC-SECURITY/Starkiller/releases/latest -L -s | grep -i appimage | grep href | awk -F"=" '{print $2}' | awk -F" " '{print $1}' | tr -d \")
wget https://github.com/${URL} -O /container/starkiller.appImage

# Extract it
cd /container \
  && chmod +x starkiller.appImage \
  && ./starkiller.appImage --appimage-extract \
  && mv squashfs-root/ starkiller/ \
  && chmod -R 755 starkiller && chmod 4755 starkiller/chrome-sandbox

# Create soft link
cat <<EOF > /usr/local/bin/starkiller
#!/bin/sh
/container/starkiller/starkiller --no-sandbox
EOF
chmod +x /usr/local/bin/starkiller
rm /usr/local/bin/get_starkiller.sh
