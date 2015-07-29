Sequel.migration do
  change do
    create_table(:items) do
      primary_key :id
      Integer :user_id, null: false
      String :task, null: false
      String :notes
      Time :created_at, null: false
    end
  end
end
