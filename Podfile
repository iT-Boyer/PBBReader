target 'PBBReader' do
    platform :osx, '10.11'
    use_frameworks!
    project 'ScaryBugsMac.xcodeproj'
    pod 'EDStarRating'
    pod 'CocoaAsyncSocket'
    pod 'FMDB'
    pod 'SnapKit', '~> 0.30.0.beta2'

    target 'ScaryBugsMacTests' do
        inherit! :search_paths
        pod 'EDStarRating'
    end
end