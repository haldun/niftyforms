class FormField
  include Mongoid::Document

  field :label
  field :required, type: Boolean, default: false

  embedded_in :form

  def serializable_hash(options = nil)
    hash = super options
    hash['type'] = _type
    hash
  end
end
