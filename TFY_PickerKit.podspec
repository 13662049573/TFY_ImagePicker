
Pod::Spec.new do |spec|
  spec.name         = "TFY_PickerKit"

  spec.version      = "2.0.0"

  spec.summary      = "相册编辑功能"

  spec.description  = <<-DESC
  相册编辑功能
                   DESC

  spec.homepage     = "http://EXAMPLE/TFY_PickerKit"
  
  spec.license      = "MIT"
 
  spec.author             = { "田风有" => "420144542@qq.com" }
  
  spec.source       = { :git => "http://EXAMPLE/TFY_PickerKit.git", :tag => spec.version }

  spec.platform     = :ios, "12.0"

  spec.source_files  =  "TFY_ImagePicker/TFY_PickerKit/TFY_PickerKit.h"
  
  spec.subspec 'TFYDownload' do |ss|
    ss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYDownload/**/*.{h,m}"
  end

  spec.subspec 'TFYDropMenu' do |ss|
    ss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYDropMenu/**/*.{h,m}"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYPhotoUit"
  end

  spec.subspec 'TFYPhotoEditing' do |ss|
    ss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYPhotoEditing/**/*.{h,m}"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYPhotoUit"
    ss.dependency "TFY_PickerKit/TFYUiit"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYCategory"
  end

  spec.subspec 'TFYUiit' do |ss|
    ss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/**/*.{h,m}"
    
    sss.subspec 'TFYCategory' do |ss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYCategory/**/*.{h,m}"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYTipsGuideView"
    end

    sss.subspec 'TFYColor' do |ss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYColor/**/*.{h,m}"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYCategory"
    end

    sss.subspec 'TFYDrawView' do |ss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYDrawView/**/*.{h,m}"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYCategory"
    end

    sss.subspec 'TFYFilterBar' do |ss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYFilterBar/**/*.{h,m}"
    end

    sss.subspec 'TFYFilterSuite' do |ss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYFilterSuite/**/*.{h,m}"
    end

    sss.subspec 'TFYPhotoUit' do |ss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYPhotoUit/**/*.{h,m}"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYCategory"
      sss.dependency "TFY_PickerKit/TFYVideoUit"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYDrawView"
      sss.dependency "TFY_PickerKit/TFYDropMenu"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYColor"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYFilterSuite"
      sss.dependency "TFY_PickerKit/TFYDownload"
    end

    sss.subspec 'TFYPickerUit' do |ss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYPickerUit/**/*.{h,m}"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYCategory"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYPhotoUit"
      sss.dependency "TFY_PickerKit/TFYVideoEditing"
    end

    sss.subspec 'TFYTipsGuideView' do |ss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYTipsGuideView/**/*.{h,m}"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYCategory"
    end

    sss.subspec 'TFYVideoUit' do |ss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYVideoUit/**/*.{h,m}"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYCategory"

    end

  end

  spec.subspec 'TFYVideoEditing' do |ss|
    ss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYVideoEditing/**/*.{h,m}"
    ss.dependency "TFY_PickerKit/TFYUiit"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYPhotoUit"

  end

  spec.subspec 'TFYPicker' do |ss|
    ss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYPicker/**/*.{h,m}"
    ss.dependency "TFY_PickerKit/TFYPhotoEditing"
    ss.dependency "TFY_PickerKit/TFYVideoEditing"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYPickerUit"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYCategory"
    ss.dependency "TFY_PickerKit/TFYUiit"
  end

  spec.resources    = 'TFY_ImagePicker/TFY_PickerKit/Resources/*.bundle'

  spec.frameworks    = "Foundation","UIKit"
  
  spec.xcconfig = {"ENABLE_STRICT_OBJC_MSGSEND" => "NO", 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) COCOAPODS=1 NDEBUG=1 _DEBUG_TAG_'}

  spec.requires_arc  = true

end
