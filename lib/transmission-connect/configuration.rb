class Configuration
  include Enumerable

  ## def initialize(args)
  ## args - array of hashes:
  #  args = [
  #      {
  #          :host => '127.0.0.1',
  #          :port => 9091,
  #          :down => true
  #      },
  #      {
  #          :host => '127.0.0.1',
  #          :port => 9092,
  #          :up => true
  #      },
  #      {
  #          :host => '192.168.100.199',
  #          :port => 9091,
  #          :username => 'username',
  #          :password => 'password',
  #          :down => true,
  #          :up => true
  #      }
  #  ]
  def initialize(args = [])
    @clients = []
    @downs = []
    @ups = []
    args.each do |arg|
      client = Client.new(arg)
      @clients << client
      @downs << client if arg.key?(:down) && arg[:down]
      @ups << client if arg.key?(:up) && arg[:up]
    end
  end

  def each
    @clients.each{|i| yield i}
  end

  def each_ups
    @ups.each{|i| yield i}
  end

  def each_downs
    @downs.each{|i| yield i}
  end

  class Client
#    HOST = 'http://127.0.0.1:3000'
    HOST = 'http://peerlize.hitlan.ru'
    FIELDS = ['downloadDir', 'error', 'errorString', 'eta', 'hashString', 'id', 'name', 'peersConnected', 'peersKnown', 'peersSendingToUs', 'percentDone', 'rateDownload', 'rateUpload', 'recheckProgress', 'startDate', 'status', 'totalSize', 'torrentFile']
    attr_reader :interval
    def initialize(args)
      @host = args.delete(:host) || '127.0.0.1'
      @port = args.delete(:port) || 9091
      @username = args[:username]
      @password = args[:password]
      @interval = args.delete(:interval) || 5
      @transmission = Transmission::Client.new(@host, @port, @username, @password)
    end

    def report
      @transmission.torrents(FIELDS) do |torrents|
        result = {:host => "#{@host}:#{@port}"}
        torrents.each do |torrent|
          puts 'torrent'
          result[torrent.hashString.to_sym] = torrent.attributes
        end
        EM::HttpRequest.new("#{HOST}/transmission/").post :body => {:torrents => result.to_json}
      end
    end

    def session_stats
      @transmission.session_stat do |ss|
        puts 'session'
        result = ss.attributes.merge({:host => "#{@host}:#{@port}"})
        EM::HttpRequest.new("#{HOST}/transmission/stat").post :body => {:session_stat => result.to_json}
      end
    end

  end

end