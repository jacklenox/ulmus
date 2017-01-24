# Ulmus

A proof of concept WordPress theme written in Elm.

## Setup

In order to compile the Elm source code, you need the `elm` package from npm. The easiest way to install npm is to install Node. You can follow instructions on how to do that [here](https://nodejs.org/).

Once you have npm, install the `elm` package with:

```
npm install elm -g
```

Once you've done that, clone this repo to your system. From within this directory, you run:

```
elm package install
```

You can then compile the file to JavaScript with the following command:

```
elm-make src/Ulmus.elm --output ulmus.js
```

Once that's done, this will work like a normal theme. You just need to drag the whole directory into the `wp-content/themes` directory of a WordPress site, and activate the theme via `wp-admin`.
