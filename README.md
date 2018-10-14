# Fig
[![Build Status](https://magnum.travis-ci.com/emcien/fig.svg?token=KdrVLZNkgJFW8ixyH9nh)](https://magnum.travis-ci.com/emcien/fig)

Fig is a library for standardizing the configuration of a ruby application. This
was specifically written with Rails in mind, but is not limited to that
framework. The intent is to ensure that all configuration for an application is
loaded from the environment, per 12 factor design. It is a wrapper around the
popular [Figaro](https://github.com/laserlemon/figaro) configuration library.

The possible values that can be set via Fig are configured in two files: a
paramaters file and a defaults file (see the files in `spec/data` for an
example). The values in the parameters file specify all of the possible fields
that can be configured and their associated types. The values in the defaults
file are a subset of the fields in the parameters file, specifying default
values for configuration fields if they are not set in the environment. This
means that fields in the defaults file are optional, while fields not included
are required to be set by the environment.

When the application is loading, you instantiate your configuration by calling:
```
# Assign to a global
CONFIG = Fig::Config.new('params.yml', 'defaults.yml', 'application.yml', 'MYAPP')
```

The final argument is a prefix with which all environment variable are expected
to be prefixed.

Before the rest of your app makes use of the configuration, it should be locked
(though it may make sense to modify it in flight during initialization before
locking it): `CONFIG.lock`
