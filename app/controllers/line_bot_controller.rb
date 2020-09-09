class LineBotController < ApplicationController
  require "line/bot"

  protect_from_forgery with: :null_session

  def callback
    # LINEで送られてきたメッセージのデータを取得
    body = request.body.read

    # LINE以外からリクエストが来た場合 Error を返す
    signature = request.env["HTTP_X_LINE_SIGNATURE"]
    unless client.validate_signature(body, signature)
      head :bad_request and return
    end

    # LINEで送られてきたメッセージを適切な形式に変形
    events = client.parse_events_from(body)

    events.each do |event|
      # LINE からテキストが送信された場合
      if (event.type === Line::Bot::Event::MessageType::Text)
        message = event["message"]["text"]
        #binding.pry
        if (message == "一覧")
          #binding.pry
          tasks = Task.all
          text = tasks.map.with_index(1) { |task, index| "#{index}: #{task.body}" }.join("\n")

        elsif (message.include?("削除"))
          #binding.pry
#          @num = message.slice(0,2)
#          @message = Task.where(id: @num)
#          reply_message = {
#            type: "text",
#            text: "タスク#{@num}：「#{@message[0][:body]}」 を削除しました。"
#          }
#          Task.find(@num).destroy!

          index = message.gsub(/削除*/, "").strip.to_i
          tasks = Task.all.to_a
          task = tasks.find.with_index(1) { |_task, _index| index == _index }
          task.destroy!
          text = "タスク #{index}: 「#{task.body}」 を削除しました！"

        else
          #binding.pry
          # 送信されたメッセージをデータベースに保存
          Task.create(body: message)

          text = "タスク：「#{message}」 を登録しました。"
        end
        reply_message = {
          type: "text",
          text: text
        }
        client.reply_message(event["replyToken"], reply_message)
      end
    end

    # LINE の webhook API との連携をするために status code 200 を返す
    render json: { status: :ok }
  end

  private

    def client
      @client ||= Line::Bot::Client.new do |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      end
    end

    def task_params
      params.require(:task).permit(:body)
    end
end
