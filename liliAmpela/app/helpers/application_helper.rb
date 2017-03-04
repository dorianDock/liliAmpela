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
    return '' if current_page?('/')

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

end
