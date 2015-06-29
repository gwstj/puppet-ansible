# = Class : ansible::user
#
# == Summary
#
# Create an ansible user
#
# == Description
#
# This class enable the following features :
#
# - create an ansible user
# - create rsa ssh keys
# - run commands with sudo (optional)
#
# The password is managed by puppet.
# By default, it's not possible to log as the ansible user with a password.
# See shadow and sshd manpages for more information about locked account.
#
# == Parameter
#
# [*sudo*]
# set to 'enable' if you want to authorize ansible user to behave like root
#
# == Examples
#
# === Create a ansible user with a non valid password
#
# class { 'ansible::user':
#   sudo => 'enable'
# }
#
# or
#
# include ansible::user
#
# === Create a ansible user with a password
#
# class { 'ansible::user':
#   sudo     => 'enable',
#   password => '<aValidPasswordHash>'
# }
#
class ansible::user(
  $sudo = 'disable',
  $password = '*NP*',
  $username = 'ansible',
) {

  include ansible::params

  # Create an 'ansible' user
  user { $ansible::user::username:
    ensure     => present,
    comment    => 'ansible',
    managehome => true,
    shell      => '/bin/bash',
    home       => "/home/${ansible::user::username}",
    password   => $ansible::user::password
  }

  # Create a .ssh directory for the 'ansible' user
  file { "/home/${ansible::user::username}/.ssh" :
    ensure  => directory,
    mode    => '0700',
    owner   => $ansible::user::username,
    group   => $ansible::user::username,
    require => User[$ansible::user::username],
    notify  => Exec[home_ansible_ssh_keygen]
  }

  # Generate rsa keys for the 'ansible' user
  exec { 'home_ansible_ssh_keygen':
    path    => ['/usr/bin'],
    command => "ssh-keygen -t rsa -q -f /home/${ansible::user::username}/.ssh/id_rsa -N \"\"",
    creates => "/home/${ansible::user::username}/.ssh/id_rsa",
    user    => $ansible::user::username,
    require => Package['openssh-server']
  }

  ensure_packages([ 'openssh-server' ])

  # Enable sudo
  if $ansible::user::sudo == 'enable' {

    # Install and manage sudo
    # (use: https://forge.puppetlabs.com/saz/sudo)
    class { 'sudo': }

    # Ansible user can do everything with sudo
    sudo::conf { 'ansible':
      content => 'ansible ALL = NOPASSWD : ALL',
    }
  }

}
