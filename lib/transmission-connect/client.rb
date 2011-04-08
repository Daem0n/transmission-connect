module Transmission
  RPC_PATH = 'transmission/rpc'

  class Client
    SESSION_STAT_ARGS = %w(activeTorrentCount downloadSpeed pausedTorrentCount torrentCount uploadSpeed cumulative-stats current-stats)
    TORRENT_ARGS = %w(downloadDir hashString id isFinished name percentDone sizeWhenDone status totalSize error errorString)
    CHECK_WAIT = 1
    CHECK = 2
    DOWNLOAD = 4
    SEED = 8
    STOPPED = 16
    STATUS = {
        1 => :check_wait,
        2 => :check,
        4 => :download,
        8 => :seed,
        16 => :stopped
    }


    def initialize(host = '127.0.0.1', port = 9091, username = nil, password = nil)
      @header = username.nil? ? {} : {'Authorization' => Base64.encode64("#{username}:#{password}")}
      @uri = URI.parse("http://#{host}:#{port}/#{RPC_PATH}")
      @connection = Net::HTTP.start(@uri.host, @uri.port)
    end

    def session_stats(args = {})
      request('session-stats', args)
    end

    def add_bt_magnet(hash)
      hash = "magnet:?xt=urn:btih:#{hash}"
      request('torrent-add', {:filename => hash})
    end

    def rem_bt_magnet(hash)
      request('torrent-remove', {:ids => hash.to_a})
    end

    def get_info(hash = nil)
      args = hash.nil? ? {} : {:ids => hash.to_a}
      args = {:fields => TORRENT_ARGS}.merge(args)
      request('torrent-get', args)
    end

    private
    def request(method, args)
      post_data = build_json method, args
      result = @connection.post2(@uri.path, post_data, @header)
      case result
        when Net::HTTPSuccess
          JSON.parse(result.read_body)['arguments']
        when Net::HTTPConflict
          @header = @header.merge("x-transmission-session-id" => result.header["x-transmission-session-id"])
          request(method, args)
        else
          raise Exception
      end
    end

    def build_json(method,attributes = {})
      if attributes.length == 0
        {'method' => method}.to_json
      else
        {'method' => method, 'arguments' => attributes }.to_json
      end
    end

  end
end
