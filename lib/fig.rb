require "figaro"
require "ostruct"

module Fig
  class Config
    def initialize(params_path, defaults_path, figaro_path, prefix)
      @prefix = prefix

      Figaro.application = Figaro::Application.new(path: figaro_path)
      Figaro.load

      read_params(params_path, defaults_path)
      @params.keys.each { |k| build_config(k) }
      build_base if base
    end

    # YML dump of the entire config, including defaults
    def dump(path)
      config_out = {}
      @params.each do |k, v|
        if k == "base"
          v.keys.each do |b|
            val = config_out[b] = send(b)
            next unless val && val.is_a?(Array)
            config_out[b] = val.to_s
          end
        else
          config_out[k] = send(k).to_h
          config_out[k].each do |r, s|
            next unless s && s.is_a?(Array)
            config_out[k][r] = s.to_s
          end
        end
      end
      File.open(path, "w") { |f| f.write config_out.to_yaml }
    end

    def lock
      remove_instance_variable(:@params)
      remove_instance_variable(:@prefix)
      remove_instance_variable(:@defaults)
      self.class.send(:undef_method, "extend")
      self.class.send(:undef_method, "merge")
      self.class.send(:undef_method, "update")
      self.class.send(:undef_method, "dump")
      self.class.send(:undef_method, "lock")
    end

    def merge(namespace, hash)
      unless self.respond_to? namespace
        fail Error, "Config namespace is not defined"
      end

      # merge the old with the new, replacing nil vals
      hash = send(namespace).marshal_dump.merge(hash) { |_k, o, n| o || n }
      self.class.send(:define_method, namespace.to_sym) do
        return OpenStruct.new(hash)
      end
    end

    def extend(namespace, hash)
      if self.respond_to? namespace
        fail Error, "Config namespace is already defined"
      else
        self.class.send(:define_method, namespace.to_sym) do
          return OpenStruct.new(hash)
        end
      end
    end

    def update(namespace, key, value)
      unless self.respond_to? namespace
        fail Error, "Config namespace is not defined"
      end
      # merge the old with the new
      new = {}
      new[key] = value
      hash = send(namespace).marshal_dump.merge(new) { |_k, o, n| n || o }
      self.class.send(:define_method, namespace.to_sym) do
        return OpenStruct.new(hash)
      end
    end

    private

    def read_params(params_path, defaults_path)
      fail "File not found: #{params_path}" unless File.exist?(params_path)
      fail "File not found: #{defaults_path}" unless File.exist?(defaults_path)

      @params = YAML.load(File.read(params_path))
      @defaults = YAML.load(File.read(defaults_path))
    end

    def build_config(key)
      ch = {}

      @params[key].each do |k, type|
        # Read the params into the config hash, defaulting if a default
        # key exists or requiring (using !) if no default exists
        full_key = "#{@prefix}_#{key}_#{k}"
        if @defaults[key] && @defaults[key].key?(k)
          default_value = @defaults[key][k]
          val = Figaro.env.send("#{full_key}") || default_value
        else
          val = Figaro.env.send("#{full_key}!")
        end

        # Convert to appropriate type as Figaro reads everything as string
        if val
          case type
          when "array"  then ch[k] = conv_a(full_key, val.to_s)
          when "bool"   then ch[k] = conv_b(full_key, val.to_s)
          when "int"    then ch[k] = conv_d(full_key, val.to_s)
          when "float"  then ch[k] = conv_f(full_key, val.to_s)
          when "string" then ch[k] = val.to_s.strip
          else fail(Error, "Type not recognized: #{type}")
          end
        else
          ch[k] = val
        end
      end

      self.class.send(:define_method, key.to_sym) do
        return OpenStruct.new(ch)
      end
    end

    def build_base
      base.each_pair do |k, v|
        self.class.send(:define_method, k.to_sym) do
          return v
        end
      end

      self.class.send(:undef_method, "base")
    end

    def conv_b(key, s)
      if    s =~ /\Atrue\z/i   then true
      elsif s =~ /\Afalse\z/i  then false
      else
        fail Error, "Could not convert '#{key}' ('#{s}') to a boolean"
      end
    end

    def conv_d(key, s)
      if s =~ /\A[-\+]?\d+\z/ then s.to_i
      else
        fail Error, "Could not convert '#{key}' ('#{s}') to an integer"
      end
    end

    def conv_f(key, s)
      if s =~ /\A[-\+]?\d+(\.\d+)?\z/ then s.to_f
      else
        fail Error, "Could not convert '#{key}' ('#{s}') to a float"
      end
    end

    def conv_a(key, s)
      s.split(",")
    rescue
      raise Error, "Could not convert '#{key}' ('#{s}') to an array"
    end
  end

  class Error < StandardError; end
end
