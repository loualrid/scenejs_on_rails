# Scenejs On Rails
## Currently Running SceneJS V3.2

First off, if you dont know about [Scenejs](http://scenejs.org/), go take a look so you can appreciate what this gem does.

For the informed, this gem allows you to utilize scenejs and all of its plugin glory within rails WITHOUT having to load all
of its javascript files into your asset pipeline. If you are fine with scenejs.org hosting your files AND not being able to
easily create and utilize your own scenejs plugins, this gem is not for you. I repeat, if you don't plan on using self-made
plugins, just pull from scenejs.org directly.

Advantages:

* You will be hosting all the scenejs plugins through this gem and can not worry about scenejs.org being unreachable
* All plugins will be static
* You can create plugins in vendor/assets/javascripts/scenejs_plugins and link to them easily
* Images (gif, png, jpg) included in your plugins will be loaded as well and dont have to be embedded in asset pipeline
* Your filesystem will NOT be exposed by this gem

Disadvantages:
* You will be hosting an additional 32MB
* The scenejs.js file is ~580 kb

## Installation

Add this line to your application's Gemfile:

    gem 'scenejs_on_rails'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install scenejs_on_rails

Then add this to your routes.rb
    
    get '/scenejs/get_scenejs_data'

And finally add this to your application.js

    //= require scenejs

## Usage Example
In a script tag:

```javascript
  // Demo of the "cameras/orbit" and "objects/space/planets/earth" custom node types

  // Create scene
  var scene = SceneJS.createScene({
    nodes: [

      {
        type:"cameras/orbit",
        id : "camera",
        yaw:340,
        pitch:-20,
        zoom:7,
        zoomSensitivity:1.0,
        eye:{ y:0 },
        look:{ y:0 },
     
        nodes:[
          // Custom lighting to simulate the Sun
          {
            type:"lights",
            lights:[
              {
                mode:"dir",
                color:{ r:1.0, g:1.0, b:1.0 },
                diffuse:true,
                specular:true,
                dir:{ x:-0.5, y:-0.5, z:-0.75 }
              }
            ],

            nodes:[
              // Planet Earth,
              // implemented by plugin at http://scenejs.org/api/latest/plugins/node/objects/space/planets/earth.js
              {
                type:"objects/space/planets/earth"
              }
            ]
          }
        ]
      }
    ]
  });
```

This will render the SceneJS team's awesome earth graphic with no additional work on your part. If it doesnt, there is a problem
and you should create an issue about it.

## Detailed Information

Simply by declaring 

```javascript
  type: 'myplugin/path'
```
for a node, scenejs will send a request to your app for the plugin data it needs. If it is looking for javascripts that define the node,
it will recieve them as raw inline javascript and then mark that plugin as loaded. It looks in your /lib/assets/javascripts/scenejs_plugins folder
then /vendor/assets/javascripts/scenejs_plugins and finally in its own directory for the javascripts. If it doesn't find the data, the scenejs controller (within rails) raises a 
ActionController::RoutingError error.

It is an extremely good idea to have your node type data be based on your filesystem for your plugins. For example, if you are creating a plugin like

```javascript
  SceneJS.Types.addType("objects/space/planets/awesome_sun", {
    
    init:function (params) {

      var texturePath = "node/objects/space/planets/awesome_sun/";
```
Then your plugin should have its main js file be at Rails.root / lib / assets / javascripts / scenejs_plugins / node / objects / space / planets / awesome_sun.js

For your images, they should be in Rails.root / lib / assets / javascripts / scenejs_plugins / node / objects / space / planets / awesome_sun (with awesome_sun being
a directory) and then linked like so:

```javascript
  type: "texture",
  layers: [
    {
      src: texturePath + 'mysunimg.png'
    }
  ],
```
This will tell scenejs to grab the image data from scenejs controller's get_plugin_data url. The image data is served via send_data(location_of_image_file).

### NOTE!

If you plan on using images / whatever as textures within an init script (something that defines the base scene like the earth example), you can use your asset pipeline.

```javascript
  type: "texture",
  layers: [
    {
      src: "<%= asset_path 'mytexture.jpg' %>"
    }
  ],
```
You can also setup a path to grab these from if you dont want too many images in your pipeline (advanced graphics may use very large images). For example you could store
 your images in Rails.root / lib / assets / javascripts / scenejs_plugins / generic_images and then link to your images like this:

```javascript
  type: "texture",
  layers: [
    {
      src: "generic_images/mytexture.jpg"
    }
  ],

```
It is always better to store images used in the init script in the pipeline! You dont have a choice for plugins however. It is highly recommended to write all your objects
as plugins to better utilize DRY which allows you to use the least amount of code possible to render your scene from the init script.

## Vulnerability via looking for the files?

For the security minded, the scenejs controller figures out where to find its files from params[:file] then searching in three possible locations for that data.
As the location parser uses File.join() it was possible for an attacker to use '..' to dig up files they are not meant to find. This has been prevented through
statements that scan the params[:file] string. If this occurs, the controller will raise a ActionController::UnpermittedParameters error. This will never occur
normally.

## So why did you need to modify the original source?

```javascript
  SceneJS.setConfigs({
   pluginPath: (((location.protocol.length === 0) ? 'http://' : location.protocol + '//') + location.host + '/scenejs/get_scenejs_data.js?file=')
  });
```

Is the only edit made to scenejs.js source. Everything else happens naturally through the parsing of the files. Kudos to the SceneJS team on this by the way,
Louis Alridge had originally written some hacks into the source to get things to work just right, but with 3.2 simply adding that is all thats needed.



## SceneJS Libraries

Certain libraries like stats.min can be included through the asset pipeline in your application.js like this:

    //= require scenejs_lib/stats.min

Anything you'd normally find in /examples/libs in the scenejs repo can be found there... Extras can be found with

    //= require scenejs_extras/gui

### NOTE!

You may run into some libraries that don't work because they dont call on the SceneJS pluginPath variable and instead try finding their dependencies
through the filesystem (like the standard physics engine). Theres nothing you can really do about this unless you want to get your hands dirty with some js.
If you run into these, submit an issue (to both this gem and to the scenejs repo). You can 'fix' this by putting the files causing the problem in YOUR vendor
directory and fixing them there at the very least. 