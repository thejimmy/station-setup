#
# Cookbook Name:: desktop-setup
# rECipe:: centos7
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


reboot 'kde_reboot' do
  action :nothing
  delay_mins 1
  reason 'kde systemd link updated'
end

['unzip',
'glx-utils',
'mesa-dri-drivers',
'plymouth-system-theme',
'spice-vdagent',
'xorg-x11-drivers',
'xorg-x11-server-Xorg',
'xorg-x11-utils',
'xorg-x11-xauth',
'xorg-x11-xinit',
'xvattr',
'cjkuni-uming-fonts',
'dejavu-sans-fonts',
'dejavu-sans-mono-fonts',
'dejavu-serif-fonts',
'gnu-free-mono-fonts',
'gnu-free-sans-fonts',
'gnu-free-serif-fonts',
'google-crosextra-caladea-fonts',
'google-crosextra-carlito-fonts',
'jomolhari-fonts',
'khmeros-base-fonts',
'liberation-mono-fonts',
'liberation-sans-fonts',
'liberation-serif-fonts',
'lklug-fonts',
'lohit-assamese-fonts',
'lohit-bengali-fonts',
'lohit-devanagari-fonts',
'lohit-gujarati-fonts',
'lohit-kannada-fonts',
'lohit-malayalam-fonts',
'lohit-marathi-fonts',
'lohit-nepali-fonts',
'lohit-oriya-fonts',
'lohit-punjabi-fonts',
'lohit-tamil-fonts',
'lohit-telugu-fonts',
'madan-fonts',
'nhn-nanum-gothic-fonts',
'open-sans-fonts',
'overpass-fonts',
'paktype-naskh-basic-fonts',
'paratype-pt-sans-fonts',
'sil-abyssinica-fonts',
'sil-nuosu-fonts',
'sil-padauk-fonts',
'smc-meera-fonts',
'stix-fonts',
'thai-scalable-waree-fonts',
'ucs-miscfixed-fonts',
'vlgothic-fonts',
'wqy-microhei-fonts',
'wqy-zenhei-fonts',
'kde-workspace',
'kde-wallpapers',
'kde-style-oxygen',
'kde-style-phase',
'kde-baseapps',
'kde-base-artwork',
'gdm',
'SDL',
'libvpx'].each do |kde_package|
  package kde_package do
    action :install
  end
end

# /etc/systemd/system/default.target -> /lib/systemd/system/multi-user.target

link '/etc/systemd/system/default.target' do
  to '/lib/systemd/system/multi-user.target'
  action :delete
  not_if "ls -l /etc/systemd/system/default.target | grep -q /lib/systemd/system/graphical.target"
end

link '/etc/systemd/system/default.target' do
  to '/lib/systemd/system/graphical.target'
  group 'root'
  owner 'root'
  mode  '0777'
  notifies :request_reboot, 'reboot[kde_reboot]', :delayed
end

node['ops_workstation']['other_packages'].each do |other_package|
  package other_package do
    action :install
  end
end


node['ops_workstation']['other_remote_packages'].each do | other_remote_package |

  if ( other_remote_package['epel'] == true && node['ops_workstation']['use_epel'] == true )

    include_recipe 'yum-epel'

    package other_remote_package['name'] do
      action :install
    end

  elsif ( other_remote_package['use_epel'] == true && node['ops_workstation']['repo'] )

    yum_repository other_remote_package['repo']['name'] do
      description other_remote_package['repo']['description']
      baseurl     other_remote_package['repo']['baseurl']
      gpgkey      other_remote_package['repo']['gpgkey']
      action :create
    end

    package other_remote_package['name'] do
      action :install
    end

  else

    remote_file other_remote_package['install_file'] do
      source  other_remote_package['source_file']
      action  :nothing
      owner   'root'
      group   'root'
      action  :create
      not_if "yum list installed #{other_remote_package['name']} | grep -q #{other_remote_package['name']}"
    end

    rpm_package other_remote_package['name'] do
      source    other_remote_package['install_file']
    end

  end
end

remote_file '/tmp/packer.zip' do
  source node['ops_workstation']['packer_source']
  notifies :run, "bash[extract_packer]", :immediately
end

bash 'extract_packer' do
  cwd '/usr/local/bin'
  code <<-EOH
    unzip /tmp/packer.zip -d /usr/local/bin
    EOH
    action :nothing
end

file '/usr/local/bin/packer' do
  owner 'root'
  group 'root'
  mode  '0755'
end


if node['ops_workstation']['add_r_language'] == true

  #not going to try and manually reference the R RPMs in EPEL right now ...
  include_recipe 'yum-epel'

  node['ops_workstation']['r_lang_pacakges'].each do |r_package|
    package r_package do
      action :install
    end
  end

  rpm_package 'rstudio' do
    source node['ops_workstation']['r_studio_package']
    action :install
  end

end

if node['ops_workstation']['add_docker'] == true

  yum_repository node['ops_workstation']['docker_repo']['name'] do
    description  node['ops_workstation']['docker_repo']['description']
    baseurl      node['ops_workstation']['docker_repo']['baseurl']
    gpgkey       node['ops_workstation']['docker_repo']['gpgkey']
    action :create
  end

  node['ops_workstation']['docker_pacakges'].each do |docker_package|
    package docker_package do
      action :install
    end
  end

end

if node['ops_workstation']['add_java'] == true
  include_recipe 'java'
end

# firewall_rule 'ssh-server' do
#   port [22,3389]
# end

# Fix for xrdp sesman failure on startup
# chcon --type=bin_t /usr/sbin/xrdp
# chcon --type=bin_t /usr/sbin/xrdp-sesman
