# yarf

yarf means "Yet Another Rails Fixture"

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yarf', group: :development
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yarf

## Usage


At the point where you want to take the database snapshot, just do like this.

```
Yarf.record("snapshot_name1")
```

And you can load the snapshot from fixtures to database like this
```
Yarf.load_fixtures("000-snapshot_name1")
```

The number might be different from "000", please check the file name at spec/fixtures.



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec yarf` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/yarf.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

