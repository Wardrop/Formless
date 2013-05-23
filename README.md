Formless
========

Formless provides a means to populate forms without the need for anything other than plain-old HTML. It removes the requirement for form population logic within your views, serving as a complete replacement for form builders.

Formless can be used with any existing libraries or frameworks. Its only dependancy is Nokogiri.


In Action
---------
Install it...

```console
$ gem install formless
```

Take some HTML...

```html
<!DOCTYPE html>
<html>
  <body>
    <h1>Edit Person</h1>
    <form id="edit_form" method="POST" action="./">
      <input type="text" name="full_name" />
      <input type="number" min="0" name="age" />
      <input type="radio" name="gender" value="m" id="gender_m"> <label for="gender_m">Male</label>
      <input type="radio" name="gender" value="f" id="gender_f"> <label for="gender_f">Female</label>
      <select name="region">
        <option>America</option>
        <option>Europe</option>
        <option>Oceania</option>
      </select>
      <input type="submit" value="Submit" />
    </form>
  </body>
</html>
```

And populate it...

```ruby
selector = '#edit_form'
values = {name: 'Jeffrey', age: 29, gender: 'm', region: 'Europe'}
FormPopulator.new('<html>...</html>', selector).populate!(values).to_s #=> <!DOCTYPE html><html> ... </html>
```


How It Works
------------
Nokogiri is used to parse the given HTML into a data structure that can be easily and reliably operated on. The keys in the provided hash are mapped to the `name` attribute of HTML elements. A collection of _field setters_, defaulting to `Formless::FieldSetters` are responsible for correctly setting the various field types, whilst _formatters_, defaulting to `Formless::Formatters` provide an opportunity to process the value before setting it, such as formatting dates.


Performance
-----------
Convenience is prioritised over performance; there are many less convenient but better performing solutions if that's your priority. With that said, there are ways to optimise your use of Formless. The most obvious optimisation is to re-use your Formless or Nokogiri NodeSet instances, to save re-parsing your HTML:

```ruby
@form ||= Formless.new('...')
@form.populate({name: 'Bill', age: 31}).to_s #=> <!DOCTYPE html><html> ... </html>
```

Formless also provides two complementary `populate` methods. `populate!` modifies the nodeset associated with the Formless instance, whilst `populate` works on a copy of that nodeset. Where performance is important, `populate!` should be used. It's important to note however that you must explicitly set a field to a value for that field to be reset, so extra care must be taken:

```ruby
@form ||= Formless.new('...')
@form.populate!({name: 'Bill', age: 31})
@form.populate!({name: 'John'}) #=> Age is still set to 31
@form.populate!({name: 'John', age: nil}) #=> Age is now set to empty
```


Comprehensive
-------------
Formless is intended to provide comprehensive support for HTML5 forms. Any contradiction to this is considered a bug. To summarise:

* All HTML5 input fields, including:
    * Checkboxes
    * Radio buttons
    * Password's which are not populated by default
    * Date and time fields: date, datetime, datetime-local, week, month
* Textarea fields
* Select fields, including multi-select fields
* Common-name fields, such as for use with the array idiom, e.g. name="favourites[]"
