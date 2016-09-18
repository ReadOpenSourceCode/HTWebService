
Pod::Spec.new do |s|

  s.name         = "HTWebService"
  s.version      = "1.0.0"
  s.summary      = "An network layer framework help you handle JSON to Object mapping, business status judgement etc.
"
  s.description  = <<-DESC
                    An network layer framework help you handle JSON to Object mapping, business status judgement etc.
                    Ease use.
                   DESC
  s.homepage     = "https://github.com/DeveloperPans/HTWebService"
  s.license      = "MIT"
  s.author       = { "Pan" => "developerpans@163.com" }
  s.social_media_url = 'http://shengpan.net'
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source       = { :git => "https://github.com/DeveloperPans/HTWebService.git", :tag => s.version.to_s }
  s.source_files = 'HTWebService/*.{h,m}'
  s.frameworks = 'UIKit'
  s.dependency 'AFNetworking'
  s.dependency 'Reachability'

end
