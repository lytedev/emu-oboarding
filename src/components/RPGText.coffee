class RPGText
	constructor: (@commandTrigger = '`', @speed = 20, caretPeriod = 400) ->
		# @commandTrigger: the character that the parser looks for in order to
		# trigger commands
		# @speed: the number of milliseconds that must elapse before a character is
		# processed

		@messages = [] # messages shown in chatbox/on screen
		@queue = "" # text/command queue
		@lastTimestamp = 0 # timestamp of last update
		@charTimer = 0 # time since last written to the message list

		@isUpdating = false # true when the console is printing characters to the screen
		@caret = true # true when the caret should be drawn
			# the caret should also be drawn anytime @isUpdating is true 

		@caretTimer = 0
		@caretPeriod = caretPeriod

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
	
	addNewMessage: (opts, justReturn = false) ->
		msg = {}
		if opts?
			msg = opts
		else
			msg = text: ''
		if not justReturn
			@messages.push msg
		return msg

	update: (timestamp) ->
		dt = timestamp - @lastTimestamp

		# control whether or not the caret should be drawn
		@isUpdating = @queue != ''
		if not @isUpdating
			@caretTimer += dt
			if @caretTimer >= @caretPeriod
				@caretTimer %= @caretPeriod
				@caret = !@caret

		# prevent huge timesteps when the component just starts
		if @lastTimestamp == 0 or @queue == ''
			@isUpdating = false
			@lastTimestamp = timestamp
			return
		@lastTimestamp = timestamp

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

			# look for a command character in the substring we're about to push
			commandCharIndex = @queue.substring(0, numChars).indexOf(@commandTrigger)
			if commandCharIndex > -1
				# if we find one, cut the number of characters down to the character
				# before the command character
				numChars = commandCharIndex + 1

				# extract the command and arguments
				re = /`([a-zA-Z0-9-_]*?)\((.*)\)/
				matches = @queue.match re
				if matches?
					console.log "MATCHES", commandCharIndex, numChars, matches, @queue
					if matches.length > 2
						null # TODO: trigger console commands

			else
				# no command character was found, so we just append characters to the
				# current message until we find a newline character, at which point
				# a new and empty message will become the current message
				output = @queue.substring 0, numChars
				newlineCharIndex = output.indexOf("\n")
				if newlineCharIndex == -1
					@getCurrentMessage().text += output

				else
					# output everything before the newline
					outputUpToNewline = output.substring 0, newlineCharIndex
					@getCurrentMessage().text += outputUpToNewline
					# add a new message (in place of printing the new line)
					@addNewMessage()
					# output everything after the newline to the new current message
					outputAfterNewline = output.substring newlineCharIndex + 1
					@getCurrentMessage().text += outputAfterNewline

				# strip off what we just output
				@queue = @queue.substring output.length
		
module.exports = RPGText
