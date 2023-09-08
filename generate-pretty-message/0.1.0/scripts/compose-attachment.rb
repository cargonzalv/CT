#!/usr/local/bin/ruby
require 'erb'
require 'json'
require 'ostruct'

template_file = ENV['TEMPLATE_FILE'] || ''
destination   = ENV['MESSAGE_DESTINATION'] || ''

namespace = OpenStruct.new

template = File.read(template_file)

namespace.message = ENV['MESSAGE']
namespace.colour  = ENV['COLOUR'] || '#4EC2C5'
namespace.title   = ENV['TITLE']
namespace.author  = ENV['AUTHOR'] || 'Concourse'

namespace.unixtime = Time.now.to_i

puts output = ERB.new(template).result(namespace.instance_eval { binding })

json = JSON.parse(output)
fallback = json[0]['fallback']

File.write(destination, output)
File.write(File.join(File.dirname(destination), 'fallback'), fallback)
