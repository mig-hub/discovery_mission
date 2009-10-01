A SPACE ODYSSEY

This is just a simple, basic and lightweight crawler.
It is used to reference all URLs of your website in order to record them on a database, and use them for a sitemap manager.

Just put the file somewhere you can require it and then you're ready to take off:

require 'discovery_mission'

# Use a block to do something with each path

DiscoveryMission.for("http://www.my-domain.com") do |url, response|
	SitemapEntry.new(url) if response.code=='200'
	puts "Dave Bowman landed on #{url}"
end

# Or just without a block because an Array with all paths is returned

my_sitemap_entries = DiscoveryMission.for("http://www.my-domain.com")