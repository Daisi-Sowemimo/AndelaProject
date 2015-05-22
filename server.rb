require "sinatra"
require "data_mapper"
#require "bcrypt"



configure do
  enable :sessions
	DataMapper::setup(:default, "mysql://root:user@localhost/contactmanager")
end

class User
  include DataMapper::Resource
  #include BCrypt
  property :id, Serial
  property :username, Text, :required => true
  property :password, BCryptHash, :required => true
  property :phone, String
  has n, :contacts
end

class Contact
	include DataMapper::Resource
  	property :id, Serial
  	property :firstname, Text, :required => true
  	property :lastname, Text
  	property :phone, String 
  	property :address, String
  	property :email, Text
    property :website, Text
    property :company, Text
    belongs_to :user
end

DataMapper.finalize.auto_upgrade!

get "/" do
  @user = User.get(session[:id])
	erb :index
end

get "/login" do
  erb :login
end

get "/signup" do
	erb :signup
end

post "/login" do
  @user = User.first(username: params[:username])
  if @user && @user.password == params[:password]
    session[:id] = @user.id
    session[:username] = @user.username
    redirect "/users/#{session[:username]}/profile"
  else
    redirect "/signup"
  end
  erb :login
end

delete "/logout" do
  seesion.destroy
  redirect "/"
end

post "/signup" do
	@user = User.new
  @user.username = params[:username]
  @user.phone = params[:phone]
   if params[:pwd] == params[:confirmpwd]
   @user.password = params[:pwd]
   else
    redirect "/signup"
   end
   @user.save
   session[:id] = @user.id
   session[:username] = @user.username
   redirect "/users/#{session[:username]}/profile"
end



  get "/users/:username/profile" do
  @user = User.all(:username => params[:username])
  @contacts = Contact.all(:user_id => session[:id])
  for i in @user
    if params[:username] == i.username
      @user = i
    end  
  end
    erb :profile
  end
  

post "/profile" do
  @contact = Contact.new
  @contact.firstname = params[:firstname] 
  @contact.lastname = params[:lastname]
  @contact.phone= params[:phone] 
  @contact.address = params[:address]
  @contact.email = params[:email]
  @contact.website = params[:website]
  @contact.company = params[:company]
  @contact.user = User.get(session[:id])
  @contact.save
  redirect "/users/#{session["name"]}/profile"
end

post "/edit" do
  @contact = Contact.get(params[:id])
  if params[:delete]
    @contact.destroy
  else
    @contact.update(firstname: params[:firstname], lastname: params[:lastname], phone: params[:phone], address: params[:address], email: params[:email], website:params[:website], company: params[:company])
  end
  redirect "/users/#{session["name"]}/profile"
end

get "/logout" do
  session.clear
  redirect "/login"
end