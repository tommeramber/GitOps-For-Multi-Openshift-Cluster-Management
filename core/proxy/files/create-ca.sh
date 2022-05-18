cat > csr_answer.txt << EOF
[req]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = dn
[ dn ]
C=US
ST=New York
L=New York
O=MyOrg
OU=MyOU
emailAddress=me@working.me
CN = registry
EOF

openssl req -newkey rsa:4096 -nodes -sha256 -keyout ca.key -x509 -days 365 -out ca.crt -config <( cat csr_answer.txt )
