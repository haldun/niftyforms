class Answer
  include Mongoid::Document

  embedded_in :post
  belongs_to :form_field
end
