Pod::Spec.new do |spec|
    spec.name          = 'PrivoSDK'
    spec.version       = '3.1.0'
    spec.license       = { :type => 'Copyright (c) Privo' }
    spec.homepage      = 'https://github.com/Privo/privo3-ios-sdk'
    spec.authors       = { 'Privo' => '' }
    spec.summary       = 'PRIVO SDK'
    spec.source        = { :git => 'https://github.com/Privo/privo3-ios-sdk.git', :tag => spec.version }
    spec.source_files  = 'Sources/PrivoSDK/**/*'
    spec.module_name   = 'PrivoSDK'
    spec.swift_version = '5.3'
    spec.dependency      'Alamofire', '~> 5.2'
    spec.dependency      'JWTDecode', '~> 2.6'
    spec.platform     = :ios, '13.0'
  end
