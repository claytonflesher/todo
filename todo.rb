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
  erb :dashboard, locals: {title: title, item: Todo::Item.new}
end

post "/admin/list" do
  title = "To do / Admin / New Item"
  item = Blog::Item.new(task: params[:task], notes: param[:notes])
  if item.valid?
    db.save(item)
  else
    erb :new_item, locals: {title: title, item: item}
  end
end

get "/" do
  title = "To Do"
  items = db.all
  erb :list, locals: {title: title, item: item}
end
