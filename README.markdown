# paypal_autosweep

## Coming Soon

Paypal offers a feature called [Autosweep](http://www.ehow.com/how_4598202_automatically-transfer-payments-checking-account.html) which will withdraw your Paypal balance into your back account at the end of the day. Problem is Autosweep is only available to US bank account holders and is somewhat inflexible.

This mini app built for [Google App Engine](http://appengine.google.com) allows you to use the functionality of Autosweep on any Paypal account linked to a bank account. Advanced features include setting up minimum balances and minimum transfer amounts as well as testing in the sandbox.

Since the Paypal API doesn't allow you to transfer money to your bank account, this app requires you upload your Paypal email address and password to your google app-engine account. This data is kept private, but if you are uncomfortable with this please don't use this service.

## Installation Instructions

If you haven't already done so, install ruby, rubygems and git.
Windows users see: (https://github.com/dwilkie/paypal_autosweep/wiki/Windows)

### Quick Setup

1. Create a new free app at: (http://appengine.google.com)
2. Install google-appengine: `gem install google-appengine`
3. Clone this repos: `git clone git://github.com/dwilkie/paypal_autosweep.git`
4. Open up: `paypal_autosweep/WEB-INF/app.yaml`
5. Change `application` to the name of your application from step #1
6. Open up: `paypal_autosweep/config/paypal.yml`
7. Change `email` and `password` to your Paypal email and password
8. Upload to google-appengine: `appcfg.rb update .` and follow the prompts

By default your entire Paypal balance will be transferred to your linked bank account every 24 hours.

### Advanced Configuration

`paypal_autosweep/config/paypal.yml` contains advanced configuration options such as developer and sandbox accounts as well as minimum balance and minimum transfer options

`paypal_autosweep/WEB-INF/cron.yaml` controls the scheduling of your autosweeps. Read the examples in this file to change the scheduling.

