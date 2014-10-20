Files:
'Vagrantfile'
'dev_setup_vagrant.sh'

These files are used to provision a virtual machine to be used as a development environment for Ruby on Rails. The 'Vagrantfile' is used to provide setup commands for Vagrant (http://www.vagrantup.com/) running on Virtualbox.

The 'dev_setup_vagrant.sh' shell script sets up all the software tools required to begin developing on Rails. The database is created and seeded from the existing repository which resides on the host machine and is shared with the guest over NFS, which reduces the performance penalty of virtualization.