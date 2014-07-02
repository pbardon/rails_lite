require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @params = Params.new(req, route_params)
    @req = req
    @res = res
    @already_built_response = false
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    @res["Content-Type"] = type
    @res.body = content
    session.store_session(@res)
    raise "Can't Render Twice" if already_built_response?
    @already_built_response = true
  end

  # helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    @res.status = 302
    @res.body = "<HTML><A HREF=\"#{url.to_s}\">#{url.to_s}</A>.</HTML>\n"
    @res.header['location'] = url.to_s
    session.store_session(@res)
    raise "Can't Render Twice" if already_built_response?
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    f = File.open("views/#{self.class.to_s.underscore}/#{template_name}.html.erb", 'r') do |f|
      file = f.read
      erb = ERB.new(file)
      result = erb.result(binding)
      render_content(result, "text/html")
    end
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    unless @already_built_response
      render name.to_sym
    end
  end
end
