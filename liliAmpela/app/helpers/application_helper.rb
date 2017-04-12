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

    link_to text.html_safe, spree.cart_path, class: "cart-info item specificFont forcedBlack"
  end

  def custom_product_breadcrumbs(separator = '&nbsp;&raquo;&nbsp;', breadcrumb_class = 'inline')
    return '' if current_page?('/products')

    crumbs = [[Spree.t(:home), spree.root_path]]
    crumbs << [Spree.t(:products), products_path]

    items = crumbs.each_with_index.collect do |crumb, i|
      link_to(crumb.last, itemprop: 'item') do
        content_tag(:span, crumb.first, itemprop: 'name') + tag('meta', { itemprop: 'position', content: (i+1).to_s }, false, false)
      end + (crumb == crumbs.last ? '' : content_tag(:i,'', class: 'right angle icon divider'))
    end

    content_tag(:div, raw(items.map(&:mb_chars).join), id: 'breadcrumbs', class: 'ui breadcrumb')
  end

  def custom_taxon_breadcrumbs(taxon, separator = '&nbsp;&raquo;&nbsp;', breadcrumb_class = 'inline')
    return '' if current_page?('/') || current_page?('/home/story') || current_page?('/home/contact') || current_page?('/home/team')

    crumbs = [[Spree.t(:home), spree.root_path]]

    if taxon
      crumbs << [Spree.t(:products), products_path]
      crumbs += taxon.ancestors.collect { |a| [a.name, spree.nested_taxons_path(a.permalink)] } unless taxon.ancestors.empty?
      crumbs << [taxon.name, spree.nested_taxons_path(taxon.permalink)]
    else
      crumbs << [Spree.t(:products), products_path]
    end

    separator = raw(separator)

    items = crumbs.each_with_index.collect do |crumb, i|
        link_to(crumb.last, itemprop: 'item') do
          content_tag(:span, crumb.first, itemprop: 'name') + tag('meta', { itemprop: 'position', content: (i+1).to_s }, false, false)
        end + (crumb == crumbs.last ? '' : content_tag(:i,'', class: 'right angle icon divider'))
    end

    content_tag(:div, raw(items.map(&:mb_chars).join), id: 'breadcrumbs', class: 'ui breadcrumb')
  end

  def custom_flash_messages(opts = {})
    ignore_types = ["order_completed"].concat(Array(opts[:ignore_types]).map(&:to_s) || [])

    flash.each do |msg_type, text|
      unless ignore_types.include?(msg_type)
        concat(content_tag(:div, text, class: "flash #{msg_type}"))
      end
    end
    nil
  end

  def custom_taxons_tree(root_taxon, current_taxon, max_level = 1)
    return '' if max_level < 1 || root_taxon.children.empty?
    content_tag :ul, class: 'ui list taxons-list' do
      taxons = root_taxon.children.map do |taxon|
        css_class = (current_taxon && current_taxon.self_and_ancestors.include?(taxon)) ? 'current' : nil
        content_tag :li, class: 'item '+css_class.to_s do
          link_to(taxon.name, seo_url(taxon)) +
              taxons_tree(taxon, current_taxon, max_level - 1)
        end
      end
      safe_join(taxons, "\n")
    end
  end

  def meta_data
    object = instance_variable_get('@' + controller_name.singularize)
    meta = {}

    if object.is_a? ActiveRecord::Base
      meta[:keywords] = object.meta_keywords if object[:meta_keywords].present?
      meta[:description] = object.meta_description if object[:meta_description].present?
    end

    if meta[:description].blank? && object.is_a?(Spree::Product)
      meta[:description] = truncate(strip_tags(object.description), length: 160, separator: ' ')
    end


    meta
  end

  def meta_data_tags
    meta_data.map do |name, content|
      tag('meta', name: name, content: content)
    end.join("\n")
  end

  def custom_checkout_states
    @order.checkout_steps
  end

  def custom_checkout_progress
    states = custom_checkout_states
    items = states.map do |state|
      text = Spree.t("order_state.#{state}").titleize

      css_classes = []
      current_index = states.index(@order.state)
      state_index = states.index(state)

      if state_index < current_index
        css_classes << 'completed'
        text = link_to text, checkout_state_path(state)
      end

      css_classes << 'next' if state_index == current_index + 1
      css_classes << 'current' if state == @order.state
      css_classes << 'first' if state_index == 0
      css_classes << 'last' if state_index == states.length - 1
      # It'd be nice to have separate classes but combining them with a dash helps out for IE6 which only sees the last class
      class_state_for_step = ''
      if state == @order.state
        class_state_for_step = 'active'
      end

      css_class_for_icon = ''
      if state == 'address'
        css_class_for_icon = 'user icon'
      end
      if state == 'delivery'
        css_class_for_icon = 'truck icon'
      end
      if state == 'payment'
        css_class_for_icon = 'payment icon'
      end
      if state == 'confirm'
        css_class_for_icon = 'info icon'
      end
      icon_to_use = content_tag('i','', class: css_class_for_icon)
      title_to_use = content_tag('div', text, class: 'title')
      content_to_use = icon_to_use+content_tag('div', title_to_use, class: 'content')
      #content_tag('div', content_tag('span', text), class: 'step '+css_classes.join('-'))
      content_tag('div', content_to_use, class: 'step '+class_state_for_step+' '+css_classes.join('-'))
    end

    content_tag('div', raw(items.join("\n")), class: 'ui steps progress-steps', id: "checkout-step-#{@order.state}")
  end

end
