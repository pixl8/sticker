Sticker - Documentation
=======================

Sticker is a lightweight framework focused on managing CSS and JavaScript includes on a per-request basis.

Sticker in a nutshell
---------------------

Sticker helps you out by mapping your static resources to useful IDs. These IDs can then be referenced in your CFML code. So:

    :code:`/js/lib/2bf82ac6-sitecore.min.js` becomes **"sitecore"**

    **and**

    :code:`http://cdn.jquery.com/jquery-34.25.34.min.js` becomes **"jquery"**

A typical layout template that uses Sticker might look like this:

.. code-block:: cfm

        <cfset sticker.include( assetId="jquery" )
                      .include( assetId="bootstrapjs" )
                      .include( assetId="bootstrapcss" )
                      .include( assetId="sitecss" )
                      .include( assetId="sitejs" )
                      .include( assetId="specific-#pageType#", throwOnMissing=false )
                      .include( assetId="modernizr", group="headjs" ) />

        ...

        #sticker.renderIncludes( type="css" )#
        #sticker.renderIncludes( group="headjs" )#
    </head>
    <body>
        ...

        #sticker.renderIncludes( type="js" )#
    </body>

Configuration
-------------

Sticker uses :code:`StickerBundle.cfc` configuration files that are planted in the root of your static asset folders. You might, for example, have a folder structure like this:

.. code-block:: text

    /wwwroot
        /assets
            /js
            /css
            /images
            StickerBundle.cfc

And a :code:`StickerBundle.cfc` file that looks like this

.. code-block:: js

    component output=false {

        // all valid StickerBundle.cfc files must implement the 'configure()' method
        public void function configure( bundle ) output=false {
            // registering a single, remote asset
            bundle.addAsset( id="jquery", url="http://cdn.jquery.com/jquery-34.25.34.min.js" );

            // registering a single, local asset, note the wildcard filename map to
            // help with cachebusters in the filename.
            bundle.addAsset( id="sitecore", path="/js/*-sitecore.min.js" );

            // registering multiple assets at once, notice the idGenerator closure function
            // that can be used to format your asset IDs based on each matched
            // asset
            bundle.addAssets(
                  directory = "/css"
                , filter    = "*.min.css"
                , idGenerator = function( filePath ){
                     var id = Replace( filepath, "/", "-", "all" );
                     id = ReReplace( filePath, "\.min\.css$", "" );
                     id = ReReplace( filePath, "^-", "" );

                     return id;
                  }
            )
        }

    }

.. note::

    All paths in your StickerBundle.cfc file are relative to the parent directory of the StickerBundle.cfc


Installing Sticker
------------------

Sticker can be downloaded from Forgebox_. Once downloaded unpacked, create a mapping to the sticker directory called '/sticker' (not required if you unpacked sticker to the webroot).

Starting up Sticker
-------------------

The Sticker API is designed to be a Singleton and any instances you make should be cached in a permanent scope, e.g. the application scope. An example instantiation, using :code:`Application.cfc`, might look like this:

.. code-block:: js

    component output=false {
        //...
        function onApplicationStart() output=false {
            // 1. instantiate sticker with no arguments
            var sticker = new sticker.Sticker();

            // 2. add bundles, each bundle must have a StickerBundle.cfc file in it's root directory
            sticker.addBundle( rootDirectory="/assets", rootUrl="http://mywebsite-static.com/" )
                   .addBundle( rootDirectory="/myCompanyCoreAssetLib", rootUrl="/corelib/" );

            // 3. call load(), this will read all the bundles and merge their definitions
            sticker.load();

            application.sticker = sticker;
        }
    }


Specifying sort order and dependencies
--------------------------------------

By default, your assets will be rendered in alphabetical order. However, you can define sort orders and dependencies by modifying your :code:`StickerBundle.cfc`, using the :code:`before()`, :code:`after()`, :code:`dependsOn()` and :code:`dependents()` methods:

.. code-block:: js

    component output=false {

        public void function configure( bundle ) output=false {
           // etc...

           // the sitecore asset depends on jquery, all other assets depend on sitecore
           bundle.asset( "sitecore" ).dependsOn( "jquery" ).dependents( "*" );

           // the core css file should come before all others
           bundle.asset( "core-css" ).before( "*" );

           // the blog-template css file should come after a whole bunch of others
           bundle.asset( "blog-template-css" ).after( "common-css", "social-css" );

        }

    }

.. _Forgebox: http://www.coldbox.org/forgebox/view/sticker