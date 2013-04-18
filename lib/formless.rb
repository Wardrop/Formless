require 'date'
require 'nokogiri'

class Formless
  
  DATE_FORMAT = '%d/%m/%Y'
  DATETIME_FORMAT = '%d/%m/%Y %l:%M%P'
  
  FieldSetters = {
    textarea: proc { |node, values|
      node.content = values.shift
    },
    radio: proc { |node, values|
      node.delete('checked')
      node['checked'] = 'checked' if values.include? node['value']
    },
    checkbox: proc { |node, values|
      node.delete('checked')
      node['checked'] = 'checked' if values.include? node['value']
    },
    select: proc { |node, values|
      matches = node.css('option').to_a.each { |n| n.delete('selected') }.find_all do |n|
        n.has_attribute?('value') ? values.include?(n['value']) : values.include?(n.content)
      end
      if !matches.empty?
        if node.has_attribute? 'multiple'
          matches.each { |n| n['selected'] = 'selected' }
        else
          matches.first['selected'] = 'selected'
        end
      elsif !node.has_attribute?('multiple') && value = values.compact.first
        node << node.document.create_element('option', value, selected: 'selected')
      end
    },
    password: proc { |node, values|
      node['value'] = values.shift if options[:populate_passwords]
    },
    default: proc { |node, values|
      node['value'] = values.shift
    }
  }
  
  Formatters = {
    [Date, Time] => proc { |node, value|
      case node['type']
      when 'date'
        value.strftime('%F')
      when 'datetime'
        value.strftime('%FT%T%z')
      when 'datetime-local'
        value.strftime('%FT%T')
      when 'week'
        value.strftime('%G-W%V')
      when 'month'
        value.strftime('%G-%m')
      else
        (value.respond_to? :hour) ? value.strftime(DATETIME_FORMAT) : value.strftime(DATE_FORMAT)
      end
    },
    nil => proc { '' }
  }
  
  attr_accessor :selector
  attr_reader :options
  attr_reader :nodeset
  
  def nodeset=(html)
    @nodeset = case html
    when Nokogiri::XML::Node
      Nokogiri::XML::NodeSet.new(html, [html])
    when Nokogiri::XML::NodeSet
      html
    else
      doc = Nokogiri.parse(html)
      Nokogiri::XML::NodeSet.new(doc, [doc])
    end
  end
  
  def initialize(html, selector = nil, **options)
    self.nodeset = html
    self.selector = selector
    @options = {
      field_setters: FieldSetters,
      formatters: Formatters,
      populate_passwords: false
    }.merge!(options)
  end
  
  def field_setters
    self.options[:field_setters]
  end
  
  def formatters
    self.options[:formatters]
  end
  
  def populate(values, selector = nil, nodeset = self.nodeset)
    populate!(values, selector, Nokogiri::XML::NodeSet.new(nodeset.document, nodeset.to_a.map! { |n| n.dup }))
  end
  
  def populate!(values, selector = nil, nodeset = self.nodeset)
    nodeset = selector ? nodeset.css(selector) : nodeset
    values.each do |field, value|
      nodes = nodeset.css(%{[name="#{field}"]})
      nodes = nodeset.css(%{[name="#{field}[]"]}) if nodes.empty?
      nodes.each { |n| set_field(n, value) }
    end
    nodeset
  end

private

  def set_field(node, value)
    setter = field_setters[(node['type'] || node.name).to_sym] || FieldSetters[:default]
    instance_exec(node, [*format_value(node, value)], &setter)
  end
  
  def format_value(node, value)
    condition, formatter = formatters.find do |conditions, block|
      [*conditions].find { |c| c === value }
    end
    formatter ? instance_exec(node, value, &formatter) : value
  end

end