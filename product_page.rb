require 'base_page'

class ProductPage < BasePage
  def second_element
    @driver.find_element(:id, "item_1_title_link")
  end

  # def scroll_down_the_page
  #   element = @driver.find_element(:id, "item_0_title_link")
  #   element.location_once_scrolled_into_view
  #   my_element = @driver.find_element(:id, "item_2_title_link")
  #   my_element.click
  # end
  def click_add_to_cart
    @driver.find_element(:class, "add-to-cart-button").click
  end
  def select_two_products_and_add_to_cart
    first_item = @driver.find_elements(:id, "item_5_title_link")
    p first_item
  end

end