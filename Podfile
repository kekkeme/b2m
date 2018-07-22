source 'https://github.com/CocoaPods/Specs.git'
#
platform :ios, '9.0'

inhibit_all_warnings!
use_frameworks!

def all_pods

pod 'ReSwift', '~> 4.0' 

# Reactive pods
pod 'RxSwift', '~> 4.0'
pod 'RxCocoa', '~> 4.0'
pod 'RxKeyboard'

pod 'AlamofireImage'
pod 'CRNotifications'


end

target "B2M" do
	all_pods
end


post_install do |installer|

    installer.pods_project.targets.each do |target|
        puts target.name
    end

end

