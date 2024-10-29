defmodule Paubox.MessageTest do
  use ExUnit.Case, async: true
  doctest Paubox.Message

  @subject "Hey y'all!"
  @from "messenger@example.local"
  @recipients ["someone@somewhere.local"]

  describe "Jason Encoding" do
    test "encodes a basic message" do
      message = basic_message()

      assert Jason.encode!(message) |> Jason.decode!() ==
               %{
                 "headers" => %{
                   "subject" => @subject,
                   "from" => @from
                 },
                 "force_secure_notification" => false,
                 "allow_non_tls" => false,
                 "content" => %{}
               }
    end

    test "encodes a message with recipients" do
      message = %Paubox.Message{basic_message() | recipients: @recipients}

      assert Jason.encode!(message) |> Jason.decode!() ==
               %{
                 "headers" => %{
                   "subject" => @subject,
                   "from" => @from
                 },
                 "force_secure_notification" => false,
                 "allow_non_tls" => false,
                 "content" => %{},
                 "recipients" => @recipients
               }
    end

    test "encodes a message with html content" do
      message = %Paubox.Message{basic_message() | html_content: "<h1>Hey y'all!</h1>"}

      assert Jason.encode!(message) |> Jason.decode!() ==
               %{
                 "headers" => %{
                   "subject" => @subject,
                   "from" => @from
                 },
                 "force_secure_notification" => false,
                 "allow_non_tls" => false,
                 "content" => %{
                   "text/html" => "<h1>Hey y'all!</h1>"
                 }
               }
    end

    test "encodes a message with html and text content" do
      message = %Paubox.Message{
        basic_message()
        | html_content: "<h1>Hey y'all!</h1>",
          text_content: "Hey y'all!"
      }

      assert Jason.encode!(message) |> Jason.decode!() ==
               %{
                 "headers" => %{
                   "subject" => @subject,
                   "from" => @from
                 },
                 "force_secure_notification" => false,
                 "allow_non_tls" => false,
                 "content" => %{
                   "text/plain" => "Hey y'all!",
                   "text/html" => "<h1>Hey y'all!</h1>"
                 }
               }
    end

    test "encodes a message with cc and bcc" do
      message = %Paubox.Message{
        basic_message()
        | recipients: @recipients,
          cc: ["someone-b@somewhere.local"],
          bcc: ["someone-c@somewhere.local"]
      }

      assert Jason.encode!(message) |> Jason.decode!() ==
               %{
                 "headers" => %{
                   "subject" => @subject,
                   "from" => @from
                 },
                 "force_secure_notification" => false,
                 "allow_non_tls" => false,
                 "content" => %{},
                 "recipients" => @recipients,
                 "cc" => ["someone-b@somewhere.local"],
                 "bcc" => ["someone-c@somewhere.local"]
               }
    end

    test "encodes a message with reply-to" do
      message = %Paubox.Message{
        basic_message()
        | reply_to: "messenger+reply@example.local"
      }

      assert Jason.encode!(message) |> Jason.decode!() ==
               %{
                 "headers" => %{
                   "subject" => @subject,
                   "from" => @from,
                   "reply-to" => "messenger+reply@example.local"
                 },
                 "force_secure_notification" => false,
                 "allow_non_tls" => false,
                 "content" => %{}
               }
    end

    test "encodes a message with List-Unsubscribe" do
      message = %Paubox.Message{
        basic_message()
        | unsubscribe: "https://example.local/unsubscribe"
      }

      assert Jason.encode!(message) |> Jason.decode!() ==
               %{
                 "headers" => %{
                   "subject" => @subject,
                   "from" => @from,
                   "List-Unsubscribe" => "https://example.local/unsubscribe"
                 },
                 "force_secure_notification" => false,
                 "allow_non_tls" => false,
                 "content" => %{}
               }
    end
  end

  defp basic_message do
    %Paubox.Message{
      subject: @subject,
      from: @from
    }
  end
end
