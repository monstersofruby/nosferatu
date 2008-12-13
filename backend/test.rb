require 'rubygems'
require 'spec'
require 'nosferatu'

describe Nosferatu::Controllers::LinksIndex do
  describe '/' do
    it 'should be success when LinksIndex' do
      result =
        Nosferatu.get(
          :LinksIndex, 
          'links'
        )
      
      result.links.should_not be_nil
    end
    
    it 'should create Link when create Link' do
      num_before = Link.all.size
      
      Nosferatu.post(
        :LinksIndex, 
        'links',
        :input => {'title' => 'pepe', 'url' => 'url'}
      )
      
      Link.all.size.should == (num_before + 1)
    end
    
    it 'should create Comment' do
      link = Link.first
      num_before = link.comments.size
      
      Nosferatu.post(
        :Comments, 
        link.id,
        :input => {'author' => 'pepe', 'body' => 'url'}
      )
      
      link.reload
      link.comments.size.should be(num_before + 1)
    end
    
    it 'should render show' do      
      Nosferatu.get(
        :LinksIndex, 
        'links'
      )
    end
    
    
  end
end

