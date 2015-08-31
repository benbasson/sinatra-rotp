# The Sinatra One Time Password Service

A Sinatra REST API wrapping the [ROTP](https://github.com/mdp/rotp) library, to allow other applications to more easily plug in Time-Based One-Time Passwords (TOTP) for multi-factor authentication.

Generates a QR code for use with [Google Authenticator](https://github.com/google/google-authenticator) and verifies TOTP codes according to [RFC 6238](http://tools.ietf.org/html/rfc6238).

For production purposes, please only expose this service over HTTPS, or via local network as the shared secret is passed as a parameter to the service. If the shared secret is compromised, an attacker could easily generate the correct code and bypass this layer of security.

## Installation

Fork [this repository](https://github.com/benbasson/sinatra-rotp) and then run Bundler to pull the required dependencies:

~~~
bundle install
~~~

To start up:

~~~
rackup config.ru
~~~

## API Usage

### Generate a new base32 secret

~~~
/generate-secret
~~~

Creates a new base32 token for you to store as a secret key.

### Get QR Code

~~~
/get-otp-qr-code/:user/:secret/:issuer
~~~

Creates a QR code as a PNG containing: 

* The username provided
* The secret provided (string length must be a multiple of 8)
* (optionally) The key issuer, usually the system or company name

### Verify a code

~~~
/verify-otp-code/:secret/:code
~~~~

Verifies that a user-provided code matches the expected value for the shared secret. Returns a text value of "true" or "false".

### Get the current code

~~~
/current-otp-code/:secret
~~~

Get the current time-based code for a given secret.

### Check the service is running

~~~
/service-status
~~~

Returns the string "Up and running", with the current date/time for verification.