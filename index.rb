require 'sinatra'
require 'rotp'
require 'base32'
require 'rqrcode_png'
require 'active_support/core_ext/time'

configure do
  set :server, 'thin'
end

get '/' do
  content_type 'text/plain'
  "API Documentation:\n\n" +
      "/generate-secret - generates a new base32 secret\n\n" +
      "/get-otp-qr-code/:user/:secret/:issuer - gets a OTP QR code (png) for Google Authenticator or similar\n\n" +
      "/verify-otp-code/:secret/:otp_code - checks if a code is valid for a secret, returns string true or false\n\n" +
      "/service-status - determines that this service is up and running\n\n"
end

get '/generate-secret' do
  content_type 'text/plain'
  ROTP::Base32.random_base32.upcase
end

get '/get-otp-qr-code/:user/:secret/:issuer' do |user,secret,issuer|
  if user.nil? or secret.nil?
    content_type 'text/plain'
    return 'Must provide a user and a secret, issuer may be omitted'
  end

  if secret.size % 8 != 0
    content_type 'text/plain'
    return 'Secret must be a multiple of 8 characters in length'
  end

  content_type 'image/png'
  totp = ROTP::TOTP.new(secret, issuer: issuer)
  uri_to_qr_code = totp.provisioning_uri(user)
  qr = RQRCode::QRCode.new(uri_to_qr_code, :size => 8, :level => :m)
  png = qr.to_img
  png = png.resize(250,250)
  png.to_s
end

get '/verify-otp-code/:secret/:otp_code' do |secret,otp_code|
  content_type 'text/plain'

  if secret.nil? or otp_code.nil?
    return 'Must provide a secret and a code'
  end

  if secret.size % 8 != 0
    return 'Secret must be a multiple of 8 characters in length'
  end

  totp = ROTP::TOTP.new(secret)
  totp.verify(otp_code).to_s
end

get '/service-status' do
  content_type 'text/plain'
  "Up and running: #{Time.now.to_formatted_s :db}" 
end
