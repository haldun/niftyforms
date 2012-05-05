return unless $(document.body).hasClass('forms')

$ ->
  window.editor = new Editor window.initialFormData
  ko.applyBindings(editor)

class @Editor
  TABS =
    ADD_FIELD       : 0
    FIELD_SETTINGS  : 1
    FORM_SETTINGS   : 2

  STATE =
    IDLE    : 0
    SAVING  : 1
    SAVED   : 2
    ERROR   : 3

  constructor: (formData) ->
    @catalog = FieldCatalog
    @form = new Form(formData)
    @selectedTab = ko.observable TABS.ADD_FIELD
    @selectedField = ko.observable null
    @selectedCatalogItem = ko.observable @catalog.items[0]
    @toJSON = ko.computed => ko.toJSON @form
    @saveURL = "/forms"
    @currentState = STATE.IDLE

  addFieldWithCatalogItem: (catalogItem) =>
    field = new catalogItem.klass catalogItem.initialValues
    @form.fields.push field
    @showFieldSettings field

  showFormSettings: ->
    @selectedField undefined
    @selectedTab TABS.FORM_SETTINGS

  isFormSettingsActive: ->
    TABS.FORM_SETTINGS is @selectedTab()

  showFieldSettings: (field) =>
    @selectedField field
    @selectedTab TABS.FIELD_SETTINGS

  removeField: (field) =>
    if field is @selectedField()
      @selectedField undefined
    @form.fields.remove field

  duplicateField: (field) =>
    newField = new field.constructor ko.toJS(field)
    index = _.indexOf @form.fields(), field
    @form.fields.splice index, 0, newField
    @selectedField newField

  save: =>
    return if @saving()

    data = @toJSON()

    if @form.is_new_record
      url = "/forms"
    else
      url = "/forms/#{@form.id}"
      data._method = "PUT"

    $.ajax
      type: 'POST'
      url: url
      data: data
      contentType:"application/json; charset=utf-8"
      success: (response) =>
        console.log response
        @form = new Form(response)
        @currentState = STATE.SAVED
      dataType: 'json'

    @currentState = STATE.SAVING

  saving: ->
    @currentState is STATE.SAVING


class Form
  constructor: (formData) ->
    @id = formData.id ? formData._id
    @is_new_record = formData.is_new_record
    @title = ko.observable formData.title ? "Untitled form"
    @description = ko.observable formData.description ? ""
    @fields = ko.observableArray _.map formData.fields ? [], (field) ->
      fieldClass = FieldCatalog.fieldClassFromString field.type
      new fieldClass(field)

  toJSON: ->
    copy = ko.toJS this
    copy.form_fields = copy.fields
    delete copy.fields
    delete copy.id if @is_new_record
    copy


class Field
  constructor: (fieldData) ->
    @label = ko.observable fieldData?.label ? "Untitled"
    @required = ko.observable fieldData?.required ? false
    @helpText = ko.observable fieldData?.helpText ? ""

  type: -> throw "Subclass responsibility"
  settingsTemplate: -> "#{@type()}SettingsTemplate"
  previewTemplate: -> "#{@type()}PreviewTemplate"

  toJSON: ->
    copy = ko.toJS this
    copy._type = copy.type()
    delete copy.type
    copy


class TextField extends Field
  type: -> "TextField"

  AVAILABLE_SIZES = ["small", "medium", "large"]

  constructor: (fieldData) ->
    super fieldData
    @size = ko.observable fieldData?.size ? "medium"
    @availableSizes = AVAILABLE_SIZES

  toJSON: ->
    copy = super()
    delete copy.availableSizes
    copy


class TextareaField extends Field
  type: -> "TextareaField"


class NumberField extends Field
  type: -> "NumberField"


class ChoiceableField extends Field
  constructor: (fieldData) ->
    super fieldData
    @choices = ko.observableArray _.map fieldData?.choices ? [], (choice) ->
      new Choice value: choice.value, text: choice.text
    @randomized = ko.observable fieldData?.randomized
    @hasChoices = ko.computed => @choices().length isnt 0

  addChoice: =>
    @choices.push new Choice value: @choices().length

  removeChoice: (choice) =>
    @choices.remove choice

  toJSON: ->
    copy = super()
    delete copy.hasChoices
    copy


class CheckboxField extends ChoiceableField
  type: -> "CheckboxField"


class RadioField extends ChoiceableField
  type: -> "RadioField"


class SelectField extends ChoiceableField
  type: -> "SelectField"


class ShortNameField extends Field
  type: -> "ShortNameField"


class PhoneField extends Field
  type: -> "PhoneField"


class FileField extends Field
  type: -> "FileField"


class AddressField extends Field
  type: -> "AddressField"


class DateField extends Field
  type: -> "DateField"


class EmailField extends Field
  type: -> "EmailField"


class TimeField extends Field
  type: -> "TimeField"


class URLField extends Field
  type: -> "URLField"


class MoneyField extends Field
  type: -> "MoneyField"


class LikertField extends Field
  type: -> "LikertField"


class Choice
  constructor: (choiceData) ->
    @value = ko.observable choiceData?.value ? undefined
    @text = ko.observable choiceData?.text ? ""


class CatalogItem
  constructor: (@label, @klass, @initialValues) ->
    @name = @klass.name


# Some helpers
initialChoices = ->
  [
    {value: 1, text: 'First Choice'}
    {value: 2, text: 'Second Choice'}
    {value: 3, text: 'Third Choice'}
  ]

# Catalog of available field types. This catalog also holds some meta-data
# about field types.
FieldCatalog =
  items: [
    new CatalogItem 'Single Line Text', TextField
    new CatalogItem 'Paragraph Text', TextareaField
    new CatalogItem 'Number', NumberField,
      label: 'Number'
    new CatalogItem 'Checkboxes', CheckboxField,
      label: 'Check All That Apply'
      choices: initialChoices()
    new CatalogItem 'Multiple Choice', RadioField,
      label: 'Select a Choice'
      choices: initialChoices()
    new CatalogItem 'Drop Down', SelectField,
      label: 'Select a Choice'
      choices: initialChoices()
    new CatalogItem 'Name', ShortNameField,
      label: 'Name'
    new CatalogItem 'Phone', PhoneField,
      label: 'Phone'
    new CatalogItem 'File Upload', FileField,
      label: 'File'
    new CatalogItem 'Address', AddressField,
      label: 'Address'
    new CatalogItem 'Date', DateField,
      label: 'Date'
    new CatalogItem 'Email', EmailField,
      label: 'Email'
    new CatalogItem 'Time', TimeField,
      label: 'Time'
    new CatalogItem 'Website', URLField,
      label: 'Website Address'
    new CatalogItem 'Price', MoneyField,
      label: 'Price'
    new CatalogItem 'Likert', LikertField
  ]

  findCatalogItemByName: (typeName) ->
    _.find @items, (item) -> item.name is typeName

  fieldClassFromString: (typeName) ->
    FieldCatalog.findCatalogItemByName(typeName).klass ? undefined


# Custom ko bindings
ko.bindingHandlers.tab =
  init: (element, valueAccessor) ->
    currentTab = valueAccessor()
    $(element).find('a').click ->
      currentTab $(this).parent().index()

  update: (element, valueAccessor, allBindingsAccessor, viewModel) ->
    currentTab = valueAccessor()()
    $(element).find("li:nth(#{currentTab}) a:first").trigger('click')

# ko - sortable bindings
data_key = "sortable_data"
ko.bindingHandlers.sortableList =
  init: (element, valueAccessor) ->
    $(element).mousedown ->
      $(this).data 'preSortChildren', _.toArray(this.childNodes)

    $(element).sortable
      update: (event, ui) ->
        movedDataItem = $(ui.item).data data_key
        possiblyObservableArray = valueAccessor()
        array = ko.utils.unwrapObservable possiblyObservableArray
        previousIndex = ko.utils.arrayIndexOf array, movedDataItem
        newIndex = $(element).children().index(ui.item)

        @innerHTML = ""
        $(this).append($(this).data "preSortChildren")

        array.splice previousIndex, 1
        array.splice newIndex, 0, movedDataItem

        if (typeof possiblyObservableArray.valueHasMutated) is "function"
          possiblyObservableArray.valueHasMutated()

ko.bindingHandlers.sortableItem =
  init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
    $(element).data data_key, ko.utils.unwrapObservable(valueAccessor())
