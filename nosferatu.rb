#!ruby
#!/usr/local/bin/ruby -rubygems
require 'camping'
require 'dm-core'
require 'dm-serializer'
require 'json/pure'

### SETUP
DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/nosferatu.sqlite")

### MODELS

class Link
  include DataMapper::Resource
  property :id, Integer, :serial => true
  property :title, String
  property :url, String
  property :description, Text
  property :created_at, DateTime
  property :updated_at, DateTime
  # 
  # validates_presence_of :title
  # validates_presence_of :url
end

DataMapper.auto_upgrade!

Camping.goes :Nosferatu


module Nosferatu::Controllers

 # The root slash shows the `index' view.
 class Index < R '(/|/index.html|/index.json)'
   def get(page_name)
     @links = Link.all
     if page_name =~ /.html/
       render :index
     else
       @headers['Content-Type'] = "text/javascript"
       @links.to_json
     end
  end
 end

 # Any other page name gets sent to the view
 # of the same name.
 #
 #   /index -> Views#index
 #   /sample -> Views#sample
 #
 class Page < R '/(\w+)'
   def get(page_name)
     render page_name
   end
 end

end

module Nosferatu::Views

 # If you have a `layout' method like this, it
 # will wrap the HTML in the other methods.  The
 # `self << yield' is where the HTML is inserted.
def layout
  html do
    title { 'Nosferatu Links' }
    body { self << yield}
  end
end

 # The `index' view.  Inside your views, you express
 # the HTML in Ruby.  See http://code.whytheluckystiff.net/markaby/.
 def index
  @links.each do |link|
    p link.title
  end
 end

 # The `sample' view.
 def sample
   p 'A sample page'
 end
end
