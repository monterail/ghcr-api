## GitHub Code Review API for [browser extension](https://github.com/monterail/ghcr)

### Requirements
  - ruby 1.9.2 or higher
  - git
  - redis
  - postgresql

### Installation
```
git clone git@github.com:monterail/ghcr-api.git
cd ghcr-api
bin/setup
```
Create [Heroku application](https://github.com/monterail/ghcr-api#Heroku) (optional)

Create [GitHub OAuth application](https://github.com/settings/applications/new)

- Application name: 'My GHCR Instance'
- Homepage URL: 'http://ghcr-api.dev' or 'http://my-heroku-app.com'
- Authorization callback URL: 'YOUR_HOMEPAGE_URL/api/v1/authorize/callback'

Edit `config/application.yml`

```
URL: YOUR_HOMEPAGE_URL                  # required
GITHUB_CLIENT_ID: ""                    # required
GITHUB_CLIENT_SECRET: ""                # required
GITHUB_ORG: ""                          # optional
REDIS_URL: "redis://127.0.0.1:6379/0"   # required
RAVEN_DSN: ""                           # optional
HIPCHAT_TOKEN: ""                       # optional
HIPCHAT_ROOM: ""                        # optional
```

### Heroku

```
heroku create
git push heroku master

heroku addons:add pgbackups
heroku addons:add redistogo

rake figaro:heroku
```

Setup YOUR_HOMEPAGE_URL in [browser extension](https://github.com/monterail/ghcr)

### Authentication

- `/api/v1/authorize?redirect_uri=http://github.com/foo/bar` authorizes app, generates access token and redirects to redirect_uri with access_token in fragment
- `/api/v1/commits?access_token=xyz` authorizes as user connected with access_token

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
