# coding: utf-8

# 管理者
User.create(name: "Admin User",
            email: "admin@email.com",
            password: "password",
            password_confirmation: "password",
            admin: true)
# 上長A
User.create(name: "上長A",
            email: "super-1@email.com",
            password: "password",
            password_confirmation: "password",
            superior: true)
# 上長B            
User.create(name: "上長B",
            email: "super-2@email.com",
            password: "password",
            password_confirmation: "password",
            superior: true)
            
60.times do |n|
  name = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create(name: name,
              email: email,
              password: password,
              password_confirmation: password)
end