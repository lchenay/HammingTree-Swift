Pod::Spec.new do |s|
  s.name = "HammingTree"
  s.version = "0.0.1"

  s.source = { :git => "https://github.com/lchenay/HammingTree-Swift" }
  s.source_files "HammingTree/*"
  s.frameworks = "Foundation"
  s.requires_arc = true
end
