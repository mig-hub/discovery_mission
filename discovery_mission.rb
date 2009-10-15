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
    while destination = @roadmap.rassoc(false)
      response = land_on(destination.first)
      yield(destination, response) if block_given?
      explore(response.body)
      @roadmap.assoc(destination.first)[1] = true
    end
    uri_list = @roadmap.flatten.delete_if {|d| d==true}
    reset
    uri_list
  end

  private
  
  def reset
    @roadmap = [[@domain, false]]
  end

  def land_on(destination)
    begin
      response = Net::HTTP.get_response(destination.to_s)
    rescue Exception
      puts "Error: #{$!}"
    end
    return response
  end

  def explore(html)
    html.scan(/<a href\s*=\s*["']([^"']+)["']/i) do |w|
      url_found = URI("#{w}")
      unless (url_found.absolute? and url_found.host!=@domain.host)
        url_found.host = @domain.host if url_found.relative?
        unless @roadmap.assoc(url_found)
          @roadmap << [url_found, false]
        end
      end
    end
  end
end