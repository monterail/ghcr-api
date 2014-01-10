## GitHub code review API for [chrome extension](https://github.com/monterail/ghcr)

### Installation
```
git clone git@github.com:monterail/ghcr-web.git
cd ghcr-web
bin/setup
```
Create [Heroku application](https://github.com/monterail/ghcr-web#Heroku) (optional)

Create [GitHub OAuth application](https://github.com/settings/applications/new)

- Application name: 'My GHCR Instance'
- Homepage URL: 'http://ghcr-web.dev' or 'http://my-heroku-app.com'
- Authorization callback URL: 'YOUR_HOMEPAGE_URL/api/v1/authorize/callback'

Edit `config/application.yml`

```
URL: "YOUR_HOMEPAGE_URL"  # required
GITHUB_CLIENT_ID: ""      # required
GITHUB_CLIENT_SECRET: ""  # required
RAVEN_DSN: ""             # optional
HIPCHAT_TOKEN: ""         # optional
HIPCHAT_ROOM: ""          # optional
```

### Heroku

```
heroku create
git push heroku master
rake figaro:heroku
```

Setup YOUR_HOMEPAGE_URL in [chrome extension](https://github.com/monterail/ghcr)

### Authentication

- `/api/v1/authorize?redirect_uri=http://github.com/foo/bar` authorizes app, generates access token and redirects to redirect_uri with access_token in fragment
- `/api/v1/commits?access_token=xyz` authorizes as user connected with access_token
