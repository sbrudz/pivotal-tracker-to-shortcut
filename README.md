# pivotal-tracker-to-shortcut
Ruby script to migrate stories from Pivotal Tracker to Shortcut.  For any story marked with the "shortcut" label, it will copy the name, description, estimate, comments, labels, and tasks. 

Epics and File Attachments are currently not being transferred.  It's possible to support epics but we decided it wasn't worth the effort since we only use them to group stories.  The epic labels are getting transferred over, which accomplishes the grouping.  File Attachments would have been very nice to have, but there does not seem to be a way to use the Shortcut API to upload files.  We also found that the links that the Pivotal API provides for several types of attachments, such as Video and PDF files, do not work.  Image attachment links work fine, though. 

### Mapping States

In order to map Pivotal states to Shortcut states, you must define a JSON string in the `WORKFLOW_MAPPING_JSON` environment variable that provides the mapping:

```shell
WORKFLOW_MAPPING_JSON="[{\"pivotal_state\":\"unstarted\",\"shortcut_state\":\"Draft\"},{\"pivotal_state\":\"unscheduled\",\"shortcut_state\":\"On Ice\"},]"
```

Note that the JSON must be encoded as a string, so all `"` symbols must be escaped with a backslash `\"`.

## Using the script

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
