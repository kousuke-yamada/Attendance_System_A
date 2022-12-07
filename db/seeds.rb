# coding: utf-8

# 管理者
User.create(name: "Admin User",
            email: "admin@email.com",
            password: "password",
            password_confirmation: "password",
            employee_number: 0,
            admin: true)
# 上長A
User.create(name: "上長A",
            email: "super-1@email.com",
            password: "password",
            password_confirmation: "password",
            employee_number: 1,
            superior: true)
# 上長B            
User.create(name: "上長B",
            email: "super-2@email.com",
            password: "password",
            password_confirmation: "password",
            employee_number: 2,
            superior: true)
            
60.times do |n|
  name = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  employee_number = n+3
  User.create(name: name,
              email: email,
              password: password,
              password_confirmation: password,
              employee_number: employee_number)
end