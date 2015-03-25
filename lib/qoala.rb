require 'qoala/railtie'
require 'qoala/controller'

module Qoala

  class << self
    attr_accessor :settings
  end

  def self.setup
    self.settings ||= Settings.new
    yield settings
  end

  class Settings
    attr_accessor :api_key
    attr_accessor :api_secret

    def initialize
      # authenticate calls from qoala to client
      @api_key = ""
      # encrypt data sent from client to qoala
      @api_secret = ""
    end
  end

end
