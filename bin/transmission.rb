#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'transmission-client'
require '../lib/transmission-connect'

CONFIG = "../config/transmission.yml"
result = []

while true
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
    end
  rescue
  end
end
