require "sequel"
DB = Sequel.postgres('todo')
Sequel::Model.plugin :validation_helpers

require "bundler/setup"
require "sinatra"
require "bcrypt"
require_relative "models/item"
require_relative "models/user"

enable :sessions
set :session_secret, ""

helpers do
  include ERB::Util
end

before do
  @user = Todo::User.find(:email => session[:email])
end

get "/sign_up" do
  title  = "To Do / Sign Up"
  erb :sign_up, locals: {title: title, user: Todo::User.new, errors: []}
end

post "/sign_up" do
  title  = "To Do / Sign Up"
  user   = Todo::User.new(email: params[:email], password: BCrypt::Password.create(params[:password]), first_name: params[:first_name], last_name: params[:last_name])
  errors = [ ]
  unless user.valid?
    errors.push(user.errors.values)
    errors.flatten!
  end
  if errors.any?
    erb :sign_up, locals: {title: title, user: user, db: db, errors: errors}
  else
    user.save
    redirect "/login"
  end
end

get "/login" do
  title = "To Do / Login"
  erb :login, locals: {title: title}
end

post "/login" do
  title = "To Do / Login"
  user = Todo::User.find(email: params[:email])
  if user && valid_password?(user, params[:password])
    session[:email] = user.email
    redirect "/"
  else
    erb :login, locals: {title: title}
  end
end

post "/logout" do
  session.clear
  redirect "/login"
end

get "/" do
  title = "To Do / Dashboard"
  if @user == nil
    redirect "/login"
  else
    if @user.email
      erb :dashboard, locals: {title: title, item: Todo::Item.new, user: @user}
    else
      redirect "/login"
    end
  end
end

post "/" do
  title = "To Do / Dashboard"
  item = Todo::Item.new(task: params[:task], notes: params[:notes])
  if item.valid?
    @user.add_task(item)
    redirect "/"
  else
    erb :dashboard, locals: {title: title, item: item, user: user}
  end
end

post "/delete/:id" do
  Todo::Item[params['id']].destroy
  redirect "/"
end

def valid_password?(user, password)
  BCrypt::Password.new(user.password) == password
end
