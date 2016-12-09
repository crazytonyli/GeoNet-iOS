platform :ios, '9.0'

use_frameworks!

target 'GeoNet' do
  use_frameworks!

  pod 'MWFeedParser', '~> 1.0'
  pod 'FormatterKit/TimeIntervalFormatter', '~> 1.8'

  target 'GeoNetTests' do
    inherit! :search_paths
  end

end

target 'GeoNetAPI' do
  pod 'Result', '~> 3.0'
  pod 'SwiftyJSON', '~> 3.1'
end
