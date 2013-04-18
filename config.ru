require './lib/formless'

run proc { |env|
  request = Rack::Request.new(env)
  html = open('./spec/form.html').read
  form = Formless.new(html)
  [200, {}, [form.populate(request.POST).to_s]]
}