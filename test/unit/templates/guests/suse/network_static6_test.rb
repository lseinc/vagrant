# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MIT

require_relative "../../../base"

require "vagrant/util/template_renderer"

describe "templates/guests/suse/network_static6" do
  let(:template) { "guests/suse/network_static6" }

  it "renders the template" do
    result = Vagrant::Util::TemplateRenderer.render(template, options: {
      device:    "eth2",
      ip:        "fde4:8dba:82e1::c4",
    })
    expect(result).to eq <<-EOH.gsub(/^ {6}/, "")
      #VAGRANT-BEGIN
      # The contents below are automatically generated by Vagrant. Do not modify.
      STARTMODE='auto'
      BOOTPROTO='static'
      IPADDR=fde4:8dba:82e1::c4
      DEVICE=eth2
      #VAGRANT-END
    EOH
  end

  it "includes the prefix-length and gateway" do
    result = Vagrant::Util::TemplateRenderer.render(template, options: {
      device:           "eth1",
      ip:               "fde4:8dba:82e1::c4",
      gateway:          "fde4:8dba:82e1::01",
      prefix_length:    "64",
    })
    expect(result).to eq <<-EOH.gsub(/^ {6}/, "")
      #VAGRANT-BEGIN
      # The contents below are automatically generated by Vagrant. Do not modify.
      STARTMODE='auto'
      BOOTPROTO='static'
      IPADDR=fde4:8dba:82e1::c4
      DEVICE=eth1
      GATEWAY=fde4:8dba:82e1::01
      PREFIXLEN=64
      #VAGRANT-END
    EOH
  end
end
