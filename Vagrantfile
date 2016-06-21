# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "centos-6.5"

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  config.vm.provision "shell",
    privileged: true,
    inline: <<-SHELL
      yum install -y rpm-build;
    SHELL

end
