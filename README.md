# Yes we code

## Installation

```
bundle install --binstubs
echo 3000 > ~/.pow/ghcr-web
rake db:create db:migrate
rails server
```

## Authentication

`/api/v1/authorize?redirect_uri=http://github.com/foo/bar` authorizes app, generates access token and redirects to redirect_uri with access_token in fragment

`/api/v1/commits?access_token=xyz` authorizes as user connected with access_token
