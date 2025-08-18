Pod::Spec.new do |spec|
  spec.name         = "MonetaiSDK"
  spec.version      = "1.2.0"
  spec.summary      = "Monetai iOS SDK for predictive user analytics and monetization"
  spec.description  = <<-DESC
                      Monetai iOS SDK provides powerful predictive analytics to help you understand
                      user behavior and optimize monetization strategies. Features include user
                      prediction, discount management, and event tracking.
                   DESC

  spec.homepage     = "https://github.com/hayanmind/monetai-ios"
  spec.license      = { :type => "Apache-2.0", :file => "LICENSE" }
  spec.author       = { "Monetai" => "support@monetai.com" }

  spec.ios.deployment_target = "13.0"
  spec.swift_version = "5.0"

  spec.source       = { :git => "https://github.com/hayanmind/monetai-ios.git", :tag => "#{spec.version}" }

  spec.source_files = "Sources/MonetaiSDK/**/*.swift"
  spec.frameworks   = "Foundation", "StoreKit", "Combine"

  spec.dependency 'Alamofire', '~> 5.8'

  spec.pod_target_xcconfig = {
    'SWIFT_VERSION' => '5.0'
  }
end 