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
end

get "/sign_up" do
  title = "To do / Sign Up"
  erb :sign_up, locals: {title: title, user: Todo::User.new}
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
    redirect "/admin/list"
  else
    erb :login, locals: {title: title}
  end
end

get "/admin/list/new" do
  title = "To Do / Admin / New Item"
  items = db.all
  erb :new_item, locals: {title: title, item: Todo::Item.new}
end

get "/admin/list" do
  title = "To Do / Admin"
  items = db.all
  erb :dashboard, locals: {title: title, items: items, item: Todo::Item.new, user: @user}
end

post "/admin/list" do
  title = "To do / Admin / New Item"
  item = Todo::Item.new(task: params[:task], notes: params[:notes])
  if item.valid?
    db.save_item(item)
    redirect "/admin/list"
  else
    erb :new_item, locals: {title: title, item: item}
  end
end

get "/" do
  title = "To Do"
  items = db.all
  erb :list, locals: {title: title, item: item}
end
