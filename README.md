# cucumber_csteps

  Write [Cucumber](https://github.com/cucumber/cucumber) step definitions in C (or C++)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cucumber_csteps'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cucumber_csteps

## Usage

Write your step definitions in this form

```c
#include &lt;csteps.h&gt;

// You need a uniq STEP_PREFIX per file
#define STEP_PREFIX atm_steps

GIVEN("^the account balance is (\d+)$") (int balance) {
  // setup account
}

WHEN("^the account holder requests (\d+)$") (int amount) {
  // make withdraval
}

THEN("^the account balance should be (\d+)$") (int balance) {
  // assert correct behaviuor
}
```

Place your step definition files in features/step_definitions

Compile the code. The include path of &lt;csteps.h&gt; can be found by running

    $ csteps-include-path

Link your production code and step_definitions into a shared library.

Put this in features/support/env.rb (replace LIBNAME with the name of your library)

```ruby
require 'cucumber_csteps'
CucumberCsteps.load_steps('LIBNAME', 'libLIBNAME.so', ["features/**/*.c"])
```

Run cucumber as you would normally:

    $ cucumber

## Example

For a full working example, checkout [https://github.com/fooheads/cucumber_csteps-atm](https://github.com/fooheads/cucumber_csteps-atm)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/cucumber_csteps/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

(The MIT License)

Copyright (c) 2015 Fooheads AB <hello@fooheads.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


