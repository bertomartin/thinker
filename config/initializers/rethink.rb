RDB_CONFIG = {
  :host => ENV['RDB_HOST'] || 'localhost',
  :port => ENV['RDB_PORT'] || 28015,
  :db   => ENV['RDB_DB']   || 'thinker',
  :r    => RethinkDB::RQL.new
}

r = RDB_CONFIG[:r]

begin
  conn = r.connect(:host => RDB_CONFIG[:host], :port => RDB_CONFIG[:port])
  Rails.logger.info "\nSetting up RethinkDB for the #{Rails.env} environment."
rescue Exception => err
  puts "Cannot connect to RethinkDB database #{RDB_CONFIG[:host]}:#{RDB_CONFIG[:port]} (#{err.message})"
  Process.exit(1)
end

begin
  r.db_create(RDB_CONFIG[:db]).run(conn)
  Rails.logger.info "Created `thinker` database."
rescue RethinkDB::RqlRuntimeError => err
  Rails.logger.info "Database `thinker` already exists."
end

db = r.db(RDB_CONFIG[:db])

begin
  r.db(RDB_CONFIG[:db]).table_create('users').run(conn)
  Rails.logger.info "Created `users` table."

  if Rails.env = "development"

    pws = [{},{},{}]
    pws[0][:salt] = BCrypt::Engine.generate_salt
    pws[0][:fish] = BCrypt::Engine.hash_secret("x", pws[0][:salt])
    pws[1][:salt] = BCrypt::Engine.generate_salt
    pws[1][:fish] = BCrypt::Engine.hash_secret("y", pws[0][:salt])
    pws[2][:salt] = BCrypt::Engine.generate_salt
    pws[2][:fish] = BCrypt::Engine.hash_secret("z", pws[0][:salt])

    users = db.table('users').insert([
      {
        email: "chas@munat.com",
        salt: pws[0][:salt],
        fish: pws[0][:fish],
        created_at: r.now,
        updated_at: r.now
      },
      {
        email: "joe@munat.com",
        salt: pws[1][:salt],
        fish: pws[1][:fish],
        created_at: r.now,
        updated_at: r.now
      },
      {
        email: "sam@munat.com",
        salt: pws[2][:salt],
        fish: pws[2][:fish],
        created_at: r.now,
        updated_at: r.now
      }
    ]).run(conn)

    user_ids = users['generated_keys']

    Rails.logger.info "Added users: #{user_ids}"
  end
rescue RethinkDB::RqlRuntimeError => err
  Rails.logger.info "Table `users` already exists."
end

begin
  r.db(RDB_CONFIG[:db]).table_create('articles').run(conn)
  Rails.logger.info "Created `articles` table."

  if Rails.env = "development"
    articles = db.table('articles').insert([
      {
        user_id: user_ids.sample,
        title: "Sed porttitor lectus nibh",
        body: %{
          Sed porttitor lectus nibh. Vestibulum ac diam sit amet quam vehicula
          elementum sed sit amet dui. Curabitur **aliquet quam** id dui posuere
          blandit. Sed porttitor lectus nibh. Donec sollicitudin molestie
          malesuada.

          Praesent sapien massa, convallis a pellentesque nec, egestas non nisi.
          Curabitur aliquet _quam id dui posuere blandit_. Lorem ipsum dolor sit
          amet, consectetur adipiscing elit. Proin eget tortor risus. Pellentesque
          in ipsum id orci porta dapibus.
        },
        created_at: r.now,
        updated_at: r.now
      },
      {
        user_id: user_ids.sample,
        title: "Vivamus suscipit tortor",
        body: %{
          Vivamus suscipit tortor eget felis porttitor volutpat. Vestibulum ante
          ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae;
          Donec velit neque, auctor sit amet aliquam vel, ullamcorper sit amet
          ligula. Mauris blandit aliquet elit, eget tincidunt nibh pulvinar a.
          Vivamus suscipit tortor eget felis porttitor volutpat.

          Proin eget tortor risus. Cras ultricies ligula sed magna dictum porta.
          Donec sollicitudin molestie malesuada. Vestibulum ante ipsum primis in
          faucibus orci luctus et ultrices posuere cubilia Curae; Donec velit
          neque, *auctor sit amet aliquam vel*, ullamcorper sit amet ligula.

          Pellentesque in ipsum id orci porta dapibus. Nulla porttitor accumsan
          tincidunt. Proin eget tortor risus. Donec sollicitudin molestie
          **malesuada**.
        },
        created_at: r.now,
        updated_at: r.now
      },
      {
        user_id: user_ids.sample,
        title: "Quisque velit nisi",
        body: %{
          Quisque velit nisi, **pretium ut lacinia in**, elementum id enim. Sed
          porttitor lectus nibh. Praesent sapien massa, convallis a pellentesque
          nec, egestas non nisi. Nulla quis lorem ut libero malesuada feugiat.
          Nulla quis lorem ut libero *malesuada feugiat*. Vestibulum ac diam sit
          amet quam vehicula elementum sed sit amet dui.

          Nulla porttitor accumsan tincidunt. Vivamus magna justo, lacinia eget
          consectetur sed, convallis at tellus. Proin eget tortor risus. Donec
          sollicitudin molestie malesuada. Vestibulum ac diam sit amet quam
          vehicula elementum sed sit amet dui. Lorem ipsum dolor sit amet,
          consectetur adipiscing elit.
        },
        created_at: r.now,
        updated_at: r.now
      }
    ]).run(conn)

    article_ids = articles['generated_keys']

    Rails.logger.info "Added articles: #{article_ids}"
  end
rescue RethinkDB::RqlRuntimeError => err
  Rails.logger.info "Table `articles` already exists."
end

begin
  r.db(RDB_CONFIG[:db]).table_create('replies').run(conn)
  Rails.logger.info "Created `replies` table."

  if Rails.env = "development"
    replies = db.table('replies').insert([
      {
        user_id: user_ids.sample,
        article_id: article_ids.sample,
        body: %{
          Praesent sapien massa, convallis a pellentesque nec, egestas non nisi.
          Curabitur aliquet _quam id dui posuere blandit_. Lorem ipsum dolor sit
          amet, consectetur adipiscing elit. Proin eget tortor risus. Pellentesque
          in ipsum id orci porta dapibus.
        },
        created_at: r.now,
        updated_at: r.now
      },
      {
        user_id: user_ids.sample,
        article_id: article_ids.sample,
        body: %{
          Pellentesque in ipsum id orci porta dapibus. Nulla porttitor accumsan
          tincidunt. Proin eget tortor risus. Donec sollicitudin molestie
          **malesuada**.
        },
        created_at: r.now,
        updated_at: r.now
      },
      {
        user_id: user_ids.sample,
        article_id: article_ids.sample,
        body: %{
          Nulla porttitor accumsan tincidunt. Vivamus magna justo, lacinia eget
          consectetur sed, convallis at tellus. Proin eget tortor risus. Donec
          sollicitudin molestie malesuada. Vestibulum ac diam sit amet quam
          vehicula elementum sed sit amet dui. Lorem ipsum dolor sit amet,
          consectetur adipiscing elit.
        },
        created_at: r.now,
        updated_at: r.now
      }
    ]).run(conn)

    reply_ids = replies['generated_keys']

    Rails.logger.info "Added replies: #{reply_ids}"
  end
rescue RethinkDB::RqlRuntimeError => err
  Rails.logger.info "Table `replies` already exists."
end

conn.close if conn
