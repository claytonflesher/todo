require "bundler/setup"
require "sinatra"
require_relative "lib/todo/item"
require_relative "lib/todo/database"
require_relative "lib/todo/user"

enable :sessions

db = Todo::Database.new
db.setup

helpers do
  include ERB::Util
end

before do
  @user = db.load_user(session[:email])
end

get "/sign_up" do
  title  = "To Do / Sign Up"
  errors = [ ]
  erb :sign_up, locals: {title: title, user: Todo::User.new, db: db, errors: errors}
end

post "/sign_up" do
  title  = "To Do / Sign Up"
  user   = Todo::User.new(email: params[:email], password: params[:password], first_name: params[:first_name], last_name: params[:last_name])
  errors = [ ]
  unless user.valid?
    errors.push(user.errors)
    errors.flatten!
  end
  if db.load_user(user.email)
    errors << "This email is not available. Please login or choose another."
  end
  if errors.any?
    erb :sign_up, locals: {title: title, user: user, db: db, errors: errors}
  else
    db.save_user(user)
    redirect "/login"
  end
end

get "/login" do
  title = "To Do / Login"
  erb :login, locals: {title: title}
end

post "/login" do
  title = "To Do / Login"
  user = db.authenticate(email: params[:email], password: params[:password])
  if user
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
    db.save_user(@user)
    redirect "/"
  else
    erb :dashboard, locals: {title: title, item: item, user: @user}
  end
end

post "/delete/:slug" do
  @user.delete_task(params['slug'])
  db.save_user(@user)
  redirect "/"
end
