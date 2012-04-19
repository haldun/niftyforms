class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :answers
  belongs_to :form

  def answer_for_field(field)
    answers.detect { |answer| answer.form_field_id == field.id }
  end
end
