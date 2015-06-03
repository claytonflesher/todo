require "bundler/setup"
require "sinatra"
require_relative "lib/todo/item"
require_relative "lib/todo/database"

db = Todo::Database.new

helpers do
  include ERB::Util
end

get "/admin/list/new" do
  title = "To Do / Admin / New Item"
  items = db.all
  erb :new_item, locals: {title: title, item: Todo::Item.new}
end

get "/admin/list" do
  title = "To Do / Admin"
  items = db.all
  erb :dashboard, locals: {title: title, items: items, item: Todo::Item.new}
end

post "/admin/list" do
  title = "To do / Admin / New Item"
  item = Todo::Item.new(task: params[:task], notes: params[:notes])
  if item.valid?
    db.save(item)
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
