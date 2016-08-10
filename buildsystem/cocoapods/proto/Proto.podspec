Pod::Spec.new do |s|
  s.name     = 'Proto'
  s.version  = '0.0.1'
  s.license  = 'New BSD'
  s.authors  = { 'gRPC contributors' => 'grpc-io@googlegroups.com' }
  s.homepage = 'http://www.grpc.io/'
  s.summary = 'RemoteTest example'
  s.source = { :git => 'https://github.com/grpc/grpc.git' }

  s.ios.deployment_target = '7.1'
  s.osx.deployment_target = '10.9'

  s.dependency "!ProtoCompiler-gRPCPlugin", "~> 1.0.0-pre1"

  protoc = "/usr/local/bin/protoc"
  plugin = "/usr/local/bin/grpc_objective_c_plugin"
  proto_dir = "../../../proto"

  s.prepare_command = <<-CMD
    #{protoc} \
        --plugin=protoc-gen-grpc=#{plugin} \
        --objc_out=. \
        --grpc_out=. \
        --proto_path #{proto_dir}/ \
        #{proto_dir}/**.proto
  CMD

  s.subspec 'Messages' do |ms|
    ms.source_files = '**.pbobjc.{h,m}'
    ms.public_header_files = '**.pbobjc.h'
    ms.header_mappings_dir = '.'
    ms.requires_arc = false
    ms.dependency 'Protobuf'
    # This is needed by all pods that depend on Protobuf:
    ms.pod_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1',
    }
  end

  s.subspec 'Services' do |ss|
    ss.source_files = '**.pbrpc.m', '**.pbrpc.h'
    ss.public_header_files = '**.pbrpc.h'
    ss.header_mappings_dir = '.'
    ss.requires_arc = true
    ss.dependency 'gRPC-ProtoRPC'
    ss.dependency "#{s.name}/Messages"
  end
end
