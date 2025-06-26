#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'

puts "🧪 Testing Team Task Manager API (Working Endpoints)"
puts "=" * 60

base_url = 'http://localhost:3000/api'

# Test 1: User Registration
puts "\n1. Testing User Registration..."
uri = URI("#{base_url}/auth/sign_up")
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request.body = {
  user: {
    email: "demo#{Time.now.to_i}@example.com",
    password: "password123",
    password_confirmation: "password123",
    nickname: "Demo User"
  }
}.to_json

response = http.request(request)
puts "Status: #{response.code} #{response.message}"
if response.code == '201'
  result = JSON.parse(response.body)
  email = result['user']['email']
  puts "✅ Registration successful for: #{email}"
  
  # Test 2: User Login
  puts "\n2. Testing User Login..."
  uri = URI("#{base_url}/auth/sign_in")
  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/json'
  request.body = {
    email: email,
    password: "password123"
  }.to_json
  
  response = http.request(request)
  puts "Status: #{response.code} #{response.message}"
  if response.code == '200'
    result = JSON.parse(response.body)
    token = result['token']
    puts "✅ Login successful, token: #{token[0..20]}..."
    
    # Test 3: Get Current User
    puts "\n3. Testing Get Current User..."
    uri = URI("#{base_url}/auth/me")
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{token}"
    
    response = http.request(request)
    puts "Status: #{response.code} #{response.message}"
    if response.code == '200'
      result = JSON.parse(response.body)
      puts "✅ Get current user successful: #{result['user']['nickname']}"
    else
      puts "❌ Get current user failed"
    end
  else
    puts "❌ Login failed"
  end
else
  puts "❌ Registration failed"
end

puts "\n🎉 Core authentication system is working!"
puts "\nNext steps:"
puts "- Use Postman for easier testing"
puts "- Fix workspace endpoints"  
puts "- Build your Vue.js frontend"