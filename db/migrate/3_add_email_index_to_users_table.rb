Sequel.migration do
  change do
    alter_table(:users) do
      add_index(:email)
    end
  end
end
