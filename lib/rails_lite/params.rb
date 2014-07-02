require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = {}
    @params.merge!(route_params)
    @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
    @permitted_keys = []
    print req.body
    @params.merge!(parse_www_encoded_form(req.body)) if req.body

    @params

  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    keys.each do |key|
      @permitted_keys << key
    end
  end

  def require(key)
    if !@params.include?(key)
      raise AttributeNotFoundError
    end
  end

  def permitted?(key)
    @permitted_keys.include?(key)
  end

  def to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    decoded = URI.decode_www_form(www_encoded_form)
    output_hash = {}
    decoded.each do |param|
      keys = parse_key(param.first)
      current_hash = output_hash

      keys[0...-1].each do |key|
        if !current_hash.has_key?(key)
          current_hash[key] = {}
          current_hash = current_hash[key]
        else
          current_hash = current_hash[key]
        end

      end

      current_hash[keys[-1]] = param.last
    end

    output_hash

  end



  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
