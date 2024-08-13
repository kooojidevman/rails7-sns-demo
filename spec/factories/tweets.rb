# == Schema Information
#
# Table name: tweets
#
#  id         :bigint           not null, primary key
#  body       :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
FactoryBot.define do
  factory :tweet do
    body { "MyText" }
    user_id { 1 }
  end
end
