source 'https://github.com/CocoaPods/Specs.git'
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'
# Uncomment this line if you're using Swift
use_frameworks!

workspace 'RxFun'

def commons
    pod 'RxSwift', '4.4.1'
end

target 'FunWithRxSwift' do
    project 'FunWithRxSwift/FunWithRxSwift.xcodeproj'
    commons
end

# post_install do |installer|
#     installer.pods_project.targets.each do |target|
#         target.build_configurations.each do |config|
#             config.build_settings['ENABLE_BITCODE'] = "YES"
#             config.attributes.delete('EMBEDDED_CONTENT_CONTAINS_SWIFT')
#         end
#     end
# end
