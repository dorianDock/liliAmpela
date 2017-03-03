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


  def custom_taxon_breadcrumbs(taxon, separator = '&nbsp;&raquo;&nbsp;', breadcrumb_class = 'inline')
    return '' if current_page?('/') || taxon.nil?

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

end
