Spree.ready ($) ->
  Spree.addImageHandlers = ->
    thumbnails = ($ '#product-images div.thumbnails')
    ($ '#main-image').data 'selectedThumb', ($ '#main-image img').attr('src')
    thumbnails.find('div').eq(0).addClass 'selected' unless thumbnails.find('div.selected').length
    thumbnails.find('a').on 'click', (event) ->
      ($ '#main-image').data 'selectedThumb', ($ event.currentTarget).attr('href')
      ($ '#main-image').data 'selectedThumbId', ($ event.currentTarget).parent().attr('id')
      thumbnails.find('div').removeClass 'selected'
      ($ event.currentTarget).parent('div').addClass 'selected'
      false

    thumbnails.find('div').on 'mouseenter', (event) ->
      ($ '#main-image img').attr 'src', ($ event.currentTarget).find('a').attr('href')

    thumbnails.find('div').on 'mouseleave', (event) ->
      ($ '#main-image img').attr 'src', ($ '#main-image').data('selectedThumb')

  Spree.showVariantImages = (variantId) ->
    ($ 'div.vtmb').hide()
    ($ 'div.tmb-' + variantId).show()
    currentThumb = ($ '#' + ($ '#main-image').data('selectedThumbId'))
    if not currentThumb.hasClass('vtmb-' + variantId)
      thumb = ($ ($ '#product-images div.thumbnails div:visible.vtmb').eq(0))
      thumb = ($ ($ '#product-images div.thumbnails div:visible').eq(0)) unless thumb.length > 0
      newImg = thumb.find('a').attr('href')
      ($ '#product-images div.thumbnails div').removeClass 'selected'
      thumb.addClass 'selected'
      ($ '#main-image img').attr 'src', newImg
      ($ '#main-image').data 'selectedThumb', newImg
      ($ '#main-image').data 'selectedThumbId', thumb.attr('id')

  Spree.updateVariantPrice = (variant) ->
    variantPrice = variant.data('price')
    ($ '.price.selling').text(variantPrice) if variantPrice
  radios = ($ '#product-variants input[type="radio"]')

  if radios.length > 0
    selectedRadio = ($ '#product-variants input[type="radio"][checked="checked"]')
    Spree.showVariantImages selectedRadio.attr('value')
    Spree.updateVariantPrice selectedRadio

  Spree.addImageHandlers()

  radios.click (event) ->
    Spree.showVariantImages @value
    Spree.updateVariantPrice ($ this)
