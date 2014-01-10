## GitHub code review API for [chrome extension](https://github.com/monterail/ghcr)

### Development

You need to have setup pointing `http://ghcr-web.dev` to rails app.
```
bin/setup
```

### Authentication

`/api/v1/authorize?redirect_uri=http://github.com/foo/bar` authorizes app, generates access token and redirects to redirect_uri with access_token in fragment

`/api/v1/commits?access_token=xyz` authorizes as user connected with access_token
