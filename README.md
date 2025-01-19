# Best Life

Persist any custom attributes against any model in a database.

## Guidelines
As we partner with many different companies, we often get requests to store some kind of custom data on
specific models. The data is different between partners, and the models they wish to store it against can
also change. Because these data points are specific to a single partner instance we do not want to
normalise these attributes into our database, i.e. we do not want to create a new database field for each
custom attribute. Nonetheless we want to provide a means for the users to store and query this data using
their relational database engine.

Given example models that partners might want to extend with customer attributes:
  - `Customer name:string phone_number:string`
  - `Battery capacity:int`

Your task is to implement a Concern (or any comparable pattern) that can be re-used in multiple models
(i.e. in the ones given above) to encapsulate the logic necessary to store custom attributes. For simplicity
those custom attributes can always be strings and should always be present. No interface component
needs to be developed, the configuration which Model allows for which custom attribute should live in the
database as it would be editable by users if we would add a configuration interface.

For testing imagine two partners: The first partner might only want to add `email:string` to their Customer
model, the second partner might want to add `hometown:string` to Customer as well as `make:string` and
`model:string` to Battery.

Bear in mind that the example schema mentioned above is really just for illustration. The challenge is to
implement a solution that can handle _any_ custom attributes stored against _any_ model. Also:
- There is no need to model the partners themselves as they all will use individual instances of your
  Rails application.
- Users need to be able to query the custom attribute using pure SQL, so serialising custom
  attributes into JSON is would be impractical.
- Please use SQLite as relational storage engine for your solution to spare us the need to spin up
  your favourite DBMS.
- Add a detailed README describing your solution.

Please implement your solution inside an empty rails app, and share your solution either as zip file or in a
publicly accessible repository, e.g. on GitHub for review.

## Getting Started
### Prerequisites
- Ruby 3.3.0
- Rails 8.0.0
- Bundler 2.5.20
### Setup
```shell
  ./bin/bundle install
  ./bin/rails db:prepare
```

## Walkthrough
### Database Design
#### CustomAttribute Model
Create a `CustomAttributes` model with fields `:key`, `:value`, with polymorphic reference for `:attributable`.
The `:key` and `:value` fields will be used to store the custom attributes key:value pair
Having a polymorphic association on the `CustomAttribute` model ensures the model can be associated with multiple models
The value can be retrieved using pure SQL by looking up the `CustomAttribute` table

#### CustomField Model
Granted the need to configure what custom attribute keys are allowed for a particular model, creating the CustomField model with fields
`:name`, `:associated_model` ensures that a record of allowed keys by model can be maintained

### Logic
#### Attributable Concern
Given that the solution should be re-usable across multiple models, having the custom attributes logic in a concern makes
it easy to mixin this logic in any class that requires the custom attributes functionality.

This concern defines the association to custom attributes in the _included_ block such that all models automatically have
that association

A custom_attribute can be set on the parent object by providing the key:value params to the method `set_custom_attribute(key:, value:)`
Before the custom attribute can be persisted
- A database query is made to check where a custom_attribute with that key for that object exists. If it exists, the custom_attribute is retrieved, if not a new one is instantiated
- The key is should be validated to ensure that it is not blank, its a valid key, and that custom fields for the parent object's class have been set.
- If the validation raises any errors, the custom attributes are not set and the object is returned, with clear error messages tied to the custom_attribute

A custom_attribute can be retrieved by calling `get_custom_attribute(key:)` on the object. If a match is found the value is returned, else it returns `nil`


### Assumptions
- A custom_attribute should not be created if it's key has not been added as a custom_field for the parent object
- A custom_attribute key and custom_field name fields are always a string data type, in lower case, and unique for every attributable object
- When creating a custom attribute, the method should return detailed errors within a custom attribute object
- When retrieving a custom attribute, return `nil` if a blank key is provided or no matching records are found in the database
- No UI, API endpoints or deployment features required

## Usage
Generate your model
  ```shell
  ./bin/rails g model Invoice reference:string
  ./bin/rails db:migrate
  ```

Include the `Atrributable` concern in your model
```ruby
class Invoice < ApplicationRecord
  include Attributable
end
```

Create custom fields for your model in the rails console
```shell
> ./bin/rails console
# Loading development environment (Rails 8.0.0)
```
```ruby
associated_model = 'Invoice' # => "Invoice"
name = 'generated_by' # => "generated_by"
CustomField.create!(name:, associated_model:) # => #<CustomField:0x000000014475f658 id: 1, name: "generated_by", associated_model: "invoice", created_at: "2024-11-20 12:26:02.766668000 +0000", updated_at: "2024-11-20 12:26:02.766668000 +0000">
```


Create a custom attribute for an invoice object with key `generated_by`
```ruby
invoice = Invoice.create!(reference: 'WR345-01') # => #<Invoice:0x0000000144f169c8 id: 1, reference: "WR345-01", created_at: "2024-11-20 12:28:30.577399000 +0000", updated_at: "2024-11-20 12:28:30.577399000 +0000">
invoice.set_custom_attribute(key: name, value: 'J. Doe') # => true
```

Retrieve a custom attribute for an invoice object with key `generated_by`
```ruby
invoice.get_custom_attribute(key: 'generated_by') # => "Finance Assistant"
```


## Run Tests
```shell
  ./bin/rails spec
```
