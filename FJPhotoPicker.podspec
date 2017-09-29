Pod::Spec.new do |s|
  s.name         = "FJPhotoPicker"
  s.version      = "1.0.2"
  s.summary      = "图片选择器:一句话集成系统相册、拍照、手机相册等选取图片"
  s.homepage     = "http://www.jianshu.com/p/bea2bfed3f3f"
 s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'fangjinfeng' => '116418179@qq.com' }
  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.source       = { :git => "https://github.com/fangjinfeng/FJPhotoPicker.git", :tag => "0.0.4" }
  s.source_files = "FJPhotoPicker/**/*.{h,m}"
  s.resources    = "FJPhotoPicker/Resources/*.{png,xib,bundle}"
  s.requires_arc = true
  s.framework  = 'UIKit'
end
