# Valkyrie::ActiveRecord

A generic ActiveRecord based metadata backend for [Valkyrie](https://github.com/samvera-labs/valkyrie). Doesn't require JSON functions in the database backend so should work on nearly anything supported by ActiveRecord. Has been tested to work with SQLite and MariaDB (using mysql2 ActiveRecord adapter).

This largely follows the architecture of the Postgres adapter in Valkyrie and even uses the conversion functions defined in ```Valkyrie::Persistence::Postgres::ORMConverter::RDFMetadata```.

## Installation

In general, follow Valkyrie README. To enable the ActiveRecord adapter, add ```gem 'valkyrie-activerecord'``` to your Gemfile. You can then install the database migrations with ```rake valkyrie_active_record_engine:install:migrations```.

Configure the metadata adapter in Valkyrie by adding the following to your ```config/initializers/valkyrie.rb```:

```ruby
Valkyrie::MetadataAdapter.register(
  Valkyrie::Persistence::ActiveRecord::MetadataAdapter.new,
  :activerecord
)
```

You can then use ```:activerecord``` as a metadata adapter in `config/valkyrie.yml`

## Indexing

You will need to specify all of the fields that you are going to be using for searching beforehand, except for the these standard ones that are handled automatically: ```member_ids```, ```alternate_ids``` and ```internal_resource```. This includes any fields you intend to use with the ```find_inverse_references_by``` query method. To do this, pass a hash of fields to the ```MetadataAdapter``` initializer (typically done in ```config/initializers/valkyrie.rb```). For example:

```ruby
Valkyrie::Persistence::ActiveRecord::MetadataAdapter.new(indexed_fields: {
  member_of: { join: true }
})
```
If you specify ```join: true``` then the field is added to a separate table (```orm_indexed_fields```) and indexed there. Otherwise it is added to the resource table (```orm_resources```) directly and you will also need to create a db migration that adds the field there along with an index. Adding it in the table directly is probably faster but that method won't work with multi-valued fields. For nearly all cases, it is recommended to use ```join: true```.

At this moment, no other indexing options are supported.

## License

```Valkyrie::ActiveRecord``` is available under the [the Apache 2.0 license](LICENSE).