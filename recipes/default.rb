#
# Cookbook Name:: dry-run-lies
# Recipe:: default
#
# Copyright 2012-2013, A Fistful of Servers
# Author:: Sean OMeara <someara@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

########################################
# Set up machine with initial conditions
########################################

include_recipe 'nfs::server'

directory '/srv/nfssrv' do
  owner 'root'
  recursive true
end

directory '/mnt/nfsmount' do
  action :create
  recursive true
  owner 'root'
end

file '/srv/nfssrv/file-1' do
  content 'hi there\n'
end

file '/srv/nfssrv/file-2' do
  content 'I am a text file\n'
end

file '/srv/nfssrv/file-3' do
  content 'Adam likes cheese.\n'
end

# export that directory via nfs to localhost
nfs_export '/srv/nfssrv' do
  network '127.0.0.1/32'
  writeable true
  sync true
  options ['no_root_squash']
end

# mount the NFS share locally
mount '/mnt/nfsmount' do
  device '127.0.0.1:/srv/nfssrv'
  fstype 'nfs'
  options 'rw'
end

################################################
# Drop off a CFEngine policy to run in noop mode
################################################

package "cfengine3"

inputs_dir = "/var/cfengine/inputs"

directory inputs_dir do
  action :create
  recursive true
end

cookbook_file "#{inputs_dir}/cfengine_stdlib.cf"
cookbook_file "#{inputs_dir}/failsafe.cf"
cookbook_file "#{inputs_dir}/promises.cf"

cookbook_file '/tmp/lies-1.cf' do
  source 'lies-1.cf'
end

##############################################
# Drop off a Puppet policy to run in noop mode
##############################################

cookbook_file '/tmp/lies-1.pp' do
  source 'lies-1.pp'
end

################################################
# Here be Dragons.
################################################

package "nmap" do
  only_if "/usr/bin/test -f /usr/bin/puppet"
end

package "puppet" do
  action [:remove, :purge]
end

package "puppet-common" do
  action [:remove, :purge]
end

#
execute "hack the planet" do
  command "/bin/echo HACKING THE PLANET"
  only_if "/usr/bin/test -f /usr/bin/nmap"
end

# chef-solo -c /tmp/vagrant-chef-1/solo.rb -j /tmp/vagrant-chef-1/dna.json -Fmin --why-run
