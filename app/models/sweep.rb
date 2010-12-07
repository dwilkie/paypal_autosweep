class Sweep

  PAYPAL_LIVE_URL = "https://paypal.com"
  PAYPAL_SANDBOX_URL = "https://sandbox.paypal.com"
  PAYPAL_DEVELOPER_URL = "https://developer.paypal.com"

  PAYPAL_LIVE_API_ENDPOINT = "https://api-3t.paypal.com/nvp"
  PAYPAL_SANDBOX_API_ENDPOINT = "https://api-3t.sandbox.paypal.com/nvp"

  LOG_IN_LINK_TEXT = "Log In"
  LOG_OUT_LINK_TEXT = "Log Out"
  TRANSFER_LINK_TEXT = "Transfer to Bank Account"

  include DataMapper::Resource
  property :id, Serial
  property :created_at, DateTime
  property :failed_at, DateTime
  property :error, String
  property :backtrace, Text

  attr_accessor :environment, :email, :password,
                :api_username, :api_password, :api_signature,
                :developer_email, :developer_password,
                :minimum_balance, :minimum_transfer

  def perform
    agent = Mechanize.new
    begin
      raise ArgumentError, "don't know your Paypal user details" unless
        email &&
        password &&
        api_username &&
        api_password &&
        api_signature
      end
      amount_to_transfer = transfer_amount
      raise ArgumentError, "transfer amount: #{amount_to_transfer} is less than minimum: #{minimum_transfer.to_f.to_s}"
        unless should_transfer?(amount_to_transfer)
      if sandbox?
        raise ArgumentError, "don't know your Paypal developer user details"
        unless
          developer_email && developer_password
        agent.get(PAYPAL_DEVELOPER_URL)
        form = agent.page.forms.last
        form.login_email = developer_email
        form.login_password = developer_password
        form.checkboxes.last.check
        form.submit
        agent.get(PAYPAL_SANDBOX_URL)
        login_email = sandbox_email
        login_password = sandbox_password
      else
        agent.get(PAYPAL_LIVE_URL)
        login_email = email
        login_password = password
      end
      agent.page.link_with(:text => LOG_IN_LINK_TEXT).click
      form = agent.page.forms.last
      form.login_email = login_email
      form.login_password = login_password
      form.submit
      agent.page.link_with(:text => TRANSFER_LINK_TEXT).click
      form = agent.page.forms.last
      form.amount = amount_to_transfer
      form.submit
      form = agent.page.forms.last
      form.submit
      agent.page.link_with(:text => LOG_OUT_LINK_TEXT).click
    rescue Exception => e
      self.error = e.message
      self.backtrace = e.backtrace
      self.failed_at = Time.now
    end
    self.save
  end

  private

  def get_balance
    body = {
      "METHOD" => "GetBalance",
      "VERSION" => "51",
      "USER" => api_username,
      "PWD" => api_password,
      "SIGNATURE" => api_signature
    }
    uri = sandbox? ? PAYPAL_SANDBOX_API_ENDPOINT : PAYPAL_LIVE_API_ENDPOINT
    response = AppEngine::URLFetch.fetch(
      uri,
      :payload => Rack::Utils.build_nested_query(body),
      :method => 'POST',
      :follow_redirects => false,
      :headers => {"Content-Type" => "application/x-www-form-urlencoded"}
    )
    parsed_response = Rack::Utils.parse_nested_query(response)
    parsed_response["L_AMT0"]
  end

  def transfer_amount
    balance = get_balance.to_f
    transfer = minimum_balance ? balance - minimum_balance.to_f : balance
    transfer = transfer >= minimum_transfer ? transfer : 0 if minimum_transfer
    transfer.to_s
  end

  def should_transfer?(transfer_amount)
    transfer_amount.to_f > 0.00
  end

  def sandbox?
    environment == "sandbox"
  end
end

