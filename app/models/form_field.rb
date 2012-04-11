class FormField
  include Mongoid::Document

  field :label
  field :required, type: Boolean, default: false

  embedded_in :form
end
