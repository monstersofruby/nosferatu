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
  has n, :comments
  property :id, Integer, :serial => true
  property :title, String
  property :url, String
  property :votes, Integer, :default => 0
  property :description, Text
  property :created_at, DateTime
  property :updated_at, DateTime
  # 
  # validates_presence_of :title
  # validates_presence_of :url
end

class Comment
  include DataMapper::Resource
  belongs_to :link
  property :id, Integer, :serial => true
  property :author, String
  property :body, Text
  property :link_id, Integer
  property :created_at, DateTime
  # 
  # validates_presence_of :title
  # validates_presence_of :url
end


DataMapper.auto_upgrade!

Camping.goes :Nosferatu


module Nosferatu::Controllers

  class LinksIndex < R '(/|/links|/links.json)'
    def get(format)
      @links = Link.all
      unless format =~ /.json/
        render :links_index
      else
         @headers['Content-Type'] = "text/javascript"
         @links.to_json
      end
    end
    
    def post(page_name)
      @link = 
        Link.new(
          :title          => input.title,
          :url            => input.url,
          :description    => input.description,
          :created_at     => Time.now
        )
        
      @link.save
      render :links_show 
    end
  end
 
  class LinksShow < R '/links/(\d+)'
    def get link_id
      @link = Link.first(:id => link_id)
      render :links_show
    end
  end
 
  class LinksNew < R '/links/new'
    def get
      render :links_new
    end
  end
 
  class Votes < R '/links/(\d+)/votes'
    def post(link_id)
      @link = Link.first(:id => link_id)
      @link.update_attributes(:votes => (@link.votes + 1))
      render :links_show
    end
  end
  
  class Comments < R '/links/(\d+)/comments'
    def post(link_id)
      @link = Link.first(:id => link_id)
      @link.comments.create(:author => input.author, :body => input.body, :created_at => Time.now)
      render :links_show
    end
  end
  

end

module Nosferatu::Views

  def layout
    html do
      title { 'Nosferatu Links' }
      body do
        div :id => 'menu' do
          ul do
            li{ a 'portada', :href => '/' }
            li{ a 'añadir enlace', :href => '/links/new' }
          end
        end
        self << yield
      end
    end
  end

  def links_index
    @links.each do |link|
      a link.title, :href => "/links/#{link.id}"
    end
  end
  
  def links_show
    h2 @link.title
    a @link.url, :href => @link.url
    p @link.description
    
    p "Votos: #{@link.votes}"
    form :action => "/links/#{@link.id}/votes", :method => 'post', :id => "new_vote" do
      input :type => 'submit', :value => 'Vota'
    end    
    
    h3 "Comentarios"
    div :id => 'comments' do
      @link.comments.each do |comment|
        p { "#{comment.author} dijo a las #{comment.created_at.to_s}: #{comment.body}" }
      end
    end
    h3 "Opina sobre este link"
    form :action => "/links/#{@link.id}/comments", :method => 'post', :id => "new_comment" do
      textarea :name => 'body'
      label 'Autor'
      input :type => 'text', :name => 'author'
      input :type => 'submit', :value => 'Añadir'
    end
  end
  
  def links_new    
    h2 'Añadir enlace'
    form :action => '/links', :method => 'post' do
      label 'Título'
      input :type => 'text', :name => 'title'
      label 'Url'
      input :type => 'text', :name => 'url'
      label 'Descripción'
      textarea :name => 'description'
      input :type => 'submit', :value => 'Añadir'
    end
  end
end
