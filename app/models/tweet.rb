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
class Tweet < ApplicationRecord
  belongs_to :user
end
