platform :ios, '6.0'
pod 'AFNetworking',	  '~> 1.3.1'
pod 'AFHTTPRequestOperationLogger',	'~> 0.10.0'
pod 'MBProgressHUD', '~> 0.8'
pod 'OHHTTPStubs', '2.0.0'
pod 'MagicalRecord', '2.2'
pod 'FMDB', '2.1'
pod 'SDWebImage', '3.5'
pod 'JMImageCache', '0.4.0'
pod 'NSDate+TimeAgo'
pod 'MKNetworkKit'
pod 'FDTake', '0.1'
pod 'GoogleAnalytics-iOS-SDK', '3.0.2'

post_install do |installer|
  installer.project.targets.each do |target|
    target.build_configurations.each do |config|
      s = config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
      s ||= [ '$(inherited)' ]
    s.push('MR_ENABLE_ACTIVE_RECORD_LOGGING=0');
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = s
    end
  end
end
