#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'

class APITester
  def initialize(base_url = 'http://localhost:3000/api')
    @base_url = base_url
    @token = nil
  end

  def test_all
    puts "🧪 Testing Team Task Manager API"
    puts "=" * 50
    
    test_user_registration
    test_user_login
    test_get_current_user
    test_create_workspace
    test_get_workspaces
    test_create_task
    test_get_tasks
    
    puts "\n✅ All tests completed!"
  end

  private

  def make_request(method, endpoint, data = nil, auth = true)
    uri = URI("#{@base_url}#{endpoint}")
    http = Net::HTTP.new(uri.host, uri.port)
    
    case method.upcase
    when 'GET'
      request = Net::HTTP::Get.new(uri)
    when 'POST'
      request = Net::HTTP::Post.new(uri)
      request.body = data.to_json if data
    when 'PUT'
      request = Net::HTTP::Put.new(uri)
      request.body = data.to_json if data
    when 'DELETE'
      request = Net::HTTP::Delete.new(uri)
    end
    
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{@token}" if auth && @token
    
    begin
      response = http.request(request)
      puts "#{method} #{endpoint}: #{response.code} #{response.message}"
      
      if response.body && !response.body.empty?
        result = JSON.parse(response.body)
        puts "Response: #{result}"
        return result
      end
    rescue => e
      puts "❌ Error: #{e.message}"
      return nil
    end
  end

  def test_user_registration
    puts "\n1. Testing User Registration..."
    user_data = {
      user: {
        email: "testuser#{Time.now.to_i}@example.com",
        password: "password123",
        password_confirmation: "password123",
        nickname: "Test User"
      }
    }
    
    result = make_request('POST', '/auth/sign_up', user_data, false)
    puts result ? "✅ Registration successful" : "❌ Registration failed"
  end

  def test_user_login
    puts "\n2. Testing User Login..."
    login_data = {
      email: "testuser#{Time.now.to_i}@example.com",
      password: "password123"
    }
    
    # First create a user
    user_data = {
      user: {
        email: login_data[:email],
        password: "password123",
        password_confirmation: "password123",
        nickname: "Test User"
      }
    }
    make_request('POST', '/auth/sign_up', user_data, false)
    
    # Then try to login
    uri = URI("#{@base_url}/auth/sign_in")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = login_data.to_json
    
    begin
      response = http.request(request)
      puts "POST /auth/sign_in: #{response.code} #{response.message}"
      
      if response.body && !response.body.empty?
        result = JSON.parse(response.body)
        puts "Response: #{result}"
        
        # Extract token from response body or Authorization header
        if result['token']
          @token = result['token']
          puts "✅ Login successful, token saved from response"
        elsif response['Authorization']
          @token = response['Authorization'].sub('Bearer ', '')
          puts "✅ Login successful, token saved from header"
        else
          puts "❌ No token received"
        end
      end
    rescue => e
      puts "❌ Error: #{e.message}"
    end
  end

  def test_get_current_user
    puts "\n3. Testing Get Current User..."
    return puts "❌ No token available" unless @token
    
    result = make_request('GET', '/auth/me')
    puts result ? "✅ Get current user successful" : "❌ Get current user failed"
  end

  def test_create_workspace
    puts "\n4. Testing Create Workspace..."
    return puts "❌ No token available" unless @token
    
    workspace_data = {
      work_group: {
        name: "Test Workspace #{Time.now.to_i}"
      }
    }
    
    result = make_request('POST', '/work_groups', workspace_data)
    if result && result['work_group']
      @workspace_id = result['work_group']['id']
      puts "✅ Workspace created with ID: #{@workspace_id}"
    else
      puts "❌ Workspace creation failed"
    end
  end

  def test_get_workspaces
    puts "\n5. Testing Get Workspaces..."
    return puts "❌ No token available" unless @token
    
    result = make_request('GET', '/work_groups')
    puts result ? "✅ Get workspaces successful" : "❌ Get workspaces failed"
  end

  def test_create_task
    puts "\n6. Testing Create Task..."
    return puts "❌ No token available" unless @token
    return puts "❌ No workspace available" unless @workspace_id
    
    task_data = {
      task: {
        title: "Test Task #{Time.now.to_i}",
        description: "This is a test task created by the API tester",
        category: "feature",
        status: "open",
        priority: "medium"
      }
    }
    
    result = make_request('POST', "/work_groups/#{@workspace_id}/tasks", task_data)
    if result && result['task']
      @task_id = result['task']['id']
      puts "✅ Task created with ID: #{@task_id}"
    else
      puts "❌ Task creation failed"
    end
  end

  def test_get_tasks
    puts "\n7. Testing Get Tasks..."
    return puts "❌ No token available" unless @token
    return puts "❌ No workspace available" unless @workspace_id
    
    result = make_request('GET', "/work_groups/#{@workspace_id}/tasks")
    puts result ? "✅ Get tasks successful" : "❌ Get tasks failed"
  end
end

# Run the tests
if __FILE__ == $0
  tester = APITester.new
  tester.test_all
end