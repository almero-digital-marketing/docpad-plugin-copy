# Export Plugin
module.exports = (BasePlugin) ->
	# Define Plugin
	class Copy extends BasePlugin
		# Plugin name
		name: 'copy'

		# Writing all files has finished
		writeAfter: (opts,next) ->
			# Import
			eachr = require('eachr')
			pathUtil = require('path')

			# Prepare
			docpad = @docpad
			config = @getConfig()
			docpadConfig = @docpad.getConfig()

			outPath = pathUtil.normalize(docpadConfig.outPath)
			srcPath = pathUtil.normalize(docpadConfig.srcPath)

			if Object.keys(config).length is 0
				config.default = {}
				config.default.src = 'raw'

			TaskGroup = require('taskgroup').TaskGroup
			tasks = new TaskGroup({concurrency: 1}).done (err, results) ->
				if not err?
					docpad.log('info', 'Copying completed successfully')
				else
					docpad.log('error', 'Copying error ' + err)
				next?()

			eachr config, (target, key) ->
				tasks.addTask (complete) ->

					src = pathUtil.join(srcPath, target.src)
					out = outPath
					if target.out?
						out = pathUtil.join(outPath, target.out)

					# Use ncp settings if specified
					options = if target.options? and typeof target.options is 'object' then target.options else {}

					docpad.log("info", "Copying #{key} out: #{out}, src: #{src}")

					WINDOWS = /win32/.test(process.platform)
					OSX = /darwin/.test(process.platform)
					CYGWIN = /cygwin/.test(process.env.PATH)  # Cheap test!
					XCOPY = WINDOWS && !CYGWIN

					command = (
						if XCOPY
							['xcopy', '/eDy', src+'\\*', out+'\\']
						else
							if OSX
								['rsync', '-a', src + '/', out + '/' ]
							else
								['cp', '-Ruf', src+'/.', out ]								
					)

					safeps = require('safeps')
					safeps.spawn command, {output:false}, (err) ->
						return complete(err) if err
						docpad.log('debug', "Done copying #{key}")
						return complete()
			tasks.run()

