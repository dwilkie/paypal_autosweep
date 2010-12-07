require 'sinatra/base'
require 'mechanize'
require './app/models/sweep'

class PaypalAutosweep < Sinatra::Base

  set paypal_settings = YAML.load(
    File.read("config/paypal.yml")
  )

  # Tasks uris

  # Autosweep
  post '/tasks/sweeps' do
    sweep = Sweep.new
    sweep.environment = paypal_settings['paypal']['environment']
    sweep.email = paypal_settings['paypal']['email']
    sweep.password = paypal_settings['paypal']['password']
    sweep.api_username = paypal_settings['paypal']['api_username']
    sweep.api_password = paypal_settings['paypal']['api_password']
    sweep.api_signature = paypal_settings['paypal']['api_signature']
    sweep.developer_email =  paypal_settings['paypal']['developer_email']
    sweep.developer_password =  paypal_settings['paypal']['developer_password']
    sweep.minimum_balance = paypal_settings['paypal']['minimum_balance']
    sweep.minimum_transfer = paypal_settings['paypal']['minimum_transfer']
    sweep.perform
  end

  get '/cron/autosweep' do
    AppEngine::Labs::TaskQueue.add(
      nil,
      :url => "/tasks/sweeps",
      :method => 'POST'
    )
  end
end

