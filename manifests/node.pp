# = Class : ansible::node
#
# == Summary
#
# Configure a host which can be managed by an ansible master host
#
# == Description
#
# This class enable the following features :
#
# - create an ansible user
# - install/configure sudo
# - export host keys
# - set the authorized_keys file with the public key of the ansible master node
#
# == Parameter
#
# [*master*]
# The fqdn of the master host (**string**) (**required**)
#
# [*sudo*]
# Set to 'disable' if you don't want to authorize ansible user to behave like
# root (**boolean**) (**optional**)
#
# == Example
#
# class { 'ansible::node' :
#   master  => 'master.fqdn.tld'
# }
#
class ansible::node(
  $master = 'none'
  $sudo   = 'enable'
  ){

  include ansible::params

  if $ansible::node::master == 'none' {
    fail('master parameter must be set')
  }
  if ($ansible::node::sudo != 'enable' and $ansible::node::sudo != 'disable') {
    fail('sudo parameter must be "enable" or "disable"')
  }

  # Export host key to store config
  @@sshkey { "ansible_${::fqdn}_rsa":
    host_aliases => [ $::fqdn, $::hostname, $::ipaddress ],
    type         => 'ssh-rsa',
    key          => $::sshrsakey,
    tag          => "ansible_node_${ansible::node::master}_rsa"
  }

  # Authorize master host to connect via ssh by colleting its public key
  Ssh_authorized_key <<| tag == "ansible_master_${ansible::node::master}" |>>

  # Create ansible user with sudo
  class { 'ansible::user' :
    sudo => $ansible::node::sudo
  }

}
