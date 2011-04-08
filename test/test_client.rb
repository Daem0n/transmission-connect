require 'helper'

class TestClient < Test::Unit::TestCase
  context "a transmission client" do
    setup do
      @uri = URI.parse("http://127.0.0.1:9091/transmission/rpc")
      @connect = Transmission::Client.new
      @hash = '562e7e6eb0852a652f329f5e8518385c5762fa84'
      @hash = @hash.upcase
    end

    should "have connection" do
      assert_instance_of Transmission::Client, @connect
    end

    should "get common info" do
      assert_instance_of Hash, @connect.session_stats
    end

    should "get all torrents info" do
      assert_instance_of Hash, @connect.get_info
    end

    context 'with torrent' do
      setup do
        @count = @connect.session_stats["torrentCount"]
        @arg_count = Transmission::Client::TORRENT_ARGS.count
      end

      should "add magnet link to downloads" do
        result = @connect.add_bt_magnet(@hash)
        count = @connect.session_stats["torrentCount"]
        assert_equal @count + 1, count
#        @count = count
        assert_equal @hash.upcase, result['torrent-added']['hashString'].upcase
      end

      should 'get info about all' do
        result = @connect.get_info
        assert_instance_of Hash, result
        assert_equal @count, result['torrents'].count
        result['torrents'].each do |torrent|
          assert_equal @arg_count, torrent.keys.count
        end
      end

      should 'get info by hash' do
        result = @connect.get_info(@hash)
        assert_instance_of Hash, result
        assert_equal 1, result['torrents'].count
        assert_equal @arg_count, result['torrents'].first.keys.count
      end

      should "remove by magnet link" do
        result = @connect.rem_bt_magnet(@hash)
        assert_equal @count - 1, @connect.session_stats["torrentCount"]
      end

    end

  end
end
