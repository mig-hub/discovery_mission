# Copyright (c) 2009 Mickael Riga
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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
        destination += '/' unless destination[/\/$/]
        uri_found.path = destination + uri_found.path unless uri_found.path[/^\//]
        unless @roadmap.key?(uri_found.path)
          @roadmap.store(uri_found.path, false)
        end
      end
    end
  end
end