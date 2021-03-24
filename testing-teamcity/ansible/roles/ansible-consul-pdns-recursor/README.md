Role Name
=========

# ansible-consul-pdns-recursor
pdns-recursor for consul.
dnsmasq server=/consul/127.0.0.1#8600  does not use TTL.


1. install pdns-recursor
2. set forward-zones-recurse=consul=127.0.0.1:8600 to recursor.conf
3. start pdns-recursor
4. disalbe NetworkManager update resolv.conf
5. update resolv.conf  (nameserver 127.0.0.1)

## Setup consul sample
```
### requirements.yml
- src: brianshumate.consul
  version: v2.3.2

### install brianshumate.consul
# ansible-galaxy install -r requirements.yml

### edit hosts inventory
[consul_instances]
project01  consul_node_role=bootstrap ansible_host=10.1.1.10
flash01    consul_node_role=server    ansible_host=10.1.1.11
flash02    consul_node_role=server    ansible_host=10.1.1.12
template   ansible_host=10.1.1.254   template=true
cache01    ansible_host=10.1.1.30
cache02    ansible_host=10.1.1.31


### plyabook for consul
- hosts: consul_instances
  vars:
    consul_bind_address: "{{ ansible_host }}"
    consul_datacenter: "chocotto"
    consul_enable_script_checks: true
    consul_config_custom:
      dns_config:
        service_ttl:
          "*": "5s"
  roles:
    - brianshumate.consul

  ### for autoscale template
  post_tasks:
    - name: Delete Line
      lineinfile:
        path: "/etc/consul/config.json"
        regexp: "{{ item }}"
        state: "absent"
        backup: "yes"
      with_items:
        - "advertise_addr"
        - "advertise_addr_wan"
        - "node_name"
        - "bind_addr"
      when: template is defined

```

Requirements
------------
None

Role Variables
--------------
None

Dependencies
------------
None

Example Playbook
----------------

    - hosts: servers
      roles:
         - ysakkk.ansible_consul_pdns_recursor

