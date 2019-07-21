# HEIC + ImageMagick + Heroku Buildback + Ruby On Rails convert HEIC image before save + Papperclip

## Heroku Setup

By default Heroku Dyno having imageMagick-6.9.* which doesn't have support for HEIC|HEIF formats which is going to be used in IOS 11+

to get heroku to support HEIC we need to go with the buildpacks for Heroku Dyno.

Run the following in commandline


### Install Apt Buildpack

```
heroku buildpacks:add heroku-community/apt --index 1
```

and the create ```Aptfile``` in your Application directory.

add the following line in ```Aptfile``` and save it

```
libheif-dev
```


### Install Imagemagick 7.0.*


```
heroku buildpacks:add https://github.com/mkmms/heroku-buildpack-imagemagick --index 2
```


### Ruby Buildpack

```
heroku buildpacks:add https://github.com/heroku/heroku-buildpack-ruby --index 3
```



### Clear cache
Since the installation is cached you might want to clean it out due to config changes.

```
heroku plugins:install heroku-repo
heroku repo:purge_cache -app HEROKU_APP_NAME
```