require "formula"

class NdnCxx < Formula
  version "0.4.0"
  homepage "http://named-data/doc/ndn-cxx/"
  url "https://github.com/named-data/ndn-cxx", :using => :git,
       :tag => "ndn-cxx-0.4.0"

  head "https://github.com/named-data/ndn-cxx", :using => :git,
       :branch => "master"

  depends_on "pkg-config" => :build
  depends_on "cryptopp"
  depends_on "boost"

  bottle do
    root_url "http://named-data.net/binaries/homebrew"
  end
  
  def install
    boost = Formula["boost"]
    cryptopp = Formula["cryptopp"]

    (buildpath/"VERSION").write version

    system "./waf", "configure",
             "--disable-static",
             "--enable-shared",
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
