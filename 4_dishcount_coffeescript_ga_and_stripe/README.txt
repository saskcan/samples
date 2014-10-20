File:
'subscriptions.js.coffee'

This file contains some of the client-side javascript written in coffeescript which is used to:
i) provide ecommerce data for Google Analytics
ii) create monthly subscriptions for Dishcount using Stripe ("https://stripe.com") for credit card payment.

A Ruby on Rails gem 'gon' is used to pass server-side data to the javascript through a global 'gon' object which is used for ecommerce information as well as control of token creation for secure communication with the Stripe API. DOM manipulation is present in the form of a help area for the credit card 'cvv' code.