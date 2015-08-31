require "formula"

class NdnTools < Formula
  version "0.2"
  homepage "https://github.com/named-data/ndn-tools"
  url "https://github.com/named-data/ndn-tools", :using => :git,
       :tag => "ndn-tools-0.2"

  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "ndn-cxx"

  bottle do
    root_url "http://named-data.net/binaries/homebrew"
    prefix "/usr/local"
    cellar "/usr/local/Cellar"
  end

  def install
    system "./waf", "configure",
             "--prefix=#{prefix}"
    system "./waf"
    system "./waf", "install"
  end
end
