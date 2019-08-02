Pod::Spec.new do |s|
  s.name = "SwiftWebVTT"
  s.version = "1.0.1"
  s.summary = "A parser for WebVTT caption files written in Swift"
  s.homepage = "https://github.com/auramagi/SwiftWebVTT"
  s.license = { type: 'MIT', file: 'LICENSE' }
  s.authors = { "Mike Apurin" => 'mike.apurin@gmail.com' }
  s.source = { :git => 'https://github.com/auramagi/SwiftWebVTT.git', :tag => s.version }
  
  s.ios.deployment_target = '12.0'
  
  s.swift_version = '5.0'
  
  s.source_files = "SwiftWebVTT/*.{h,swift}"
  s.resources = ["SwiftWebVTT/*.{json}"]
end