require "formula"

class Ndnping < Formula
  version "0.1.0-11-g1283684"
  homepage "https://github.com/named-data/ndn-tlv-ping"
  url "https://github.com/named-data/ndn-tlv-ping", :using => :git,
       :revision => "1283684bacb2352de38c8f0ad21a069875583d91"

  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "ndn-cxx"

  bottle do
    root_url "http://named-data.net/binaries/homebrew"
    prefix "/usr/local"
    cellar "/usr/local/Cellar"

    sha1 "d76d590126c5467c3d1451d286ae8c132d773754" => :yosemite
  end

  def install
    system "./waf", "configure",
             "--prefix=#{prefix}"
    system "./waf"
    system "./waf", "install"
  end
end
