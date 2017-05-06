Pod::Spec.new do |s|
  s.name         = "IndexedStorage"
  s.version      = "0.0.1"
  s.summary      = ""
  s.description  = "A wrapper arround Swift.Dictionary that creates and maintains multiple indexes for stored objects."
  s.homepage     = "https://github.com/uberbruns/IndexedStorage"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Karsten Bruns" => "karsten@bruns.me" }
  s.social_media_url   = ""
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/uberbruns/IndexedStorage.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
end
