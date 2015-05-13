require "formula"

class Ndnping < Formula
  version "0.1.0-12-gd3675f5"

  homepage "https://github.com/named-data/ndn-tlv-ping"
  url "https://github.com/named-data/ndn-tlv-ping", :using => :git,
       :revision => "d3675f528af468d59b2c505057acd21b56210c5c"

  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "ndn-cxx"

  bottle do
    root_url "http://named-data.net/binaries/homebrew"
    prefix "/usr/local"
    cellar "/usr/local/Cellar"

    revision 1
    sha1 "eb7a758d27f4c668dd0d2496dd9623e0588dffe6" => :yosemite
  end

  def install
    system "./waf", "configure",
             "--prefix=#{prefix}"
    system "./waf"
    system "./waf", "install"
  end
end
