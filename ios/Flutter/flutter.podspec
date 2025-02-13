Pod::Spec.new do |s|
    s.name             = 'flutter'
    s.version          = '1.0.0'
    s.summary          = 'A Flutter Podspec'
    s.homepage         = 'https://flutter.dev'
    s.license          = { :file => '../LICENSE' }
    s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
    s.source           = { :http => 'https://github.com/flutter/flutter.git', :tag => '1.0.0' }
    s.source_files     = 'Classes/**/*'
    s.public_header_files = 'Classes/**/*.h'
    s.dependency 'Flutter'
  end
  