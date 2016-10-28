#!/bin/bash
mkdir /home/ubuntu/
echo "mysql !" >> /home/ubuntu/res.txt

exec "$@"
