class @Editor
  TABS =
    ADD_FIELD: 0
    FIELD_SETTINGS: 1
    FORM_SETTINGS: 2

  constructor: (formData) ->
    @catalog = FieldCatalog
    @form = new Form(formData)
    @selectedTab = ko.observable TABS.ADD_FIELD
    @selectedField = ko.observable null
    @selectedCatalogItem = ko.observable @catalog.items[0]
    @toJSON = ko.computed => ko.toJSON @form
    @saveURL = "/forms"

  addFieldWithCatalogItem: (catalogItem) =>
    field = new catalogItem.klass catalogItem.initialValues
    @form.fields.push field
    @showFieldSettings field

  showFormSettings: ->
    @selectedField undefined
    @selectedTab TABS.FORM_SETTINGS

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
    $.ajax
      type: 'POST'
      url: @saveURL
      data: @toJSON()
      success: ->
        alert "hey!"
      accepts: 'application/json'
      contentType: 'application/json'


class Form
  constructor: (formData) ->
    @title = ko.observable formData.title ? "Untitled form"
    @description = ko.observable formData.description ? ""
    @fields = ko.observableArray _.map formData.fields ? [], (field) ->
      fieldClass = FieldCatalog.fieldClassFromString field.type
      new fieldClass(field)

  toJSON: ->
    copy = ko.toJS this
    copy.form_fields = copy.fields
    delete copy.fields
    copy


class Field
  constructor: (fieldData) ->
    @label = ko.observable fieldData?.label ? "Untitled"
    @required = ko.observable fieldData?.required ? false
    @type = ko.computed => @constructor.name

  settingsTemplate: =>
    "#{@constructor.name}SettingsTemplate"

  previewTemplate: =>
    "#{@constructor.name}PreviewTemplate"

  toJSON: ->
    copy = ko.toJS this
    copy._type = copy.type
    delete copy.type
    copy


class TextField extends Field
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


class NumberField extends Field


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


class RadioField extends ChoiceableField


class SelectField extends ChoiceableField


class ShortNameField extends Field


class PhoneField extends Field


class FileField extends Field


class AddressField extends Field


class DateField extends Field


class EmailField extends Field


class TimeField extends Field


class URLField extends Field


class MoneyField extends Field


class LikertField extends Field


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

$ ->
  window.editor = new Editor window.initialFormData
  ko.applyBindings(editor);
