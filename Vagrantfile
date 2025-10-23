# -*- mode: ruby -*-
# vi: set ft=ruby :

# Loader file to keep the main configuration under infrastructure/Vagrantfile.
# This allows running `vagrant` commands from the repository root while
# maintaining all provisioning logic inside the infrastructure directory.

main_vagrantfile = File.expand_path('infrastructure/Vagrantfile', __dir__)

unless File.exist?(main_vagrantfile)
  abort "Main Vagrantfile not found at #{main_vagrantfile}."
end

load main_vagrantfile
