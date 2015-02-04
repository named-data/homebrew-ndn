require "formula"

class NdnCxx < Formula
  version "0.3.0"
  homepage "http://named-data/doc/ndn-cxx/"
  url "https://github.com/named-data/ndn-cxx", :using => :git,
       :tag => "ndn-cxx-0.3.0"

  head "https://github.com/named-data/ndn-cxx", :using => :git,
       :branch => "master"

  depends_on "pkg-config" => :build
  depends_on "cryptopp"
  depends_on "boost"

  bottle do
    root_url "http://named-data.net/binaries/homebrew"
    sha1 "96a0c94b09cfdb5385406c995f1d151f7c492add" => :yosemite
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
