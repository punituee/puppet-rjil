#
# This has been shamelessly lifed from stacktira
#
# This is essentially the profile for haproxy
#
#
class rjil::haproxy (
  $radosgw_port          = '80',
  $horizon_port          = '80',
  $horizon_https_port    = '443',
  $novncproxy_port       = '6080',
  $keystone_public_port  = '5000',
  $keystone_admin_port   = '35357',
  $glance_port           = '9292',
  $glance_registry_port  = '9191',
  $cinder_port           = '8776',
  $nova_port             = '8774',
  $neutron_port          = '9696',
  $metadata_port         = '8775',
  $nova_ec2_port         = '8773',
  $nova_ec2_enabled      = true,
  $metadata_enabled      = true,
  $nova_enabled          = true,
  $cinder_enabled        = true,
  $glance_enabled        = true,
  $neutron_enabled       = true,
  $keystone_enabled      = true,
  $novncproxy_enable     = true,
  $radosgw_enabled       = true,
  $horizon_enabled       = true,
) {

  # TODO - add all services for openstack here, and get rid of the
  # haproxy/openstack and haproxy_service classes

  rjil::jiocloud::logrotate { 'haproxy': }

  package { ['nagios-plugins-contrib', 'libwww-perl', 'libnagios-plugin-perl']:
    ensure => 'present'
  }

  # add all openstack components like this
  if $keystone_enabled {
    $keystone_backends = {
      'real.keystone' => {'ports' => $keystone_public_port},
      'real.keystone-admin' => {'ports' => $keystone_admin_port}
    }
  } else {
    $keystone_backends = {}
  }

  $backends = merge({}, $keystone_backends)

  class { 'haproxy_consul':
    backends         => $backends,
    consul_wait      => '5s:30s',
    consul_log_level => 'debug',
  }

}
