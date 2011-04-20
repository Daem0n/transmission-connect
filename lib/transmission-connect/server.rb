module TransmissionServer
  attr_accessor :data

  def receive_data data
    query = JSON.parse(data)
    case query['command']
      when 'add'
        respond = 'add'
        target = query['client']
        ## Add magnet link to download client
        session = data.find{|client| client.host == target['host'] and client.port == target['port']}
        client.add_torrent_by_file(query['uri'])
      when 'move'
        respond = 'move'
        ## Move torrent from download to upload client
      else
        respond = 'Illegal operation'
    end
    send_data respond
    close_connection_after_writing
  end

end
