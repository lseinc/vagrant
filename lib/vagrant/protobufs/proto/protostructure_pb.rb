# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MIT

# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: protostructure.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("protostructure.proto", :syntax => :proto3) do
    add_message "protostructure.Struct" do
      repeated :fields, :message, 1, "protostructure.Struct.Field"
    end
    add_message "protostructure.Struct.Field" do
      optional :Name, :string, 1
      optional :PkgPath, :string, 2
      optional :Tag, :string, 3
      optional :type, :message, 4, "protostructure.Type"
    end
    add_message "protostructure.Type" do
      oneof :type do
        optional :primitive, :message, 1, "protostructure.Primitive"
        optional :container, :message, 2, "protostructure.Container"
        optional :struct, :message, 3, "protostructure.Struct"
      end
    end
    add_message "protostructure.Primitive" do
      optional :kind, :uint32, 1
    end
    add_message "protostructure.Container" do
      optional :kind, :uint32, 1
      optional :elem, :message, 2, "protostructure.Type"
      optional :key, :message, 3, "protostructure.Type"
      optional :count, :int32, 4
    end
  end
end

module Protostructure
  Struct = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("protostructure.Struct").msgclass
  Struct::Field = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("protostructure.Struct.Field").msgclass
  Type = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("protostructure.Type").msgclass
  Primitive = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("protostructure.Primitive").msgclass
  Container = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("protostructure.Container").msgclass
end
