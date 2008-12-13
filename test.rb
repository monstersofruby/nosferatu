require 'rubygems'
require 'spec'
require 'nosferatu'

describe Nosferatu::Controllers::LinksIndex do
  describe '/' do
    it 'should be success' do
      Nosferatu::Controllers::LinksIndex.new().get('/')
      response.should be_success
    end
  end
end

