Pod::Spec.new do |s|
  s.name         = "FJPhotoPicker"
  s.version      = "1.0.4"
  s.summary      = "A simple way to multiselect photos, gif, from ablum,force touch to preview image,support portrait and landscape,multiple languages(Chinese,English)"
  s.homepage     = "http://www.jianshu.com/p/bea2bfed3f3f"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'fangjinfeng' => '116418179@qq.com' }
  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.source       = { :git => "https://github.com/fangjinfeng/FJPhotoPicker.git", :tag => "0.0.5" }
  s.source_files = "FJPhotoPicker/**/*.{h,m}"
  s.resources    = "FJPhotoPicker/Resources/*.{png,xib,nib,bundle}"
  s.requires_arc = true
  s.framework  = 'UIKit'
end
