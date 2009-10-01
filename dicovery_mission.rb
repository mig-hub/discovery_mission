require 'net/http'
require 'uri'

class DiscoveryMission
  def initialize(url)
    @domain = URI.parse(url)
    @domain.path = "/" if @domain.path == ""
    reset
    puts "Discovery Mission Planned for #{@domain}"
  end
  
  def launch
    until @queue.empty?
      url = @queue.shift
      response = land_on(url)
      yield((@domain + url), response)
      explore(page)
      @visited[url] = true
    end
    all_paths = @visited.keys.map {|k| k.to_s}
    reset
    all_paths
  end

  private
  
  def reset
    @visited, @queue = [], {}
    new_planet(@domain.path)
  end

  def new_planet(path)
    @queue.push path
    @visited[path] = false
  end

  def land_on(path)
    begin
      url = @domain.clone
      url.path = url.path + path unless path == "/"
      puts "Landing on #{url}"
      response = Net::HTTP.get_response(url)
    rescue Exception
      puts "Error: #{$!}"
    end
    return response
  end

  def explore(html)
    html.scan(/<a href\s*=\s*["']([^"']+)["']/i) do |w|
      url = URI.parse("#{w}")
      if !@visited.has_key?(url.path) and (url.relative? or url.host == @domain.host)
        new_planet(url.path)
      end
    end
  end
end