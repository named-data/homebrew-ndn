require "formula"

class NdnTools < Formula
  version "0.0.0-g6eff4e5"
  homepage "https://github.com/named-data/ndn-tools"
  url "https://github.com/named-data/ndn-tools", :using => :git,
       :revision => "6eff4e56534b3998515b35ca25b3db39bb7aaa3e"

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
