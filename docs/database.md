# Database Best Practices

This guide covers PostgreSQL-specific patterns and best practices for the Mindful application.

## PostgreSQL Version

We use PostgreSQL 18+. Make sure your local development environment matches this version to avoid compatibility issues.

## Migrations

### General Guidelines

- **Never edit existing migrations** that have been committed and run in production. Create a new migration instead.
- **Keep migrations reversible** when possible by defining both `up` and `down` methods or using reversible migration methods.
- **Test migrations both ways**: Run `rails db:migrate` and `rails db:rollback` to ensure they work in both directions.
- **One logical change per migration**: Don't combine multiple unrelated changes in a single migration file.

### Naming Conventions

Use descriptive migration names that clearly indicate what the migration does:

```bash
# Good
rails generate migration AddIndexToUsersEmail
rails generate migration RemoveDeprecatedFieldsFromPosts
rails generate migration CreateOrdersTable

# Bad
rails generate migration UpdateUsers
rails generate migration FixStuff
```

### Adding Indexes

Always add indexes for:
- Foreign keys
- Columns used in `WHERE` clauses frequently
- Columns used in `ORDER BY` or `GROUP BY`
- Columns with uniqueness constraints

**Use `add_index` with the `algorithm: :concurrently` option in production** to avoid locking tables:

```ruby
class AddIndexToUsersEmail < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :users, :email, algorithm: :concurrently
  end
end
```

Note: `disable_ddl_transaction!` is required when using `algorithm: :concurrently`.

### Adding Columns with Default Values

When adding a column with a default value to a large table, use this pattern to avoid locking:

```ruby
class AddActiveToUsers < ActiveRecord::Migration[8.0]
  def change
    # Step 1: Add column without default
    add_column :users, :active, :boolean
    
    # Step 2: Set default for new records only
    change_column_default :users, :active, from: nil, to: true
    
    # Step 3: Backfill existing records (if needed)
    # Do this in a separate migration or background job for large tables
  end
end
```

For small tables, you can safely use:

```ruby
add_column :users, :active, :boolean, default: true, null: false
```

### Removing Columns

For zero-downtime deployments, use a multi-step process:

1. **Ignore the column** in your model first (deploy this):

```ruby
class User < ApplicationRecord
  self.ignored_columns += [:deprecated_field]
end
```

2. **Create a migration** to remove the column (deploy this later):

```ruby
class RemoveDeprecatedFieldFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :deprecated_field, :string
  end
end
```

3. **Remove the `ignored_columns` line** from your model (deploy this last).

### Renaming Columns

Similar to removing columns, use a multi-step process for production:

1. Add the new column
2. Write to both columns
3. Backfill data from old to new column
4. Read from new column
5. Stop writing to old column
6. Remove old column

For small tables or development, you can use:

```ruby
rename_column :users, :old_name, :new_name
```

## PostgreSQL-Specific Features

### JSONB Columns

PostgreSQL's JSONB type is great for flexible, semi-structured data:

```ruby
class AddMetadataToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :metadata, :jsonb, default: {}, null: false
    add_index :products, :metadata, using: :gin
  end
end
```

Query JSONB data:

```ruby
# Find products with a specific metadata value
Product.where("metadata->>'brand' = ?", "Acme")

# Find products where metadata contains a key
Product.where("metadata ? :key", key: "featured")

# Use in models
class Product < ApplicationRecord
  store_accessor :metadata, :brand, :featured
end

product.brand = "Acme"
product.save
```

### Full-Text Search

Use PostgreSQL's built-in full-text search:

```ruby
class AddSearchToArticles < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      ALTER TABLE articles
      ADD COLUMN searchable tsvector
      GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(body, '')), 'B')
      ) STORED;
    SQL

    add_index :articles, :searchable, using: :gin
  end

  def down
    remove_index :articles, :searchable
    remove_column :articles, :searchable
  end
end
```

Query with full-text search:

```ruby
Article.where("searchable @@ plainto_tsquery('english', ?)", query)
```

### Array Columns

Store arrays directly in PostgreSQL:

```ruby
class AddTagsToArticles < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :tags, :string, array: true, default: []
    add_index :articles, :tags, using: :gin
  end
end
```

Query arrays:

```ruby
# Articles with any of these tags
Article.where("tags && ARRAY[?]::varchar[]", ["ruby", "rails"])

# Articles with all of these tags
Article.where("tags @> ARRAY[?]::varchar[]", ["ruby", "rails"])
```

### UUID Primary Keys

If you prefer UUIDs over integer IDs:

```ruby
class EnableUuidExtension < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end

class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true
      t.timestamps
    end
  end
end
```

## Query Optimization

### Use `includes` to Avoid N+1 Queries

```ruby
# Bad: N+1 query
users = User.all
users.each { |user| puts user.posts.count }

# Good: Eager load
users = User.includes(:posts)
users.each { |user| puts user.posts.size }
```

### Use `select` to Limit Columns

```ruby
# Only fetch needed columns
User.select(:id, :email).where(active: true)
```

### Use `find_each` for Large Datasets

```ruby
# Bad: Loads all records into memory
User.all.each { |user| user.do_something }

# Good: Batch processing
User.find_each(batch_size: 1000) { |user| user.do_something }
```

### Explain Queries

Use `EXPLAIN ANALYZE` to understand query performance:

```ruby
# In Rails console
User.where(email: "test@example.com").explain

# Or raw SQL
ActiveRecord::Base.connection.execute("EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com'")
```

## Database Maintenance

### Vacuuming

PostgreSQL uses MVCC (Multi-Version Concurrency Control), which can lead to table bloat. Regular vacuuming helps:

```sql
-- Manual vacuum (rarely needed, autovacuum usually handles this)
VACUUM ANALYZE;

-- Check for bloated tables
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Monitoring Indexes

Check for unused indexes:

```sql
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0 AND indexname NOT LIKE '%_pkey'
ORDER BY pg_relation_size(indexrelid) DESC;
```

## Connection Pooling

Configure the connection pool in `config/database.yml`:

```yaml
production:
  pool: <%= ENV.fetch("RAILS_MAX_THREADS", 5) %>
  # For background job workers, you may need a larger pool
```

For Good Job async mode, the default pool size is usually sufficient. If you switch to external execution mode with dedicated workers, adjust the pool size accordingly.

## Backup and Recovery

### Development Backups

```bash
# Backup
pg_dump -U mindful mindful_development > backup.sql

# Restore
psql -U mindful mindful_development < backup.sql
```

### Production Backups

Use automated backup solutions like:
- AWS RDS automated backups
- Heroku Postgres continuous protection
- pgBackRest for self-hosted setups

## References

- [PostgreSQL Documentation](https://www.postgresql.org/docs/18/)
- [Rails Guides: Active Record Migrations](https://guides.rubyonrails.org/active_record_migrations.html)
- [PostgreSQL Performance Optimization](https://wiki.postgresql.org/wiki/Performance_Optimization)