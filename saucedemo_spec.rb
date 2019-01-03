# Automate https://www.saucedemo.com/index.html
# 1. user: standard_user, password: secret_sauce
# 2. select two product and add to cart
#   Sauce Labs Onesie
#   Sauce Labs Fleece Jacket
# 3. Go to Cart, make sure there are two items in cart only
# 4. click checheout
# 5. fill out shipping information (firstName, lastName, zip: 94534)
# 6. make sure total is correct on final page
# 7. click Finish and validate message on finish page
# 8. logout
#

require 'selenium-webdriver'
require 'rspec'
require 'time'
require 'rubygems'

class BasePage
  def initialize(driver)
    @driver = driver
  end
end

class SignInPage < BasePage
  def username_input
    @driver.find_element(:xpath, "//*[@id='login_button_container']/div/form/input[1]")
  end

  def password_input
    @driver.find_element(:xpath, "//*[@id='login_button_container']/div/form/input[2]")
  end

  def login_button
    @driver.find_element(:class, "login-button")
  end

  def fill_data(user_name: user_name, password: password)
    self.username_input.send_keys user_name
    self.password_input.send_keys password
  end

  def login_button_click
    self.login_button.click
    return ProductPage.new(@driver)
  end

end

class ProductPage < BasePage
  def second_element
    @driver.find_element(:id, "item_1_title_link")
  end

  def select_product(prod_id)
    prod_list = @driver.find_elements(:class, "inventory_list")
    prod_list.each do |item|
      sel_item = item.find_element(:id, prod_id).find_element(:xpath, "..").find_element(:xpath, "..")
      cart_button = sel_item.find_element(:class, "add-to-cart-button")
      cart_button.click
    end
  end

  def select_two_products_and_add_to_cart
    self.select_product("item_5_title_link")
    self.select_product("item_2_title_link")
  end


  def click_cart_icon
    @driver.find_element(:id, "shopping_cart_container").click
    return CartPage.new(@driver)
  end

  def shopping_cart_badge
    @driver.find_element(:class, "shopping_cart_badge")
  end

end

class CartPage < BasePage
  def checkout_button
    @driver.find_element(:class, "cart_checkout_link")
  end
  def click_checkout_button
    self.checkout_button.click
    return CheckOutPage.new(@driver)
  end
end

class CheckOutPage < BasePage
  def first_name_input
    @driver.find_element(:xpath, "//*[@id='checkout_info_container']/div/form/input[1]")
  end
  def last_name_input
    @driver.find_element(:xpath, "//*[@id='checkout_info_container']/div/form/input[2]")
  end
  def zip_postal_code
    @driver.find_element(:xpath, "//*[@id='checkout_info_container']/div/form/input[3]")
  end

  def fill_data_on_checkout(first_name: first_name, last_name: last_name, zip_postal_code: zip_postal_code)
    self.first_name_input.send_keys first_name
    self.last_name_input.send_keys last_name
    self.zip_postal_code.send_keys zip_postal_code
  end

  def continue_button
    @driver.find_element(:class, "cart_checkout_link")
  end
  def click_continue_button
    self.continue_button.click
    return FinalPage.new(@driver)
  end

end

class FinalPage < BasePage
  def total_amount
    @driver.find_element(:class, "summary_total_label")
  end

  def click_finish
    @driver.find_element(:class, "cart_checkout_link").click
    return FinishPage.new(@driver)
  end
end

class FinishPage < BasePage
  def verify_order_complete_message
    @driver.find_element(:class, "complete-header")
  end

  def humburger_icon
    @driver.find_element(:class, "bm-burger-button")
  end

  def click_humburger_icon
    self.humburger_icon.click
  end

  def logout_option
    @driver.find_element(:id, "logout_sidebar_link")
  end

  def logout
    self.logout_option.click
  end

  def reset_app_link
    @driver.find_element(:id, "reset_sidebar_link")
  end

end


RSpec.describe "Saucedemo: place an order" do
  before(:all) do
    @driver = Selenium::WebDriver.for :chrome
    @driver.navigate.to "https://www.saucedemo.com/"
    @wait = Selenium::WebDriver::Wait.new(:timeout => 20)

  end
  after(:all) do
    @driver.quit
  end

  it "user should be able to make an order" do
    signin_page = SignInPage.new(@driver)
    signin_page.fill_data(user_name: 'standard_user', password: 'secret_sauce')
    product_page = signin_page.login_button_click
    @wait.until{ product_page.second_element.displayed? }
    product_page.select_two_products_and_add_to_cart
    expect(product_page.shopping_cart_badge.text).to eq "2"
    cart_page = product_page.click_cart_icon
    check_out_page = cart_page.click_checkout_button
    check_out_page.fill_data_on_checkout(first_name: 'firstName', last_name: 'lastName', zip_postal_code: '94534')
    final_page = check_out_page.click_continue_button
    expect("Total: $62.62").to eq final_page.total_amount.text
    finish_page = final_page.click_finish
    expect(finish_page.verify_order_complete_message.text).to eq "THANK YOU FOR YOUR ORDER"
    finish_page.click_humburger_icon
    @wait.until{ finish_page.reset_app_link.displayed? }
    sleep 2
    finish_page.logout
  end
end