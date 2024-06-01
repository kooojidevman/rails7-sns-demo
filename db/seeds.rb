if Rails.env == 'development'
  (1..3).each do |i|
    User.create!(
      name: "ユーザー#{i}",
      email: "user_#{i}@emxample.com",
      password: 'Test1234',
      password_confirmation: 'Test1234'
    )
  end
  puts 'Created Users'
end
