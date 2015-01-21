Homebrew tap for Named Data Networking (NDN) projects
=====================================================

This tap provides formulae for NDN-related projects (http://named-data.net)

## How to install packages from NDN tap?

There are a few ways to install packages from NDN tap:

- Specify the full name of the package

        brew install named-data/ndn/<formula>

- Configure tap and use just package name

        brew tap named-data/ndn
        brew install <formula>

- Directly via URL (will not receive updates):

        brew install https://raw.githubusercontent.com/named-data/homebrew-ndn/master/<formula>.rb
