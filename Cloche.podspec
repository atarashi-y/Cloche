# coding: utf-8

Pod::Spec.new do |spec|
  spec.name = "Cloche"
  spec.version = "0.1.3"
  spec.summary = "Sorted collections written in pure Swift."
  spec.homepage = "https://github.com/atarashi-y/Cloche"
  spec.license = {
     :type => 'Apache License, Version 2.0',
     :file => 'LICENSE'
  }
  spec.author = { "Yoshinori Atarashi" => "yoshinori.atarashi@gmail.com" }
  spec.source = {
     :git => "https://github.com/atarashi-y/Cloche.git",
     :tag => "#{spec.version}"
  }

  spec.swift_version = '5.0'
  spec.ios.deployment_target = '10.0'
  spec.osx.deployment_target = '10.12'
  spec.tvos.deployment_target = '10.0'
  spec.watchos.deployment_target = '3.0'
  spec.source_files = "Sources/Cloche/*.swift"
end
