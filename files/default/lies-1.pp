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

package {"nmap":
  ensure => absent;
}

mount { "/mnt/nfsmount":
  device => "127.0.0.1:/srv/nfssrv",
  fstype => "nfs",
  ensure  => "unmounted",
  options => "defaults",
  atboot  => true,
}

file { "/mnt/nfsmount/file-1":
  ensure => present,
  require => Mount["/mnt/nfsmount"];
}

file { "/mnt/nfsmount/file-2":
  ensure => present,
  require => Mount["/mnt/nfsmount"];
}

file { "/mnt/nfsmount/file-3":
  ensure => present;
}

# puppet apply /tmp/lies-1.pp --noop

