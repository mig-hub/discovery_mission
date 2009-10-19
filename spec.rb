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

require 'rubygems'
require 'bacon'
Bacon.summary_on_exit

MyResponse = Struct::new(:body)

def template_this(content)
  "<html><head><title></title</head><body>#{content}</body></html>"
end

require File.expand_path('./discovery_mission', File.dirname(__FILE__))
class DiscoveryMission
  attr_reader :roadmap
  def land_on(destination)
    destination=='/' ? MyResponse.new("<html><head><title></title</head><body><a href='/good/destination'>click</a></body></html>") : MyResponse.new('')
  end
end

describe DiscoveryMission do
  describe 'explore' do
    before do
      @dm = DiscoveryMission.new('http://www.domain.com')
    end
    it 'Should add correct destinations to roadmap' do
      html = template_this("<a href='/good/destination'>click</a>")
      @dm.explore("/", MyResponse.new(html))
      @dm.roadmap.keys.should.include?('/good/destination')
    end
    it 'Should not raise when bad URI' do
      html = template_this("<a href='http://'>click</a>")
      @dm.explore("/", MyResponse.new(html))
      @dm.roadmap.keys.should==["/"]
    end
    it 'Should skip pointless uri' do
      html = template_this(<<-EOT)
        <a href='http://www.another_domain.com'>click</a>
        <a href='http://www.another_domain.com/with/path'>click</a>
        <a href='#'>click</a>
        <a href='javascript:void(0);'>click</a>
      EOT
      @dm.explore("/", MyResponse.new(html))
      @dm.roadmap.keys.should==["/"]
    end
    it 'Sould add current path if uri is relative to it' do
      html = template_this("<a href='chapter_one'>click</a>")
      @dm.explore("/novel", MyResponse.new(html))
      @dm.roadmap.keys.should.include?("/novel/chapter_one")
    end
    it 'Should not duplicate entries' do
      html = template_this(<<-EOT)
        <a href='/'>click</a>
        <a href='http://www.domain.com'>click</a>
      EOT
      @dm.explore("/", MyResponse.new(html))
      @dm.roadmap.keys.should==["/"]
    end
  end
  describe 'launch' do
    it 'Should be reseted for next launch' do
      dm = DiscoveryMission.new('http://www.domain.com')
      dm.launch.size.should==2
      dm.roadmap.size.should==1
    end
  end
end