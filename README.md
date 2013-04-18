Formless
========

Formless provides a means to populate forms without the need for anything other than plain-old HTML. It removes the need for form population logic within your views which form builders are usually used for.

Formless can be used with other existing libraries and frameworks. It's also caters for applications with 

In Action
---------

Take some HTML...

    <!DOCTYPE html>
    <html>
      <body>
        <h1>Edit Person</h1>
        <form id="edit_form" method="POST" action="./">
          <input type="text" name="full_name" />
          <input type="number" min="0" name="age" />
          <label><input type="radio" name="gender" value="m"> Male</label>
          <label><input type="radio" name="gender" value="f"> Female</label>
          <select name="region">
            <option>America</option>
            <option>Europe</option>
            <option>Oceania</option>
          </select>
          <input type="submit" value="Submit" />
        </form>
      </body>
    </html>

And populate it...

    selector = '#edit_form'
    values = {name: 'Jeffrey', age: 29, gender: 'm', region: 'Europe'}
    FormPopulator.new(html, selector).populate!(values).to_s #=> <!DOCTYPE html><html> ... </html>

How It Works
------------
Nokogiri is used to parse the given HTML into a data structure that can be easily and reliably operated on. The keys in the provided hash are mapped to the `name` attribute of HTML elements. A collection of _field setters_, defaulting to `Formless::FieldSetters` are responsible for correctly setting the various field types, whilst _formatters_, defaulting to `Formless::Formatters` provide an opportunity to process the value before setting it, such as formatting dates.

Performance
-----------
Convenience is prioritised over performance; there are many better. With that said, there are ways to optimise your use of Formless. The most obvious optimisation is to re-use your Formless instances:

    @form ||= Formless.new('...')
    @form.populate({name: 'Bill', age: 31}).to_s #=> <!DOCTYPE html><html> ... </html>

Formless also provides two complementary `populate` methods. `populate!` modifies the nodeset associated with the Formless instance, whilst `populate` works on a copy of that nodeset. Where performance is important, `populate!` should be used. It's important to note however that you must explicitly set a field to a value for that field to be reset:

    @form ||= Formless.new('...')
    @form.populate!({name: 'Bill', age: 31})
    @form.populate!({name: 'John'}) #=> Age is still set to 31
    @form.populate!({name: 'John', age: nil}) #=> Age is now set to empty


Support
-------

* All HTML5 input fields including checkboxes and radio buttons.
* Textarea fields
* Select fields, including multi-select fields
* Common-name fields such as for use with the common array idiom, e.g. name="favourites[]"