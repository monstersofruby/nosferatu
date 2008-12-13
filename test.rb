require 'rubygems'
require 'spec'
require 'nosferatu'

describe Nosferatu::Controllers::Index do
  describe '/' do
    it 'should be success' do
      get '/'
      response.should be_success
    end
  end
end

