# Middleman-JSPM

`middleman-jspm` adds support for using [JSPM](http://jspm.io) in [Middleman](http://middlemanapp.com).

## Installation

To get started using Middleman, install `middleman` and make a project:

```
gem install middleman
middleman init PROJECT
```

Once that's done, add `gem "middleman-jspm", :git => "https://github.com/oncomouse/middleman-jspm.git"` to your `Gemfile` and run `bundle update`

## Configuring

```ruby
activate :jspm
```

The bundle defaults to `source/javascripts/jspm_packages` for installing packages. If you want to use something else, you can activate with:

```ruby
activate :jspm, :jspm_dir => "source/js/jspm_packages"
```

### Optional

As `middleman-jspm` manages your javascript for you, you should consider adding `ignore "javascripts/*"` to your `configure :build` section of `config.rb`. Doing so will prevent the site from building your javascript files unnecessarily.

## Setting Up Node

This project relies on [Node.js](http://nodejs.org) to run JSPM. You will need to install it before you can use this gem.

After you have installed node, run:

```
npm install jspm
middleman jspm init
```

JSPM will ask if you want it to configure `config.js`. Say yes.

You can now install packages by running `middleman jspm install <packagename>` according to JSPM's settings.
	
## Defining Modules	

`middleman-jspm` will only compile files defined in its `module.json` file at build time. This file can either be stored in the same directory as `config.rb` or included as a sprockets asset in the default javascript directory. The ability to use sprockets means you can build the JSON file with ERuby if you want to dynamically determine which modules to compile.

`modules.json` defines an array of module objects defined on the following format (where all properties except `name` are optional):

```json
[
	{
		"name": "main",
		"include": [
			"jquery"
		],
		"exclude": [
			"react"
		],
		"self-executing": true
	}
]
```

The above `modules.json` file will build a module named `main` that, in addition to dependencies defined in the file, will include jQuery but will not include React. The module will also compile as self-executing (which means JSPM will not add `system.js` and `config.js`) to the resulting file. 

## Building JSPM Pages

This is a minimal working example, that includes the module in `main.js` and all of it's dependencies:

```erb
<!doctype html>
<html>
	<head>
		<meta charset='utf-8'>
		<!-- Always force latest IE rendering engine or request Chrome Frame -->
		<meta content='IE=edge,chrome=1' http-equiv='X-UA-Compatible'>
		<title><%=current_page.data.title || "The Middleman"%></title>
		<%= jspm_include_environment %>
	</head>
	<body>
		<div id="app"
		<%= jspm_include_module("main") %>
	</body>
</html>
```

`jspm_include_environment` includes the SystemJS and configuration files needed by JSPM and will include the correct files for both build and development environments. If all modules defined in `modules.json` are self-executing, this command returns nothing.

`jspm_include_module(<name>)` includes a module into the present document and will include the correct files, in the correct manner, for both build and development environments.
	
## Other Helpers

Finally, there is also a helper called `jspm_path(<name>, [<source>])` that can give you the path of a file installed with JSPM. For instance, to look the path of jquery that was installed from github, you would use `jspm_path("components/jquery", "github")` to get the path of the jquery used by JSPM. The helper works the same way for NPM packages.
	
## Additional Help

An example setup is posted at http://github.com/oncomouse/middleman-jspm-example