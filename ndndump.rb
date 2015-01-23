require "formula"

class Ndndump < Formula
  version "0.5.1-3-g0ce6036"
  homepage "https://github.com/named-data/ndndump"
  url "https://github.com/named-data/ndndump", :using => :git,
       :revision => "0ce60362a285f42cf2ecbeea8cff0c7919d28d72"

  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "ndn-cxx"

  bottle do
    root_url "http://named-data.net/binaries/homebrew"
    prefix "/usr/local"
    cellar "/usr/local/Cellar"

    revision 1
    sha1 "ddde650c5e0845d51ca5cf7e881b9d3834a27561" => :yosemite
  end

  def install
    boost = Formula["boost"]

    system "./waf", "configure",
             "--prefix=#{prefix}",
             "--boost-includes=#{boost.include}",
             "--boost-libs=#{boost.lib}"
    system "./waf"
    system "./waf", "install"
  end
end
