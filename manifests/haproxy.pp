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
  $nova_vncproxy_enable  = true,
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

  if $nova_ec2_enabled {
    $nova_ec2_enabled = {
      'real.nova-ec2' => {'ports' => $nova_ec2_port}
    }
  } else {
    $nova_ec2_backend = {}
  }

  if $metadata_enabled {
    $metadata_backends = {
      'real.metadata' => {'ports' => $metadata_port},
    }
  } else {
    $metadata_backends = {}
  }

  if $nova_enabled {
    $nova_backends = {
      'real.nova' => {'ports' => $nova_port},
    }
  } else {
    $nova_backends = {}
  }

  if $cinder_enabled {
    $cinder_backends = {
      'real.cinder' => {'ports' => $cinder_port},
    }
  } else {
    $cinder_backends = {}
  }

  if $glance_enabled {
    $glance_backends = {
      'real.glance' => {'ports' => $glance_port},
      'real.glance-registry' => {'ports' => $glance_registry_port},
    }
  } else {
    $glance_backends = {}
  }

  if $neutron_enabled {
    $neutron_backends = {
      'real.neutron' => {'ports' => $neutron_port},
    }
  } else {
    $neutron_backends = {}
  }

  if $nova_vncproxy_enabled {
    $nova_vncproxy_backends = {
      'real.nova_vncproxy' => {'ports' => $nova_vncproxy_port},
    }
  } else {
    $nova_vncproxy_backends = {}
  }

  if $radosgw_enabled {
    $radosgw_backends = {
      'real.radosgw' => {'ports' => $radosgw_port},
    }
  } else {
    $radosgw_backends = {}
  }

  $backends = merge({}, $keystone_backends)

  class { 'haproxy_consul':
    backends         => $backends,
    consul_wait      => '5s:30s',
    consul_log_level => 'debug',
  }

}
