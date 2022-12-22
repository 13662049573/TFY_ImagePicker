
Pod::Spec.new do |spec|
  spec.name         = "TFY_PickerKit"

  spec.version      = "2.0.2"

  spec.summary      = "相册编辑功能"

  spec.description  = <<-DESC
  相册编辑功能
                   DESC

  spec.homepage     = "https://github.com/13662049573/TFY_ImagePicker"
  
  spec.license      = "MIT"
 
  spec.author       = { "田风有" => "420144542@qq.com" }
  
  spec.source       = { :git => "https://github.com/13662049573/TFY_ImagePicker.git", :tag => spec.version }

  spec.platform     = :ios, "12.0"

  spec.source_files  =  "TFY_ImagePicker/TFY_PickerKit/TFY_PickerKit.h"
  
  spec.subspec 'TFYPhotoEditing' do |ss|
    ss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYPhotoEditing/**/*.{h,m}"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYPhotoUit"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYItools"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYCategory"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYFilterBar"
  end

  spec.subspec 'TFYPickerEditing' do |ss|
    ss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYPickerEditing/**/*.{h,m}"
    ss.dependency "TFY_PickerKit/TFYPhotoEditing"
    ss.dependency "TFY_PickerKit/TFYVideoEditing"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYItools"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYPickerUit"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYCategory"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYPhotoUit"
  end

  spec.subspec 'TFYVideoEditing' do |ss|
    ss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYVideoEditing/**/*.{h,m}"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYPhotoUit"
    ss.dependency "TFY_PickerKit/TFYUiit/TFYFilterBar"
  end

  spec.subspec 'TFYUiit' do |ss|
    ss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/**/*.{h,m}"
    ss.resources    = 'TFY_ImagePicker/TFY_PickerKit/TFYUiit/Resources/*.bundle'

    ss.subspec 'TFYCategory' do |sss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYCategory/**/*.{h,m}"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYItools"
    end

    ss.subspec 'TFYColor' do |sss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYColor/**/*.{h,m}"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYCategory"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYItools"
    end

    ss.subspec 'TFYDownload' do |sss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYDownload/**/*.{h,m}"
    end

    ss.subspec 'TFYDrawView' do |sss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYDrawView/**/*.{h,m}"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYCategory"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYItools"
    end

    ss.subspec 'TFYDropMenu' do |sss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYDropMenu/**/*.{h,m}"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYItools"
    end

  
    ss.subspec 'TFYFilterBar' do |sss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYFilterBar/**/*.{h,m}"
    end

    ss.subspec 'TFYFilterSuite' do |sss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYFilterSuite/**/*.{h,m}"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYItools"
    end

    ss.subspec 'TFYItools' do |sss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYItools/**/*.{h,m}"
    end

    ss.subspec 'TFYPhotoUit' do |sss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYPhotoUit/**/*.{h,m}"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYCategory"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYItools"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYColor"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYDropMenu"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYDrawView"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYDownload"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYFilterSuite"
    end

    ss.subspec 'TFYPickerUit' do |sss|
      sss.source_files  = "TFY_ImagePicker/TFY_PickerKit/TFYUiit/TFYPickerUit/**/*.{h,m}"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYCategory"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYItools"
      sss.dependency "TFY_PickerKit/TFYUiit/TFYPhotoUit"
    end
    
  end

  spec.frameworks    = "Foundation","UIKit"
  
  spec.xcconfig = {"ENABLE_STRICT_OBJC_MSGSEND" => "NO", 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) COCOAPODS=1 NDEBUG=1 _DEBUG_TAG_'}

  spec.requires_arc  = true

end
