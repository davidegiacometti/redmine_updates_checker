# Redmine Updates Checker
Updates checker for Redmine plugins.

## Supported versions
The plugin has been developed and tested on Redmine 4.0.x but should also works on previous versions. Any feedback will be appreciated.

## Installation
* Copy the plugin in #{RAILS_ROOT}/plugins
* Run bundle install
* Schedule the rake task

```
rake redmine:updates:check RAILS_ENV="production"
```

## License
Released under the MIT License.
