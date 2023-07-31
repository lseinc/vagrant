# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MIT

require_relative "../../../base"

require "vagrant/util/template_renderer"

describe "templates/guests/gentoo/network_static" do
  let(:template) { "guests/gentoo/network_static" }

  it "renders the template" do
    result = Vagrant::Util::TemplateRenderer.render(template, options: {
      device:  "en0",
      ip:      "1.1.1.1",
      netmask: "255.255.0.0",
    })
    expect(result).to eq <<-EOH.gsub(/^ {6}/, "")
      #VAGRANT-BEGIN
      # The contents below are automatically generated by Vagrant. Do not modify.
      config_en0=("1.1.1.1 netmask 255.255.0.0")
      modules_en0=("!plug")
      #VAGRANT-END
    EOH
  end

  it "includes the gateway" do
    result = Vagrant::Util::TemplateRenderer.render(template, options: {
      device:  "en0",
      ip:      "1.1.1.1",
      netmask: "255.255.0.0",
      gateway: "1.2.3.4",
    })
    expect(result).to eq <<-EOH.gsub(/^ {6}/, "")
      #VAGRANT-BEGIN
      # The contents below are automatically generated by Vagrant. Do not modify.
      config_en0=("1.1.1.1 netmask 255.255.0.0")
      modules_en0=("!plug")
      gateways_en0="1.2.3.4"
      #VAGRANT-END
    EOH
  end
end
