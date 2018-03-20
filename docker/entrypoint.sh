#!/bin/sh
set -e 
set -u

cd /home/ops
echo "downloading host keys..."
/usr/local/bin/aws s3 sync s3://${S3_BUCKET_NAME}/host-keys/ /etc/ssh/
chmod -R 600 /etc/ssh/

echo "downloading user keys..."
mkdir authorized_keys
/usr/local/bin/aws s3 sync s3://${S3_BUCKET_NAME}/user-keys/ authorized_keys/
cat authorized_keys/* > .ssh/authorized_keys
chown -R ops ./
chmod -R 0600 authorized_keys/
chmod 0700 .ssh/
chmod 0644 .ssh/authorized_keys


exec /usr/sbin/sshd -D -e "$@"
