require 'rspec'
require 'selenium-webdriver'
require 'time'
require 'rubygems'

class BasePage
  def initialize(driver)
    @driver = driver
  end
end

class SignInPage < BasePage

  def create_account_link
    @driver.find_element(:xpath, "//span[text()='Create account']")
  end

  def click_create_account
    self.create_account_link.click()
    return CreateAccountPage.new(@driver)
  end
end

class CreateAccountPage < BasePage

  def first_name_input
    @driver.find_element(:id, "firstName")
  end
  def last_name_input
    @driver.find_element(:id, "lastName")
  end

  def user_name_input
    @driver.find_element(:id, "username")
  end
  def password_input
    @driver.find_element(:id, "passwd")
  end
  def confirm_password
    @driver.find_element(:id, "password")
  end

  def fill_data(first_name: first_name, last_name: last_name, user_name: user_name,
                password: password, confirm_password: confirm_password )
    self.first_name_input.send_keys first_name
    self.last_name_input.send_keys last_name
    self.user_name_input.send_keys user_name
    self.password_input.send_keys password
    self.confirm_password.send_keys confirm_password
  end

  def next_button
    @driver.find_element(:id, "accountDetailsNext")
  end

  def click_next
    self.next_button.click
    return PhoneVerificationPage.new(@driver)
  end

end

class PhoneVerificationPage < BasePage
  def next_button_on_phone_verification
    @driver.find_element(:id,"gradsIdvPhoneNext")
  end

  def verify_header
    @driver.find_element(:id, "headingText")
  end
end

describe "Gmail - Create user account" do

  before(:all) do
    @driver = Selenium::WebDriver.for :chrome
    @driver.navigate.to "https://www.gmail.com"
    @wait = Selenium::WebDriver::Wait.for(timeout=>15)  # implicit wait: This tells Selenium to retry each find_element action
                                                        # for up to 15 seconds. If it can complete the action in that amount of time,
                                                        # it will proceed onto the next command. Otherwise it will raise
                                                        # a timeout exception.
  end

  after(:all) do
    @driver.quit
  end

  it "User should able to create an account" do
    signin_page = SignInPage.new(@driver)
    create_account_page = signin_page.click_create_account
    @wait.until{ create_account_page.first_name.displayed?}  # explicit wait: if we wrap our .displayed?
                                                              # action in an explicit wait we are able to
                                                              # override the implicit wait.
    create_account_page.fill_data(first_name: 'firstName', last_name: 'lastName', user_name: 'userName',
                                  password: 'password123', confirm_password: 'password123')
    # create_account_page.click_next
    phone_verification_page = create_account_page.click_next
    @wait.until{ phone_verification_page.next_button_on_phone_verification.displayed?} # explicit wait
    expect(phone_verification_page.verify_header.text).to eq("Verify your phone number")
  end

end