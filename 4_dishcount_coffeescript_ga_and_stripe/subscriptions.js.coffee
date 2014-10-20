# send ecommerce data to Google Analytics
# the GON RoR gem is used to pass data from the application server to the client as a global javascript object
ecommerce = () ->

  ga 'ecommerce:addTransaction', {
    'id': gon.transaction_id,         # Transaction ID. Required.
    'affiliation': '',                # Affiliation or store name.
    'revenue': gon.total,             # Grand Total.
    'shipping': '',                   # Shipping.
    'tax': ''                         # Tax.
  }

  ga 'ecommerce:addItem', {
    'id': gon.transaction_id,         # Transaction ID. Required.
    'name': gon.product_name,         # Product name. Required.
    'sku': gon.sku,                   # SKU/code.
    'category': '',                   # Category or variation.
    'price': gon.total,               # Unit price.
    'quantity': '1'                   # Quantity.
  }

  ga 'ecommerce:send'

# Stripe is used to process credit card payments
# callback from Stripe server
stripeResponseHandler = (status, response) ->
  if $('#new_subscription').length
    # the user is signing up for the first time
    $form = $('#new_subscription')
  else 
    # the user is editing their card
    $form = $('#edit_card')

  # check for an error and display the appropriate message on the form
  if response.error
    errorMsg = "Ha ocurrido un error en el proceso de pago"
    switch response.error.code
      when "incorrect_number" then errorMsg = "El número de tarjeta no es correcto"
      when "invalid_number" then errorMsg =  "El número de tarjeta no es válido"  
      when "invalid_expiry_month" then errorMsg = "El més de caducidad no es válido"
      when "invalid_expiry_year" then errorMsg = "El año de caducidad no es válido"
      when "invalid_cvc" then errorMsg = "El código de seguridad no es válido"
      when "incorrect_cvc" then errorMsg = "El código de seguridad no es correcto"
      when "card_declined" then errorMsg = "La tarjeta ha sido rechazado"
      when "processing_error" then errorMsg = "Ha ocurrido un error en el proceso de pago"

    $form.find('.payment-errors').text(errorMsg)
    $('#credit_card_form_submit_button').removeAttr("disabled")
  # if there is no error, add the Stripe token to the form and submit the form
  else
    token = response.id
    $form.append($('<input type="hidden" name="stripe_cus_token" />').val(token))
    $form.get(0).submit()

ready = ->
  # if the page requires access to the Stripe API, set the public key
  if (Stripe?)
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));

  $('#new_subscription').submit ->
    $form = $(this)
    # Disable the submit button to prevent repeated clicks
    $('#credit_card_form_submit_button').attr('disabled', 'disabled')
    if gon.submit_form
      # if the user doesn't have a Stripe customer token, submit the form to get one
      $form.get(0).submit()
    else
      # if the user already has a Stripe customer token, create a single-use token to pass
      # payment details securely
      Stripe.card.createToken($form, stripeResponseHandler);
    # perform google analytics ecommerce tracking
    ecommerce()
    # Prevent the form from submitting with the default action
    return false

  # submit the edit card form
  $('#edit_card').submit ->
    $form = $(this) 
    # Disable the submit button to prevent repeated clicks
    $('#credit_card_form_submit_button').attr('disabled', 'disabled')
    Stripe.card.createToken($form, stripeResponseHandler)
    # Prevent the form from submitting with the default action
    return false

  # show the cvv help area when clicked
  $('#cvv_help').click ->
    $('#cvv_help_display').show()
    $('#cvv_help').hide()

$(document).ready(ready)
$(document).on('page:load', ready)