#!/bin/bash
lan_name=tlan
sublan_name=subtlan
router_name=tlanrouter
DNS_RESOLVER=$1
provider=provider
subprovider=subprovider
START_IP_ADDRESS=$2
END_IP_ADDRESS=$3
PROVIDER_NETWORK_GATEWAY=$4
PROVIDER_NETWORK_CIDR=$5
SELFSERVICE_NETWORK_GATEWAY=192.168.168.1
SELFSERVICE_NETWORK_CIDR=192.168.168.0/24
ch_stat=/var/log/selfservice_stat

if [ ! -f ${ch_stat} ];then
	echo "have done before" > ${ch_stat}

	source admin-openrc
	openstack network create  --share --provider-physical-network provider --provider-network-type flat ${provider}
	openstack subnet create --network provider --allocation-pool start=${START_IP_ADDRESS},end=${END_IP_ADDRESS} --dns-nameserver ${DNS_RESOLVER} --gateway ${PROVIDER_NETWORK_GATEWAY} --subnet-range ${PROVIDER_NETWORK_CIDR} ${provider}

	source demo-openrc
	openstack network create ${lan_name}
	openstack subnet create --network selfservice --dns-nameserver ${DNS_RESOLVER} --gateway ${SELFSERVICE_NETWORK_GATEWAY} --subnet-range ${SELFSERVICE_NETWORK_CIDR} i${lan_name}

	source admin-openrc
	neutron net-update ${provider} --router:external

	source demo-openrc
	openstack router create ${router_name}
	neutron router-interface-add ${router_name} ${sublan_name}
	neutron router-gateway-set ${router_name} ${provider}
fi
