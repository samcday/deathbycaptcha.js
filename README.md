# DeathByCaptcha.js `v0.0.3`

Node.js client library for the [DeathByCaptcha](http://www.deathbycaptcha.com) service.

## Installation

DeathByCaptcha.js is available in **npm**.

`npm install deathbycaptcha`

## Usage

Using the API goes a little something like this:

	DeathByCaptcha = require("deathbycaptcha");
	var dbc = new DeathByCaptcha("your_dbc_user", "your_dbc_pass");

	dbc.solve(fs.readFileSync("/your/captcha/file"), function(err, id, solution) {
		if(err) return console.error(err); // onoes!

		if(solution !== "moo") {
			// It was wrong!
			dbc.report(id, function(err) {
				if(err) return console.error(err); // ONOES!
			});
		}
	});

### Solve CAPTCHA

Send a CAPTCHA image file to DeathByCaptcha to solve.

**DeathByCaptcha.solve(captchaImage, callback);**

Callback accepts three parameters:

* *error*: if something went wrong sending or solving the CAPTCHA.
* *captchaId*: the ID of the CAPTCHA.
* *solution*: the solution to the CAPTCHA, as text.

*Example:*

	dbc.solve(fs.readFileSync("/your/captcha/file"), function(err, id, solution) {
		if(err) return console.error(err);
		console.log("CAPTCHA solution is", solution);
	});

### Get CAPTCHA

Gets a previously solved (or in progress) CAPTCHA by ID. If the CAPTCHA is still in progress the callback will wait for it.

**DeathByCaptcha.get(captchaId, callback);**

Callback takes 3 arguments:

* *error*: if something went wrong.
* *solution*: the solution for the CAPTCHA.
* *isCorrect*: true/false if the CAPTCHA is "correct" (hasn't beenr reported)

*Example:*

	dbc.get(12345, function(err, solution, isCorrect) {
		if(err) return console.error(err);
		// isComplete is false if the CAPTCHA has been reported (see below).
		console.log("Captcha solution is", solution);
		console.log("Is it correct?", isCorrect);
	});

### Report CAPTCHA

Use this if you have reason to believe DeathByCaptcha incorrectly solved your CAPTCHA image.

**DeathByCaptcha.report(captchaId, callback);**

Callback will be handed an error if something went wrong, else nothing will be passed.

*Example:*

	dbc.report(12345, function(err) {
		if(err) return console.error(err);
		console.log("CAPTCHA was reported successfully.")
		console.log("If it wasn't older than an hour, it should have refunded");
	});

### Get Balance

Loads balance stats for your account from DeathByCaptcha.

**DeathByCaptcha.balance(callback);**

Callback:

* *error*: if something went wrong
* *credits*: computed number of CAPTCHA solutions remaining.
* *balance*: balance in US cents.
* *rate*: cost per solution in US cents.

*Example:*

	dbc.balance(function(err, credits, balance, rate) {
		if(err) return console.error(err);
		console.log(credits + " credits remaining");
		console.log("($" + (balance / 100) + " @ " + rate + "c/solution");
	});

## Fineprint

deathbycaptcha.js is Copyright (c) 2012 Sam Day

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

See `COPYING` for more information.