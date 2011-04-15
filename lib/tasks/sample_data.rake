require 'faker'

namespace :db do
 
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    admin = User.create!(:name => "Christopher Grasso",
                 :email => "csgrasso@gmail.com",
                 :password => "foobar",
                 :password_confirmation => "foobar")
    admin.toggle!(:admin)             
    99.times do |n|
      name = Faker::Name.name
      email = "example-#{n}@gmail.com"
      password = "password"
      User.create!(:name => name,
                   :email => email,
                   :password => password,
                   :password_confirmation => password)
    end
  end
end
                 