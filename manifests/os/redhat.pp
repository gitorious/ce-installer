# Configuration of Redhat
class redhat {
  case $::operatingsystemrelease {
    default: { notify{'Not supported on your OS': } }
    /^5.*/: {
      yumrepo {'epel':
        baseurl  => "http://download.fedoraproject.org/pub/epel/5/${::architecture}",
        descr    => 'EPEL repository',
        gpgcheck => 0,
        enabled  => 1;
      }
    }
    /^6.*/: {
      yumrepo {'epel':
        baseurl  => "http://download.fedoraproject.org/pub/epel/6/${::architecture}",
        descr    => 'EPEL repository',
        gpgcheck => 0,
        enabled  => 1;
      }
    }
  }
}
