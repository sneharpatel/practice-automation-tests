require 'base_page'
require 'product_page'


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