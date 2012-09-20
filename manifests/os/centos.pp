# Configuration of CentOS-based nodes
class centos {
  case $operatingsystemrelease {
    5.6: {
      yumrepo {"epel":
        baseurl => "http://download.fedoraproject.org/pub/epel/5/$architecture",
        descr => "EPEL repository",
        gpgcheck => 0,
        enabled => 1;
      }
    }
    default: {
      yumrepo {"epel":
        baseurl => "http://download.fedoraproject.org/pub/epel/6/$architecture",
        descr => "EPEL repository",
        gpgcheck => 0,
        enabled => 1;
      }
    }
  }  
}
