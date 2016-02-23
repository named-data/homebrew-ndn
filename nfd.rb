require "formula"

class Nfd < Formula
  version "0.4.0"
  homepage "http://named-data/doc/NFD/"
  url "https://github.com/named-data/NFD", :using => :git,
       :tag => "NFD-0.4.0"

  head "https://github.com/named-data/NFD", :using => :git,
       :branch => "master"

  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "ndn-cxx"

  bottle do
    root_url "http://named-data.net/binaries/homebrew"
  end

  def install
    boost = Formula["boost"]
    cryptopp = Formula["cryptopp"]

    FileUtils.rm (buildpath/"tools/nfd-start.sh")
    FileUtils.rm (buildpath/"tools/nfd-stop.sh")
    (buildpath/"tools/nfd-start.sh").write nfd_start
    (buildpath/"tools/nfd-stop.sh").write nfd_stop

    (buildpath/"VERSION").write version

    system "./waf", "configure",
             "--without-pch",
             "--sysconfdir=#{etc}",
             "--prefix=#{prefix}",
             "--boost-includes=#{boost.include}",
             "--boost-libs=#{boost.lib}"
    system "./waf"
    system "./waf", "install"

    # Startup scripts
    (buildpath/"net.named-data.nfd.plist").write plist_nfd
    (share/"ndn/").install "net.named-data.nfd.plist"
  end

  def post_install
    # Default configuration
    begin
      (etc/"ndn/nfd.conf").write nfd_conf
    rescue
      # Do not overwrite existing configuration
    end

    ndn_cxx = Formula["ndn-cxx"]

    (var/'log/ndn').mkpath

    nfd_home = var/'lib/ndn/nfd'
    (nfd_home/'.ndn').mkpath

    nfd_certgen = -> {
      begin
        (nfd_home/'.ndn/client.conf').write "tpm=tpm-file:\n"

        # Generate self-signed cert for NFD
        system "HOME=#{nfd_home} #{ndn_cxx.bin}/ndnsec-keygen /localhost/daemons/nfd | " \
               "HOME=#{nfd_home} #{ndn_cxx.bin}/ndnsec-install-cert -"

        system "sudo chown -R nobody:nogroup \"#{nfd_home}\""
      rescue
      end
    }

    config_nfd_cert = -> {
      # Dump NFD certificate
      (etc/"ndn/certs").mkpath
      system "HOME=#{nfd_home} #{ndn_cxx.bin}/ndnsec-dump-certificate $(HOME=#{nfd_home} #{ndn_cxx.bin}/ndnsec-get-default -c) > " \
             "#{etc}/ndn/certs/localhost_daemons_nfd.ndncert"
    }

    nfd_certgen.()

    begin
      config_nfd_cert.()
    rescue
      rm_r nfd_home

      nfd_certgen.()
      config_nfd_cert.()
    end
  end

  def caveats
    s = []

    s << "To start NFD and ensure it is started when system boots:"
    s << ""
    s << "    nfd-start"
    s << ""
    s << "To stop NFD and disable auto-start when system boots:"
    s << ""
    s << "    nfd-stop"
    s << ""
    s << "NFD log files are located in #{var}/log/ndn"
    s << ""
    s << "Configuration file is in #{etc}/ndn/"

    s.join("\n") unless s.empty?
  end

  def nfd_conf; <<-EOS.undent
    ; The general section contains settings of nfd process.
    general
    {
       user nobody
       group nogroup
    }

    log
    {
      ; default_level specifies the logging level for modules
      ; that are not explicitly named. All debugging levels
      ; listed above the selected value are enabled.
      ;
      ; Valid values:
      ;
      ;  NONE ; no messages
      ;  ERROR ; error messages
      ;  WARN ; warning messages
      ;  INFO ; informational messages (default)
      ;  DEBUG ; debugging messages
      ;  TRACE ; trace messages (most verbose)
      ;  ALL ; all messages

      default_level INFO

      ; You may override default_level by assigning a logging level
      ; to the desired module name. Module names can be found in two ways:
      ;
      ; Run:
      ;   nfd --modules
      ;
      ; Or look for NFD_LOG_INIT(<module name>) statements in .cpp files
      ;
      ; Example module-level settings:
      ;
      ; FibManager DEBUG
      ; Forwarder INFO
    }

    ; The tables section configures the CS, PIT, FIB, Strategy Choice, and Measurements
    tables
    {

      ; ContentStore size limit in number of packets
      ; default is 65536, about 500MB with 8KB packet size
      cs_max_packets 65536

      ; Set the forwarding strategy for the specified prefixes:
      ;   <prefix> <strategy>
      strategy_choice
      {
        /               /localhost/nfd/strategy/best-route
        /localhost      /localhost/nfd/strategy/broadcast
        /localhost/nfd  /localhost/nfd/strategy/best-route
        /ndn/broadcast  /localhost/nfd/strategy/broadcast
      }
    }

    ; The face_system section defines what faces and channels are created.
    face_system
    {
      ; The unix section contains settings of UNIX stream faces and channels.
      ; Unix channel is always listening; delete unix section to disable
      ; Unix stream faces and channels.
      unix
      {
        path /var/run/nfd.sock ; UNIX stream listener path
      }

      ; The tcp section contains settings of TCP faces and channels.
      tcp
      {
        listen yes ; set to 'no' to disable TCP listener, default 'yes'
        port 6363 ; TCP listener port number
        enable_v4 yes ; set to 'no' to disable IPv4 channels, default 'yes'
        enable_v6 yes ; set to 'no' to disable IPv6 channels, default 'yes'
      }

      ; The udp section contains settings of UDP faces and channels.
      ; UDP channel is always listening; delete udp section to disable UDP
      udp
      {
        port 6363 ; UDP unicast port number
        enable_v4 yes ; set to 'no' to disable IPv4 channels, default 'yes'
        enable_v6 yes ; set to 'no' to disable IPv6 channels, default 'yes'
        idle_timeout 600 ; idle time (seconds) before closing a UDP unicast face
        keep_alive_interval 25; interval (seconds) between keep-alive refreshes

        ; UDP multicast settings
        ; NFD creates one UDP multicast face per NIC
        mcast yes ; set to 'no' to disable UDP multicast, default 'yes'
        mcast_port 56363 ; UDP multicast port number
        mcast_group 224.0.23.170 ; UDP multicast group (IPv4 only)
      }

      ; The ether section contains settings of Ethernet faces and channels.
      ether
      {
        ; Ethernet multicast settings
        ; NFD creates one Ethernet multicast face per NIC
        mcast yes ; set to 'no' to disable Ethernet multicast, default 'yes'
        mcast_group 01:00:5E:00:17:AA ; Ethernet multicast group
      }

      ; The websocket section contains settings of WebSocket faces and channels.

      websocket
      {
        listen yes ; set to 'no' to disable WebSocket listener, default 'yes'
        port 9696 ; WebSocket listener port number
        enable_v4 yes ; set to 'no' to disable listening on IPv4 socket, default 'yes'
        enable_v6 yes ; set to 'no' to disable listening on IPv6 socket, default 'yes'
      }
    }

    authorizations
    {
      authorize
      {
        certfile certs/localhost_daemons_nfd.ndncert
        privileges
        {
            faces
            fib
            strategy-choice
        }
      }

      authorize
      {
        certfile any
        privileges
        {
            faces
            strategy-choice
        }
      }
    }

    rib
    {
      ; The following localhost_security allows anyone to register routing entries in local RIB
      localhost_security
      {
        trust-anchor
        {
          type any
        }
      }

      auto_prefix_propagate
      {
        cost 15 ; forwarding cost of prefix registered on remote router
        timeout 10000 ; timeout (in milliseconds) of prefix registration command for propagation

        refresh_interval 300 ; interval (in seconds) before refreshing the propagation
        ; This setting should be less than face_system.udp.idle_time,
        ; so that the face is kept alive on the remote router.

        base_retry_wait 50 ; base wait time (in seconds) before retrying propagation
        max_retry_wait 3600 ; maximum wait time (in seconds) before retrying propagation
        ; for consequent retries, the wait time before each retry is calculated based on the back-off
        ; policy. Initially, the wait time is set to base_retry_wait, then it will be doubled for every
        ; retry unless beyond the max_retry_wait, in which case max_retry_wait is set as the wait time.
      }
    }
    EOS
  end

  def plist_nfd; <<-EOS.undent
    <?xml version='1.0' encoding='UTF-8'?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd" >
    <plist version='1.0'>
    <dict>
    <key>Label</key><string>net.named-data.nfd</string>
    <key>ProgramArguments</key>
    <array>
      <string>#{opt_bin}/nfd</string>
      <string>--config</string>
      <string>#{etc}/ndn/nfd.conf</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
      <key>HOME</key><string>#{var}/lib/ndn/nfd</string>
    </dict>
    <key>Disabled</key><true/>
    <key>KeepAlive</key><true/>
    <key>StandardErrorPath</key><string>#{var}/log/ndn/nfd.log</string>
    <key>ProcessType</key><string>Background</string>
    </dict>
    </plist>
    EOS
  end

  def nfd_start; <<-EOS.undent
    #!@BASH@

    VERSION="@VERSION@"

    case "$1" in
      -h)
        echo Usage
        echo $0
        echo "  Start NFD"
        exit 0
        ;;
      -V)
        echo $VERSION
        exit 0
        ;;
      "") ;; # do nothing
      *)
        echo "Unrecognized option $1"
        exit 1
        ;;
    esac

    if ! sudo true
    then
      echo 'Unable to obtain superuser privilege'
      exit 2
    fi

    sudo chown root #{share}/ndn/net.named-data.nfd.plist
    sudo launchctl load -w #{share}/ndn/net.named-data.nfd.plist
    EOS
  end

  def nfd_stop; <<-EOS.undent
    #!@BASH@

    VERSION="@VERSION@"

    case "$1" in
      -h)
        echo Usage
        echo $0
        echo "  Stop NFD"
        exit 0
        ;;
      -V)
        echo $VERSION
        exit 0
        ;;
      "") ;; # do nothing
      *)
        echo "Unrecognized option $1"
        exit 1
        ;;
    esac

    if ! sudo true
    then
      echo 'Unable to obtain superuser privilege'
      exit 2
    fi

    sudo launchctl unload -w #{share}/ndn/net.named-data.nfd.plist
    EOS
  end
end
