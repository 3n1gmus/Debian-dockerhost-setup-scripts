# creates network named 'proxy' that is bound to the host IP of the '--ip' setting

docker network create -o "com.docker.network.bridge.host_binding_ipv4"="192.168.1.20" proxy # Change ip address to match your system