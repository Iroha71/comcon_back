class LinebotController < ApplicationController
    require 'line/bot'
    require 'rake'
    
    def client
        @client ||= Line::Bot::Client.new { |config|
            config.channel_secret = ENV['LINE_BOT_SECRET']
            config.channel_token = ENV['LINE_BOT_TOKEN']
        }
    end

    def callback
        body = request.body.read
        signature = request.env['HTTP_X_LINE_SIGNATURE']
        unless client.validate_signature(body, signature)
            head :bad_request
        end
        events = client.parse_events_from(body)
        events.each { |event|
            user_id = event['source']['userId']
            case event
            when Line::Bot::Event::Message
                case event.type
                when Line::Bot::Event::MessageType::Text
                    reply_message = Linebot.get_reply_message(user_id, event.message['text'])
                    sent_result = client.reply_message(event['replyToken'], reply_message)
                end
            end
        }

        head :ok
    end

    def push_message
        Rails.application.load_tasks
        Rake::Task['push_remind:line'].execute
        Rake::Task['push_remind:line'].clear
        render json: { 'message': 'LINE message pushed.' }
    end
end
