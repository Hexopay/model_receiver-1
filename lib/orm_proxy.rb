require 'orm_proxy/active_record'
require 'active_support/core_ext/string/inflections'

class ORMProxy

  def self.build(model_name, attributes)
    ORMProxy::ActiveRecord.new(model_name, attributes)
  end

  attr_reader :model_name, :attributes, :habtms, :model_klass
  def initialize(model_name, attributes)
    @model_name  = model_name
    @model_klass = prepare_model_class_name(attributes)
    @attributes  = prepare_attributes(attributes)
    @habtms      = prepare_habtms(attributes)
  end

  def update_db
    record = model_klass.find_by_id(attributes['id'])
    if record
      record.with_lock do
        unless skip_update?(record)
          attributes.delete('id')
          update_record(record, attributes)
        end
      end
    else
      create_record(model_klass, attributes)
    end

    update_habtm_values(record) if habtms
  end

  def destroy
    primary_key = model_klass.primary_key
    search_attributes = attributes

    if primary_key && attributes[primary_key]
      search_attributes = {primary_key => attributes[primary_key]}
    end

    record = model_klass.where(search_attributes).first
    record.destroy! if record
  end

  protected

  def prepare_attributes(attrs)
    if model_klass.respond_to?(:column_names)
      columns = model_klass.column_names
      attrs.select { |k,v| columns.include?(k) }
    else
      attrs
    end
  end

  def prepare_habtms(attrs)
    attrs['_adds']['habtms'] if attrs['_adds']
  end

  def prepare_model_class_name(attrs)
    klass = attrs.delete('_model_name') || model_name
    klass.classify.constantize
  end

  private

  def skip_update?(record)
    record.respond_to?(:updated_at) && attributes.has_key?('updated_at') && record.updated_at > Time.parse(attributes['updated_at'])
  end

  def model_key
    model_name.singularize.foreign_key
  end

  def habtm_key(habtm)
    habtm.singularize.foreign_key
  end

  def update_habtm_values(record)
    record ||= model_klass.find_by_id(attributes['id'])

    habtms.each do |habtm, values|
      habtm_model = [model_name, habtm].sort.join("_")
      habtm_class = habtm_model.singularize.classify.constantize

      habtm_class.where(["#{model_key} = ?", record.id]).delete_all
      habtm_key = habtm_key(habtm)

      values.each do |value|
        create_record(habtm_class, {model_key => record.id, habtm_key => value})
      end
    end
  end

end
