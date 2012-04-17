class Answer
  include Mongoid::Document

  embedded_in :post
end
