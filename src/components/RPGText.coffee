defaults =
	speed: 50
	caretPeriod: 400

class RPGText
	constructor: (@commandTrigger = '`', speed = defaults.speed, caretPeriod = defaults.caretPeriod) ->
		# @commandTrigger: the character that the parser looks for in order to
		# trigger commands
		# @speed: the number of milliseconds that must elapse before a character is
		# processed

		@messages = [] # messages shown in chatbox/on screen
		@queue = "" # text/command queue

		@reset()
		@speed = speed
		@caretPeriod = caretPeriod

		@isUpdating = false # true when the console is printing characters to the screen
		@caret = true # true when the caret should be drawn
			# the caret should also be drawn anytime @isUpdating is true 

		@callbacks = {}

		@commands =
			sleep: (ms) -> @sleeping = ms
			speed: (ms) -> @speed = ms
			reset: @reset
			style: (css) ->
				@getCurrentMessage().text += '<span style="'+css+'">'
				@stylesDepth++
			endstyle: (args) ->
				if @stylesDepth > 0
					@getCurrentMessage().text += '</span>'
					@stylesDepth--
			endstyles: (args) ->
				while @stylesDepth > 0
					@commands.endstyle.apply this
			callback: (key, args) -> @callCallback key, args

	reset: ->
		for key of defaults
			this[key] = defaults[key]

		@caretTimer = 0
		@sleeping = 0
		@stylesDepth = 0
		@lastTimestamp = 0
		@charTimer = 0

	callCallback: (key, args) ->
		if not @callbacks[key]?
			console.log "Tried to call a text command callback '#{key}' but it didn't exist."
		else
			@callbacks[key] args

	addCallback: (key, callback) ->
		@callbacks[key] = callback

	queueLine: (str) ->
		@queueString "\n" + str

	queueString: (str) ->
		@queue += str

	getCurrentMessage: ->
		curMsg = @messages[@messages.length - 1]
		if curMsg?
			return curMsg
		else
			return @addNewMessage undefined, true
	
	addMessage: (text, justReturn = false) ->
		@addNewMessage
			text: text

	addNewMessage: (opts, justReturn = false) ->
		msg = {}
		if opts?
			msg = opts
		else
			msg = text: ''
		if not justReturn
			@messages.push msg
		return msg

	parseQueue: (numChars) ->
		# if we have a command and a newline in the next string to be pushed, we
		# need to handle whichever appears first
		output = @queue.substring 0, numChars

		# look for a command character in the substring we're about to push
		commandCharIndex = output.indexOf(@commandTrigger)

		# look for a command character in the substring we're about to push
		newlineCharIndex = output.indexOf("\n")

		if commandCharIndex > -1 and (newlineCharIndex == -1 or newlineCharIndex > commandCharIndex)
			# console.log "COMMANDCHAR IN OUTPUT", JSON.stringify(@queue.substring(0, numChars)), numChars
			# if we find one, cut the number of characters down to the character
			# before the command character
			numChars = commandCharIndex + 1

			# extract the command and arguments
			re = /`([a-zA-Z0-9-_]*?)\{(.*?)\}/
			matches = @queue.match re
			if matches?
				if matches.length > 2
					# let's go ahead and print everything up to the command
					if commandCharIndex != 0
						outputUpToCommandChar = @queue.substring 0, commandCharIndex
						# console.log "outputUpToCommandChar", outputUpToCommandChar
						@queue = @queue.substring outputUpToCommandChar.length
						@getCurrentMessage().text += outputUpToCommandChar
					# handle commands with no arguments
					# console.log "Matches", matches
					if matches[2] == ''
						@commands[matches[1]].apply this, []
					else
						@commands[matches[1]].apply this, JSON.parse "[#{matches[2]}]"
					@queue = @queue.substring matches[0].length
					# console.log "QueueAfter", JSON.stringify(@queue)
				else
					console.log "Invalid command - skipping characters..."
					@queue = @queue.substring numChars
					# TODO: invalid command?

		else
			# append characters to the current message until we find a newline
			# character or a command character, at which point a new and empty message
			# will become the current message or the command will be run
			if commandCharIndex == -1 then commandCharIndex = Number.MAX_SAFE_INTEGER
			output = @queue.substring 0, Math.min(numChars, commandCharIndex)
			newlineCharIndex = output.indexOf("\n")
			if newlineCharIndex == -1
				@getCurrentMessage().text += output

			else
				# console.log "NEWLINE IN OUTPUT", JSON.stringify(output), numChars
				# output everything before the newline if applicable
				if newlineCharIndex != 0
					outputUpToNewline = output.substring 0, newlineCharIndex
					@getCurrentMessage().text += outputUpToNewline

				# if we have any styles at play, end them before starting the new
				# message
				if @messages.length > 0
					@commands.endstyles.apply this
				# add a new message (in place of printing the new line)
				@addNewMessage()
				outputAfterNewline = output.substring newlineCharIndex + 1
				@getCurrentMessage().text += outputAfterNewline
				# output everything after the newline to the new current message
				# console.log "UptoNL", (outputUpToNewline or ''), "AfterNL", outputAfterNewline

			# strip off what we just output
			@queue = @queue.substring output.length

	update: (timestamp) ->
		dt = timestamp - @lastTimestamp

		# control whether or not the caret should be drawn
		@isUpdating = @queue != '' and @sleeping <= 0
		if not @isUpdating
			@caretTimer += dt
			if @caretTimer >= @caretPeriod
				@caretTimer %= @caretPeriod
				@caret = !@caret
		else @caret = true

		# prevent huge timesteps when the component just starts
		if @lastTimestamp == 0 or @queue == ''
			@isUpdating = false
			@lastTimestamp = timestamp
			return
		@lastTimestamp = timestamp

		# don't do anything else if we're supposed to be sleeping
		if @sleeping > 0
			@sleeping -= dt
			return

		@charTimer += dt

		# if it's time to draw a character and we have characters to draw
		if @charTimer >= @speed and @queue != ''
			if @speed == 0
				# if we're rendering from the queue instantly, we just load the whole queue
				numChars = @queue.length
				@charTimer = 0
			else
				# figure out how many characters we render
				numChars = Math.min Math.floor(@charTimer / @speed), @queue.length
				# cut that much time out of our timer
				@charTimer -= numChars * @speed

			@parseQueue numChars

module.exports = RPGText
