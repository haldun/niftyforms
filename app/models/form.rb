class Form
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_id, type: Integer
  field :title
  field :description
  field :badge_background_color

  embeds_many :form_fields
  has_many :posts

  attr_accessible :title, :description, :form_fields
  accepts_nested_attributes_for :form_fields

  before_create :select_badge_background_color

  def as_json options={}
    attrs = super options
    attrs['fields'] = attrs['form_fields']
    attrs.delete 'form_fields'
    attrs['is_new_record'] = new_record?
    attrs
  end

  private

  def select_badge_background_color
    colors = %w{#243567 #3F911D #9D5B22 #44A7D6}
    self.badge_background_color = colors.sample
  end
end
