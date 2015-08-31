require 'sinatra'
require 'rotp'
require 'base32'
require 'rqrcode_png'
require 'active_support/core_ext/time'
require 'haml'
require 'kramdown'

configure do
  set :server, 'thin'
  set :haml, :attr_wrapper => '"'
end

helpers do
  def generate_secret
    ROTP::Base32.random_base32.upcase
  end
end

get '/' do
  @readme = File.read 'README.md'
  @default_secret = generate_secret
  @default_user = 'joebloggs@example.com'
  @default_system = 'eSystem'
  @starting_otp_code = ROTP::TOTP.new(@default_secret).now
  haml :index
end

get '/generate-secret' do
  content_type 'text/plain'
  generate_secret
end

get '/get-otp-qr-code/:user/:secret/:issuer?' do |user,secret,issuer|
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

get '/current-otp-code/:secret' do |secret|
  content_type 'text/plain'

  if secret.nil?
    return 'Must provide a secret and a code'
  end

  if secret.size % 8 != 0
    return 'Secret must be a multiple of 8 characters in length'
  end

  totp = ROTP::TOTP.new(secret)
  totp.now
end

get '/service-status' do
  content_type 'text/plain'
  "Up and running: #{Time.now.to_formatted_s :db}" 
end
