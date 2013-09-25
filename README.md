Tenpay demo
========

This is a simple rails app to show how to use [tenpay](https://github.com/jasl/tenpay) gem.

# Installation

- ```git clone```
- ```bundle```
- ```rails s```

# Important

Tenpay will request the site to notify payment,
so the app must be deployed on public network to make Tenpay can reach it.

Tenpay account configure can be found at ```config/initializers/tenpay.rb```,
default is Tenpay official test account, you could not to refund money you paid for test.
