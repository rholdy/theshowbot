require ‘pry’
require ‘bundler’
require ‘json’
require ‘rest-client’

Bundler.require

require_relative “./theshow/file”
require_relative “./theshow/cli”
require_relative “./theshow/api”