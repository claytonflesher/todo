Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :email, null: false
      String :password, null: false
      String :first_name, null: false
      String :last_name, null: false
    end
  end
end
