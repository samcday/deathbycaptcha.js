{EventEmitter} = require "events"
request = require "request"
http = require "http"

class Captcha extends EventEmitter
	constructor: (dbc, @uri) ->
		@id = @uri.replace "#{dbc.endpoint}/captcha", ""

		pollStatus = =>
			request.get
				url: @uri
				headers:
					accept: "application/json"
			, (err, resp, body) =>
				return @emit "error", err if err?
				return @emit "error", new Error http.STATUS_CODES[resp.statusCode] unless resp.statusCode is 200
				body = JSON.parse body
				console.log body
				setTimeout pollStatus, 2000 unless body.text
				@emit "solved", body.text, body.is_correct if body.text
		process.nextTick pollStatus

module.exports = class DeathByCaptcha
	constructor: (@username, @password, @endpoint = "http://api.dbcapi.me/api") ->

	solve: (img, cb) ->
		request.post
			url: "#{@endpoint}/captcha"
			headers:
				"content-type" : "multipart/form-data"
			multipart: [
				{
					"content-disposition" : "form-data; name=\"captchafile\"; filename=\"captcha\""
					"content-type": "application/octet-stream"
					body: img
				}
				{
					"content-disposition" : "form-data; name=\"username\""
					body: @username
				}
				{
					"content-disposition" : "form-data; name=\"password\""
					body: @password
				}
			]
		, (err, resp, body) =>
			return cb new Error err if err?
			switch resp.statusCode
				when 303
					captcha = new Captcha @, resp.headers.location
					captcha.on "error", (err) -> cb err
					captcha.on "solved", (solution) -> cb null, solution
				when 403 then cb new Error "Invalid login / Insufficient credits."
				when 400 then cb new Error "Invalid image."
				when 503 then cb new Error "Temporarily unavailable."
				else cb new Error "Unexpected error."
	get: (id, cb) ->
		url = "#{@endpoint}/captcha/#{id}"
		captcha = new Captcha @, url
		captcha.on "error", (err) -> cb err
		captcha.on "solved", (solution, isCorrect) -> cb null, solution, isCorrect
	report: (id, cb) ->
		url = "#{@endpoint}/captcha/#{id}/report"
		request.post
			url: url
			form:
				username: @username
				password: @password
		, (err, resp, body) ->
			return cb err if err?
			return cb new Error http.STATUS_CODES[resp.statusCode] unless resp.statusCode is 200
			console.log body
			return cb null
