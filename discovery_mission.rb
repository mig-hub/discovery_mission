require 'net/http'
require 'uri'

class DiscoveryMission
  
  def self.for(domain, &block)
    new(domain).launch(&block)
  end
  
  def initialize(domain)
    @domain = URI(domain)
    @domain.path = "/" if @domain.path == ""
    reset
    puts "Discovery Mission Planned for #{@domain}"
  end
  
  def launch
    while destination = @roadmap.find {|k,v| v==false}
      response = land_on(destination.first)
      yield(destination.first, response) if block_given?
      explore(destination.first, response)
      @roadmap[destination.first] = true
    end
    uri_list = @roadmap.keys
    reset
    uri_list
  end

  private
  
  def reset
    @roadmap = {@domain.path => false}
  end

  def land_on(destination)
    begin
      response = Net::HTTP.get_response(@domain.host, destination)
    rescue Exception
      puts "Error: #{$!}"
    end
    return response
  end

  def explore(destination, response)
    html = response.body
    html.scan(/<a href\s*=\s*["']([^"']+)["']/i) do |w|
      uri_found = URI("#{w}") rescue nil
      unless (uri_found.nil? or (uri_found.absolute? and uri_found.host!=@domain.host) or (uri_found.path=='' or uri_found.path=='#' or uri_found.path[/^javascript/]))
        uri_found.path = destination + uri_found.path unless uri_found.path[/^\//]
        unless @roadmap.key?(uri_found.path)
          @roadmap.store(uri_found.path, false)
        end
      end
    end
  end
end