require 'net/http'
require 'uri'

class DiscoveryMission
  
  def self.for(domain, verbose=false, &block)
    journey = new(domain, verbose)
    journey.launch(&block)
  end
  
  def initialize(domain, verbose=false)
    @domain = URI.parse(domain)
    @domain.path = "/" if @domain.path == ""
    @verbose = verbose
    reset
    puts "Discovery Mission Planned for #{@domain}" if @verbose
  end
  
  def launch
    until @queue.empty?
      url = @queue.shift
      response = land_on(url)
      yield((@domain + url), response) if block_given?
      explore(response.body)
      @visited[url] = true
    end
    all_paths = @visited.keys.map {|k| @domain + k.to_s}
    reset
    all_paths
  end

  private
  
  def reset
    @visited, @queue = {}, []
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
      puts "Landing on #{url}" if @verbose
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