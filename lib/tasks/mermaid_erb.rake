%w(db:migrate db:schema:load).each do |task|
  Rake::Task[task].enhance do
    Rake::Task['mermaid_erd'].invoke if Rails.env.development?
  end
end