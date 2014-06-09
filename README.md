sticker
=======

[![Build Status](https://travis-ci.org/pixl8/sticker.svg?branch=master)](https://travis-ci.org/pixl8/sticker)

Sticker is a per-request static asset inclusion tool for the Railo language. Its aim is to create a simple and consistent API for including JavaScript and CSS assets from multiple sources.

Documentation: [http://sticker.readthedocs.org/](http://sticker.readthedocs.org/en/latest/)

A quick example:

    // on application start (
    sticker = new sticker.Sticker();
    sticker.addBundle( rootDirectory="/assets", rootUrl="http://assets.mysite.com" )
           .addBundle( rootDirectory="/some/external/assets", rootUrl="/external/assets" );
           
    // per request
    sticker.include( "jquery" )
           .include( "core-js" )
           .include( "core-css" )
           .include( "jquery-ui-js" )
           .include( "jquery-ui-css" );
           
    #sticker.renderIncludes( 'css' )#
    #sticker.renderIncludes( 'js' )#
           
