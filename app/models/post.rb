class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :answers
  belongs_to :form
end

