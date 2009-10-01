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
      path = @queue.shift
      response = land_on(path)
      yield(@domain+path, response) if block_given?
      explore(response.body)
      @explored << path
    end
    all_paths = @explored.map {|k| @domain.host + k.to_s}
    reset
    all_paths
  end

  private
  
  def reset
    @explored, @queue = [], [@domain.path]
  end

  def land_on(path)
    begin
      clone = @domain.clone
      clone.path = clone.path + path unless path == "/"
      puts "Landing on #{clone}" if @verbose
      response = Net::HTTP.get_response(clone)
    rescue Exception
      puts "Error: #{$!}"
    end
    return response
  end

  def explore(html)
    html.scan(/<a href\s*=\s*["']([^"']+)["']/i) do |w|
      url_found = URI.parse("#{w}")
      if !@explored.include?(url_found.path) and (url_found.relative? or url_found.host == @domain.host)
        @queue << url_found.path
      end
    end
  end
end