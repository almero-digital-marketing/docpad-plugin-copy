# Copy Plugin for DocPad

Copies all files in the raw directory to out. Useful for large files that cause out of memory error when placed in files directory.

## Install

```
npm install --save docpad-plugin-copy
```

## Usage

In most cases this plugin is drop in replacement of `raw` plugin. However there are some scenarios where you should use `raw` plugin.

### Extra features and improvements

This plugin does not support custom commands as `raw` plugin does. This plugin does not use `ncp` neither. If you need any of those options please use `raw`.

What this plugin is doing differently is just the way it copies the files from `raw` folder. While `raw` plugin copies each file on every generation and regeneration which might take a lot of time, this plugin copies only files that have been changed from previous regeneration and this can easily speed up the generation process from minutes to seconds.

This plugin is a must for almost any docpad site except very small ones that does not have many files. If you are used to `raw` plugin this one will speed docpad even more.

### Basic Usage

If no configuration is specified it will copy `raw` folder in `out` so its pretty much the same as [Raw Plugin](https://github.com/docpad/docpad-plugin-raw)

### Custom Configuration

Set as many sources as you want. Path should be relative to the `src` directory. If you want you can specify destination folder with `out` option, it is relative to `out` directory.

```
plugins:
    copy:
        raw:
            src: 'raw'
        app:
            src: 'app'
        system:
            src: 'sys'
            out: 'admin/cpanel'
```

### Extra Optimization

If you want to speed up your DocPad generation and regeneration you should use `raw` folder for any file that does not change very often. This is because every change of a file in `src` foder triggers full regeneration except when the file is marked as standalone. And it much easier to make files in `static` folder treated as standalone. You can easily move files and folders from `static` to `raw` and vice versa without any changes to the layouts and documents.

Best approach is to put your vendor scripts in `raw` folder as well as large data files, images and fonts, because they don't change often. Your script files should better stay in `static` folder. To mark your `static` files as standalone you have to add this configuration do `docpad.coffee`

```
events:
    extendCollections: (opts) ->
        @docpad.getCollection('files').on('add', (document) ->
            document.setMetaDefaults(standalone:true))    
```

It's not bad idea to mark all your scripts and styles as standalone also. This is the configuration for the best performance combined with the usage of this plugin.

```
events:
    extendCollections: (opts) ->
        @docpad.getCollection('files').on('add', (document) ->
            document.setMetaDefaults(standalone:true))    
        @docpad.getCollection('stylesheet').on('add', (document) ->
            document.setMetaDefaults(standalone:true))           
        @docpad.getCollection('scripts').on('add', (document) ->
            document.setMetaDefaults(standalone:true))    
```