Pod::Spec.new do |s|
  s.name         = "MFBannerView"
  s.version      = "1.0.0"
  s.summary      = "MFBannerView is a auto scroll banner view suport horizontal and vertical direction."
  s.homepage     = "https://github.com/itdongbaojun/MFBannerView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "董宝君" => "itdongbaojun@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/itdongbaojun/MFBannerView.git", :tag => "#{s.version}" }
  s.source_files = "MFBannerView/MFBannerView/**/*.{h,m}"
  s.public_header_files = "MFBannerView/MFBannerView/**/*.h"
  s.requires_arc = true
end
