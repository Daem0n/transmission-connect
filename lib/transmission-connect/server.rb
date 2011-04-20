module TransmissionServer
  attr_accessor :data

  def receive_data data
    query = JSON.parse(data)
    case query['command']
      when 'new'
        respond = 'new'
        ## Add magnet link to download client
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
