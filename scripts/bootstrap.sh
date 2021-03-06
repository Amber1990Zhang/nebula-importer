#!/bin/sh

set -e

addr=$1
port=$2

curl -fsSL https://studygolang.com/dl/golang/go1.13.4.linux-amd64.tar.gz -o go1.13.4.linux-amd64.tar.gz
tar zxf go1.13.4.linux-amd64.tar.gz -C /usr/local/

export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin
export GOPATH=/usr/local/nebula/
export GO111MODULE=on
export GOPROXY=https://goproxy.cn

pushd ./importer/cmd
go build -o ../../nebula-importer
popd

until echo "quit" | ./bin/nebula -u user -p password --addr=$addr --port=$port &> /dev/null; do
  >&2 echo "nebula graph is unavailable - sleeping"
  sleep 1
done

>&2 echo "nebula graph is up - executing command"
cat ./importer/example/example.ngql | ./bin/nebula -u user -p password --addr=$addr --port=$port
sleep 5
./nebula-importer --config ./importer/example/example.yaml
