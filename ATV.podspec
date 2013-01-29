Pod::Spec.new do |s|
  s.name         = "ATV"
  s.version      = "0.0.1"
  s.summary      = "A pluggable table view with a different data source for each section."
  s.homepage     = "https://github.com/pnc/ATV"

  s.license      = 'MIT (example)'
  s.author       = { "Phil Calvin" => "pnc1138@gmail.com" }
  s.source       = { :git => "https://github.com/pnc/ATV.git", :tag => "0.0.1" }

  s.platform     = :ios, '4.3'
  s.source_files = 'ATV/*.{h,m}'
end
