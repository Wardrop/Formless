require_relative './helper.rb'

describe Formless do
  it "can take a html string" do
    form = Formless.new(html)
    form.nodeset.should be_a(Nokogiri::XML::NodeSet)
    form.nodeset.to_s.strip.should == html.strip
  end
  
  it "can take a nokogiri node" do
    doc = Nokogiri.parse(html)
    form = Formless.new(doc)
    form.nodeset.should be_a(Nokogiri::XML::NodeSet)
    form.nodeset.document.should == doc
    form.nodeset[0].should == doc
  end
  
  it "can take a nokogiri nodeset" do
    nodeset = Nokogiri.parse(html).css('> *')
    form = Formless.new(nodeset)
    form.nodeset.should == nodeset
  end
  
  let(:form) do
    Formless.new(html)
  end
  
  describe "field populating" do    
    example "default/unknown" do
      form.populate(unknown: 'yay').css('[name=unknown]')[0]['value'].should == 'yay'
    end
    
    example "text" do
      form.populate(full_name: 'William Fisher').css('[name=full_name]')[0]['value'].should == 'William Fisher'
    end
    
    example "textarea" do
      form.populate(hobbies: 'fishing, camping').css('[name=hobbies]')[0].content.should == 'fishing, camping'
    end
    
    example "radio" do
      form.populate(gender: 'f').css('[name=gender][value=f]')[0].has_attribute?('checked').should == true
    end
    
    example "checkbox" do
      form.populate(subscribe: 'yes').css('[name=subscribe]')[0].has_attribute?('checked').should == true
    end
    
    example "select" do
      form.populate(region: 'Europe').
        css('[name=region] > option').find { |n| n.has_attribute?('selected') }.text.should == 'Europe'
      form.populate(region: 'Australia').
        css('[name=region] > option').find { |n| n.has_attribute?('selected') }.text.should == 'Oceania'
      # Will add non-existant values
      form.populate(region: 'Middle East').
        css('[name=region] > option').find { |n| n.has_attribute?('selected') }.text.should == 'Middle East'
    end
    
    example "multi-select" do
      # Also tests order independance
      form.populate('foods[]' => ['Chips', 'Pizza']).css('[name="foods[]"] > option').select { |n|
        n.has_attribute?('selected')
      }.map { |v| v.text }.should == ['Pizza', 'Chips']
      
      # Will automatically append square brackets if not found.
      form.populate('foods' => ['Pizza', 'Chips']).css('[name="foods[]"] > option').select { |n|
        n.has_attribute?('selected')
      }.map { |v| v.text }.should == ['Pizza', 'Chips']
    end
    
    example "date" do
      date = Date.today
      form.populate(birthday: date).css('[name=birthday]')[0]['value'].should == date.strftime('%F')
    end
    
    example "datetime" do
      time = DateTime.now
      form.populate(breakfast: time).css('[name=breakfast]')[0]['value'].should == time.strftime('%FT%T%z')
    end
    
    example "datetime-local" do
      time = DateTime.now
      form.populate(dinner: time).css('[name=dinner]')[0]['value'].should == time.strftime('%FT%T')
    end
    
    example "month" do
      time = DateTime.new(2013, 9, 2, 11, 30, 15)
      form.populate(favourite_month: time).css('[name=favourite_month]')[0]['value'].should == '2013-09'
    end
    
    example "week" do
      time = DateTime.new(2013, 9, 2, 11, 30, 15)
      form.populate(favourite_week: time).css('[name=favourite_week]')[0]['value'].should == '2013-W36'
    end
    
    example "array-like field names" do
      form.populate('colours[]' => %w{blue red}).css('[name="colours[]"][checked=checked]').map { |n| n['value'] }.should == ['red', 'blue']
    end
  end
  
  it "outputs a Nokogiri nodeset" do
    form.populate({}).should be_a(Nokogiri::XML::NodeSet)
  end
  
  it "can modify the original nodeset, or a copy" do
    form.populate!({full_name: 'Bob Bobinski'}).css('[name=full_name]')[0]['value'].should == 'Bob Bobinski'
    form.populate({full_name: 'Harold Haroldo'}).css('[name=full_name]')[0]['value'].should == 'Harold Haroldo'
    form.populate!({}).css('[name=full_name]')[0]['value'].should == 'Bob Bobinski'
  end
  
  it "can take a CSS selector to narrow the nodeset" do
    form.populate!({full_name: 'Tony Jones', hobbies: 'stuff'}, 'input')
    form.nodeset.css('[name=full_name]')[0]['value'].should == 'Tony Jones'
    form.nodeset.css('[name=hobbies]')[0].content.should_not == 'stuff'
  end
  
  describe "configuration" do
    it "can toggle whether password fields are populated" do
      form.populate(password: 'ilovemonkeys').css('[name=password]')[0]['value'].should == nil
      form.options[:populate_passwords] = true
      form.populate(password: 'ilovemonkeys').css('[name=password]')[0]['value'].should == 'ilovemonkeys'
    end
    
    it "allows field setters to be overridden" do
      form.options[:field_setters] = Formless::FieldSetters.merge(password: proc { |node| node['value'] = 'meow' })
      form.populate(password: 'ilovemonkeys').css('[name=password]')[0]['value'].should == 'meow'
    end
    
    it "allows formatters to be overridden" do
      form.options[:formatters] = Formless::Formatters.merge('yes' => proc { |n,v| v == 'yes' ? 1 : 0 })
      form.populate({full_name: 'yes'}).css('[name=full_name]')[0]['value'].should == '1'
    end
  end
  
end