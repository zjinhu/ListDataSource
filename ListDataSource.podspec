
Pod::Spec.new do |s|

  s.name         = "ListDataSource"
  s.version      = "0.0.1"
  s.summary      = "A short description of ListDataSource."

  s.homepage         = 'https://github.com/jackiehu/ListDataSource'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jackiehu' => 'jackie' }
  s.source           = { :git => 'https://github.com/jackiehu/ListDataSource.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  
  s.swift_versions     = ['4.2','5.0','5.1','5.2']
  s.requires_arc = true

  s.source_files = 'Sources/**/*'
end
