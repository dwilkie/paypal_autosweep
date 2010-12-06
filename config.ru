require 'appengine-rack'
require 'dm-core'
require 'paypal_autosweep'
require 'appengine-apis/labs/taskqueue'

# Configure DataMapper to use the App Engine datastore
DataMapper.setup(:default, "appengine://auto")
DataMapper.repository.adapter.singular_naming_convention!

run PaypalAutosweep

