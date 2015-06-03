require "bundler/setup"
require "sinatra"
require_relative "lib/todo/item"
require_relative "lib/todo/database"
require_relative "lib/todo/user"

enable :sessions

db = Todo::Database.new

helpers do
  include ERB::Util
end

before do
  @user = db.load_user(session[:email])
  db.setup
end

get "/sign_up" do
  title = "To do / Sign Up"
  erb :sign_up, locals: {title: title, user: Todo::User.new}
end

get "/logout" do
  title = "To do / Logout"
  erb :logout, locals: {title: title}
end

post "/sign_up" do
  title = "To do /Sign Up"
  user = Todo::User.new(email: params[:email], password: params[:password], first_name: params[:first_name], last_name: params[:last_name])
  if user.valid?
    db.save_user(user)
    redirect "/login"
  else
    erb :sign_up, locals: {title: title, user: user}
  end
end

get "/login" do
  title = "To Do / Login"
  erb :login, locals: {title: title}
end

post "/login" do
  title = "To do / Login"
  user = db.authenticate(email: params[:email], password: params[:password])
  if user
    session[:email] = user.email
    redirect "/"
  else
    erb :login, locals: {title: title}
  end
end

post "/logout" do
  title = "To do / Logout"
  session.clear
  redirect "/login"
end

get "/" do
  title = "To Do / Dashboard"
  if @user.email
    items = db.all
    erb :dashboard, locals: {title: title, items: items, item: Todo::Item.new, user: @user}
  else
    redirect "/login"
  end
end

post "/" do
  title = "To Do / Dashboard"
  item = Todo::Item.new(task: params[:task], notes: params[:notes])
  if item.valid?
    db.save_item(item)
    redirect "/"
  else
    erb :dashboard, locals: {title: title, item: item}
  end
end
