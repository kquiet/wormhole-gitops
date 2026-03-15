#!/bin/bash

# bcrypt_hash.sh <password>
# Hash the given password using bcrypt via embedded Python

if [ -z "$1" ]; then
  echo "Usage: $0 <password>"
  exit 1
fi

PASSWORD="$1"

python3 - <<END
import bcrypt

password = "$PASSWORD".encode("utf-8")
hashed = bcrypt.hashpw(password, bcrypt.gensalt(12, prefix=b"2a"))
print(hashed.decode("utf-8"))
END