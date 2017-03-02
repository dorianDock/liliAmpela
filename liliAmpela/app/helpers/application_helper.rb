module ApplicationHelper

  def custom_link_to_cart(text = nil)
    text = text ? h(text) : Spree.t(:cart)
    css_class = nil

    if simple_current_order.nil? || simple_current_order.item_count.zero?
      text = "#{text}: (#{Spree.t(:empty)})"
      #css_class = 'empty'
    else
      text = "#{text} (#{simple_current_order.item_count})"
      #css_class = 'full'
    end

    link_to text.html_safe, spree.cart_path, class: "cart-info item"
  end

end
