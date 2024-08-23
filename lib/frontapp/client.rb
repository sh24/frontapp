require 'uri'
require 'faraday'
require 'faraday/multipart'
require_relative 'client/attachments.rb'
require_relative 'client/channels.rb'
require_relative 'client/comments.rb'
require_relative 'client/contact_groups.rb'
require_relative 'client/contacts.rb'
require_relative 'client/conversations.rb'
require_relative 'client/events.rb'
require_relative 'client/inboxes.rb'
require_relative 'client/messages.rb'
require_relative 'client/rules.rb'
require_relative 'client/tags.rb'
require_relative 'client/teammates.rb'
require_relative 'client/teams.rb'
require_relative 'client/topics.rb'
require_relative 'client/links.rb'
require_relative 'client/exports.rb'
require_relative 'error'
require_relative 'version'
require_relative 'utils/http_params.rb'

module Frontapp
  class Client

    include Frontapp::Client::Attachments
    include Frontapp::Client::Channels
    include Frontapp::Client::Comments
    include Frontapp::Client::ContactGroups
    include Frontapp::Client::Contacts
    include Frontapp::Client::Conversations
    include Frontapp::Client::Events
    include Frontapp::Client::Inboxes
    include Frontapp::Client::Messages
    include Frontapp::Client::Rules
    include Frontapp::Client::Tags
    include Frontapp::Client::Teammates
    include Frontapp::Client::Teams
    include Frontapp::Client::Topics
    include Frontapp::Client::Links
    include Frontapp::Client::Exports
    include Frontapp::Utils::HttpParams

    def initialize(options={})
      auth_token = options[:auth_token]
      user_agent = options[:user_agent] || "Frontapp Ruby Gem #{VERSION}"

      @headers = Faraday.new(base_url, {
        headers: {
          "Accept": 'application/json',
          "User-Agent": user_agent,
        }
      }) do |f|
        f.request :authorization, 'Bearer', auth_token
        f.request :json
        f.response :json
      end

      @multipart_headers = Faraday.new(base_url, {
        headers: {
          "Accept": 'application/json',
          "User-Agent": user_agent,
          "Content-Type": "multipart/form-data"
        }
      }) do |f|
        f.request :authorization, 'Bearer', auth_token
        f.request :multipart
        f.response :json
      end

    end

    def list(path, params = {})
      items = []
      last_page = false
      query = format_query(params)
      url = "#{path}?#{query}"
      until last_page
        res = @headers.get(url)
        if !res.success?
          raise Error.from_response(res)
        end
        response = res.body
        items.concat(response["_results"]) if response["_results"]
        pagination = response["_pagination"]
        if pagination.nil? || pagination["next"].nil?
          last_page = true
        else
          url = pagination["next"]
        end
      end
      items
    end

    def get(path)
      res = @headers.get(path)
      if !res.success?
        raise Error.from_response(res)
      end
      res.body
    end

    def get_plain(path)
      # TODO: Plain Text
      res = @headers.accept("text/plain").get(path)
      if !res.success?
        raise Error.from_response(res)
      end
      res.body
    end

    def get_raw(path)
      res = @headers.get(path)
      if !res.success?
        raise Error.from_response(res)
      end
      res.body
    end

    def create(path, body, multipart: false)
      api_client = multipart ? @multipart_headers : @headers
      res = api_client.post(path, body)
      if !res.success?
        raise Error.from_response(res)
      end
      res.body
    end

    def create_without_response(path, body)
      res = @headers.post(path, body)
      if !res.success?
        raise Error.from_response(res)
      end
    end

    def update(path, body)
      res = @headers.patch(path, body)
      if !res.success?
        raise Error.from_response(res)
      end
    end

    def delete(path, body = {})
      res = @headers.delete(path, body)
      if !res.success?
        raise Error.from_response(res)
      end
    end

  private

    def format_query(params)
      res = []
      q = params.delete(:q)
      if q && q.is_a?(Hash)
        res << q.map do |k, v|
          case v
          when Array then
            v.map { |c| "q[#{k}][]=#{uri_encode(c)}" }.join("&")
          else
            "q[#{k}]=#{uri_encode(v)}"
          end
        end
      end
      res << params.map {|k,v| "#{k}=#{uri_encode(v)}"}
      res.join("&")
    end

    def base_url
      "https://api2.frontapp.com/"
    end

  end
end
