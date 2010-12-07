class Sweep

  PAYPAL_LIVE_URL = "https://paypal.com"
  PAYPAL_SANDBOX_URL = "https://sandbox.paypal.com"
  PAYPAL_DEVELOPER_URL = "https://developer.paypal.com"

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
                :developer_email, :developer_password,
                :minimum_balance, :minimum_transfer

  def perform
    agent = Mechanize.new
    begin
      raise AgumentError, "don't know your Paypal user details" unless
        email && password
      end
      if environment == "sandbox"
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
      form.amount = "400"
      form.submit
      form = agent.page.forms.last
      form.submit
      agent.page
      agent.page.link_with(:text => LOG_OUT_LINK_TEXT).click
    rescue Exception => e
      self.error = e.message
      self.backtrace = e.backtrace
      self.failed_at = Time.now
    end
    self.save
  end
end

