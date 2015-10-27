require "formula"

class NdnTools < Formula
  version "0.2-2-ge02fb52"
  homepage "https://github.com/named-data/ndn-tools"
  url "https://github.com/named-data/ndn-tools", :using => :git,
       :revision => "e02fb5209092559d5fe00cb19bd8382f1c6b4329"

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
