require "formula"

class NdnTools < Formula
  version "0.2-6-gae2c9f7"
  homepage "https://github.com/named-data/ndn-tools"
  url "https://github.com/named-data/ndn-tools", :using => :git,
       :revision => "ae2c9f73ad78511d240e1ae67de99cdb0f997668"

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
