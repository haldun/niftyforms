class FormField
  include Mongoid::Document

  attr_accessible :label, :required, :helpText, :_type
  attr_accessible :choices

  field :label
  field :required, type: Boolean, default: false
  field :help_text

  embedded_in :form

  def serializable_hash(options = nil)
    hash = super options
    hash['type'] = _type
    hash
  end

  def answer_type
    _type.gsub("Field", "Answer").constantize
  end
end
