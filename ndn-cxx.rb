require "formula"

class NdnCxx < Formula
  version "0.2.0-135-g29ea835"
  homepage "http://named-data/doc/ndn-cxx/"
  url "https://github.com/named-data/ndn-cxx", :using => :git,
       :revision => "29ea8358e49cfc21ae4a290748ea24d5eaf98b6d"

  head "https://github.com/named-data/ndn-cxx", :using => :git,
       :branch => "master"

  depends_on "boost"
  depends_on "cryptopp"

  bottle do
    root_url "http://named-data.net/binaries/homebrew"
    prefix "/usr/local"
    cellar "/usr/local/Cellar"

    revision 1
    sha1 "cc4dd99fc91cc844df55e434362443107d25295c" => :yosemite
  end
  
  def install
    boost = Formula["boost"]
    cryptopp = Formula["cryptopp"]

    (buildpath/"VERSION").write version

    system "./waf", "configure",
             "--without-pch",
             "--sysconfdir=#{etc}",
             "--prefix=#{prefix}",
             "--with-cryptopp=#{cryptopp.prefix}",
             "--boost-includes=#{boost.include}",
             "--boost-libs=#{boost.lib}"
    system "./waf"
    system "./waf", "install"
  end
end
