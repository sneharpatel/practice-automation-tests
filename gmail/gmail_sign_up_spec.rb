require 'rubygems'
require 'rspec'
require 'selenium-webdriver'
require 'time'
require 'page-object'


class LoginPage
  include PageObject

  span(:create_account_link, :xpath => "//span[text()='Create account']")

  def click_create_an_account_Link
    create_account_link_element.when_visible.click
    return SignUpPage.new(@browser)
  end
end

class SignUpPage
  include PageObject

  text_field(:first_name, :id => 'firstName')
  text_field(:last_name, :id => 'lastName')
  text_field(:user_name, :id => 'username')
  text_field(:password, :name => 'Passwd')
  text_field(:confirm_password, :name => 'ConfirmPasswd')

  def enter_data(first_name: first_name, last_name: last_name, user_name: user_name,
                 password: password, confirm_password: confirm_password)
    self.first_name_element.when_visible.click
    self.first_name = first_name
    self.last_name = last_name
    self.user_name = user_name
    self.password = password
    self.confirm_password = confirm_password

  end

  def click_next_button
    wait_until {@browser.find_element(:xpath, "//*[@id='accountDetailsNext']/content/span").displayed?}
    @browser.find_element(:xpath, "//*[@id='accountDetailsNext']/content/span").click
  end
end



describe 'Gmail - create new user' do

  before(:all) do
    @driver = Selenium::WebDriver.for(:chrome)
    @driver.navigate.to("https://www.gmail.com")
  end

  after(:all) do
    @driver.quit
  end

  it "user should successfully create a gmail account" do
    login_page = LoginPage.new(@driver)
    signup_page = login_page.click_create_an_account_Link
    signup_page.enter_data(first_name: 'firstName', last_name: "lastName", user_name: "userName",
                           password: "password123", confirm_password: "password123")
    signup_page.click_next_button
  end

end