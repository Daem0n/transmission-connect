#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'transmission-client'
require 'lib/transmission-connect'

CONFIG = "config/transmission.yml"
@exit = false

trap("INT") do
  EventMachine::stop_event_loop
  @exit = true
end

trap("TERM") do
  EventMachine::stop_event_loop
  @exit = true
end

while !@exit
  begin
    EventMachine.run do
      transmission = Configuration.new(YAML.load_file(CONFIG))
      transmission.each do |client|
        EM.add_periodic_timer(client.interval) do
          client.report
        end
      end
      EM.add_periodic_timer(2) do
        transmission.each do |client|
          client.session_stats
        end
      end
      EventMachine::start_server "127.0.0.1", 2456, TransmissionServer do |server|
        server.connectors = transmission
      end
    end
  rescue Exception => e
    puts "Error: #{e.message}"
  end
end
