# pivotal-tracker-to-shortcut
Ruby script to migrate stories from Pivotal Tracker to Shortcut.  For any story marked with the "shortcut" label, it will copy the name, description, comments, labels, and tasks. Epics are currently not being transferred.

Prereqs:
* Ruby 2.7.X
* bundler

To set up:

```shell
bundle install
cp .env.example .env
```

Then set your environment variables in the `.env` file.

To run:

```shell
bundle exec ruby migrate.rb
```
