if platform_family?('rhel')

  default['ops_workstation']['use_epel'] = true

  default['ops_workstation']['packer_source'] = 'https://releases.hashicorp.com/packer/0.10.0/packer_0.10.0_linux_amd64.zip'

  default['ops_workstation']['other_packages'] = [
    'openssh-clients',
    'git',
    'wget',
    'curl',
    'gedit',
    'lsb-core-noarch',
    'tigervnc-server-minimal',
    'net-tools'
  ]

  default['ops_workstation']['other_remote_packages'] = [
    { 'install_file' => '/tmp/yakuake.x86_64.rpm',    'source_file' => 'http://mirrors.mit.edu/epel/7/x86_64/y/yakuake-2.9.9-7.el7.x86_64.rpm', 'name' => 'yakuake', 'epel' => true },
    { 'install_file' => '/tmp/atom.x86_64.rpm',       'source_file' => 'https://atom.io/download/rpm',                                          'name' => 'atom' },
    { 'install_file' => '/tmp/xrdp.x86_64.rpm',       'source_file' => 'http://mirrors.mit.edu/epel/7/x86_64/x/xrdp-0.9.0-4.el7.x86_64.rpm',    'name' => 'xrdp', 'epel' => true  },
    { 'install_file' => '/tmp/vagrant.x86_64.rpm',    'source_file' => 'https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.rpm', 'name' => 'vagrant' },
    { 'install_file' => '/tmp/VirtualBox.x86_64.rpm', 'source_file' => 'http://download.virtualbox.org/virtualbox/rpm/rhel/7/x86_64/VirtualBox-5.1-5.1.0_108711_el7-1.x86_64.rpm',  'name' => 'VirtualBox', 'repo' => {
        'name' => 'virtualbox',
        'description' => "Oracle Linux / RHEL / CentOS-$releasever / $basearch - VirtualBox",
        'baseurl' => "http://download.virtualbox.org/virtualbox/rpm/el/$releasever/$basearch",
        'gpgkey' => 'https://www.virtualbox.org/download/oracle_vbox.asc'
       }
     }
  ]

  if node['ops_workstation']['add_r_language'] == false
    default['ops_workstation']['r_lang_pacakges'] = [
      'R'
    ]
    default['ops_workstation']['r_studio_package'] = 'https://download1.rstudio.org/rstudio-0.99.896-x86_64.rpm'
  end

  if node['ops_workstation']['add_docker'] == false

    default['ops_workstation']['docker_repo'] = {
            'name' => 'dockerrepo',
            'description' => "Docker Repository",
            'baseurl' => "https://yum.dockerproject.org/repo/main/centos/$releasever/",
            'gpgkey' => 'https://yum.dockerproject.org/gpg'
          }

    default['ops_workstation']['docker_pacakges'] = [
      'docker-engine'
    ]

  end


end
