require "formula"

class Ndnping < Formula
  desc "Replaced with ndn-tools package"
  version "0.2-replaced-by-ndn-tools"

  homepage "https://github.com/named-data/ndn-tools"
  url "https://github.com/named-data/ndn-tools", :using => :git,
       :revision => "6eff4e56534b3998515b35ca25b3db39bb7aaa3e"

  depends_on "ndn-tools"
  depends_on "boost"
  depends_on "ndn-cxx"
end
