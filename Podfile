platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!
workspace 'PopularPhotos.xcworkspace'

abstract_target 'shared_pods' do
    pod 'Alamofire', '~> 4.4.0'
    pod 'ESPullToRefresh', '~> 2.6.0'
    pod 'ImageViewer', '~> 4.1.0'
    pod 'SDWebImage', '~> 3.8.2'
    pod 'GreedoLayout', '~> 1.2.0'
    target 'PopularPhotos' do
        project 'PopularPhotos/PopularPhotos.xcodeproj'
    end
    target 'PopularPhotosTests' do
        project 'PopularPhotos/PopularPhotos.xcodeproj'
    end
end
