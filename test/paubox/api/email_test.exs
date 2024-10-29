defmodule Paubox.API.EmailTest do
  use ExUnit.Case, async: true
  doctest Paubox.API.Email

  import Mock

  alias Paubox.API.Email
  alias Paubox.API.SendResponse
  alias Paubox.Message

  setup do
    Req.Test.stub(:email_send_bulk_success, fn conn ->
      Req.Test.json(conn, %{
        messages: [
          %{
            sourceTrackingId: "3d38ab13-0af8-4028-bd45-999999999999",
            data: "Service OK"
          }
        ]
      })
    end)

    :ok
  end

  describe "client/1" do
    test "creates a client with string arguments" do
      client = Email.client(%{"api_key" => "api_key", "api_user" => "api_user"})

      assert client.options.auth == "Token token=api_key"
      assert client.options.base_url == "https://api.paubox.net/v1/api_user"
    end

    test "creates a client with string arguments and opts" do
      client = Email.client(%{"api_key" => "api_key", "api_user" => "api_user"}, [])

      assert client.options.auth == "Token token=api_key"
      assert client.options.base_url == "https://api.paubox.net/v1/api_user"
    end

    test "creates a client with atom arguments" do
      client = Email.client(%{api_key: "api_key", api_user: "api_user"})

      assert client.options.auth == "Token token=api_key"
      assert client.options.base_url == "https://api.paubox.net/v1/api_user"
    end

    test "it creates an HTTP client with env variables" do
      with_mock(System, [:passthrough],
        get_env: fn str ->
          case str do
            "PAUBOX_API_KEY" -> "api_key"
            "PAUBOX_API_USER" -> "api_user"
            _ -> System.get_env(str, "NOT SET")
          end
        end
      ) do
        client = Email.client()
        assert client.options.auth == "Token token=api_key"
        assert client.options.base_url == "https://api.paubox.net/v1/api_user"
      end
    end
  end

  describe "send/2" do
    test "stub a basic successful response" do
      Req.Test.stub(:email_send_success, fn conn ->
        Req.Test.json(conn, %{
          sourceTrackingId: "3d38ab13-0af8-4028-bd45-52e882e0d584",
          data: "Service OK"
        })
      end)

      resp =
        Email.client(plug: {Req.Test, :email_send_success})
        |> Email.send(%Message{from: "test@example.local", subject: "test"})

      assert resp ==
               {:ok,
                %SendResponse{
                  sourceTrackingId: "3d38ab13-0af8-4028-bd45-52e882e0d584",
                  data: "Service OK"
                }}
    end

    test "stub a basic error response" do
      Req.Test.stub(:email_send_api_error, fn conn ->
        Req.Test.json(%Plug.Conn{conn | status: 400}, %{
          errors: [
            %{
              code: 400,
              title: "Error Title",
              details: "Description of error"
            }
          ]
        })
      end)

      resp =
        Email.client(plug: {Req.Test, :email_send_api_error})
        |> Email.send(%Message{from: "test@example.local", subject: "test"})

      assert resp ==
               {:api_error,
                %{
                  "errors" => [
                    %{
                      "code" => 400,
                      "details" => "Description of error",
                      "title" => "Error Title"
                    }
                  ]
                }}
    end

    test "stub an exception from the client" do
      Req.Test.stub(:email_send_error, fn _conn ->
        raise "Exception from client"
      end)

      resp =
        Email.client(plug: {Req.Test, :email_send_error})
        |> Email.send(%Message{from: "test@example.local", subject: "test"})

      assert resp == {:error, "** (RuntimeError) Exception from client"}
    end
  end

  describe "send_bulk/2" do
    test "stub a basic successful bulk response" do
      resp =
        Email.client(plug: {Req.Test, :email_send_bulk_success})
        |> Email.send_bulk([%Message{from: "test@example.local", subject: "test"}])

      assert {:ok, [first | _rest]} = resp
      assert first.sourceTrackingId == "3d38ab13-0af8-4028-bd45-999999999999"
      assert first.data == "Service OK"
    end
  end

  describe "send_in_batches/3" do
    test "sending in batches" do
      fake_msg = %Message{from: "test@example.local", subject: "test"}

      resp =
        Email.client(plug: {Req.Test, :email_send_bulk_success})
        |> Email.send_in_batches([fake_msg, fake_msg])

      assert {:ok, [first | _rest] = body} = resp
      assert length(body) == 1
      assert first.sourceTrackingId == "3d38ab13-0af8-4028-bd45-999999999999"
      assert first.data == "Service OK"
    end

    test "sending in batches of 1" do
      fake_msg = %Message{from: "test@example.local", subject: "test"}

      resp =
        Email.client(plug: {Req.Test, :email_send_bulk_success})
        |> Email.send_in_batches([fake_msg, fake_msg], 1)

      assert {:ok, [first | _rest] = body} = resp
      assert length(body) == 2
      assert first.sourceTrackingId == "3d38ab13-0af8-4028-bd45-999999999999"
      assert first.data == "Service OK"
    end
  end

  describe "get_receipt/2" do
    test "stub a successful receipt response" do
      Req.Test.stub(:email_get_receipt_success, fn conn ->
        Req.Test.json(
          conn,
          %{
            sourceTrackingId: "6e1cf9a4-7bde-4834-8200-ed424b50c8a7",
            data: %{
              message: %{
                id: "<f4a9b518-439c-497d-b87f-dfc9cc19194b@authorized_domain.com>",
                message_deliveries: [
                  %{
                    recipient: "recipient@host.com",
                    status: %{
                      deliveryStatus: "delivered",
                      deliveryTime: "Mon, 23 Apr 2018 13:27:34 -0700",
                      openedStatus: "opened",
                      openedTime: "Mon, 23 Apr 2018 13:27:51 -0700"
                    }
                  }
                ]
              }
            }
          }
        )
      end)

      resp =
        Email.client(plug: {Req.Test, :email_get_receipt_success})
        |> Email.get_receipt("doesnt-matter")

      assert resp == %{
               "data" => %{
                 "message" => %{
                   "id" => "<f4a9b518-439c-497d-b87f-dfc9cc19194b@authorized_domain.com>",
                   "message_deliveries" => [
                     %{
                       "recipient" => "recipient@host.com",
                       "status" => %{
                         "deliveryStatus" => "delivered",
                         "deliveryTime" => "Mon, 23 Apr 2018 13:27:34 -0700",
                         "openedStatus" => "opened",
                         "openedTime" => "Mon, 23 Apr 2018 13:27:51 -0700"
                       }
                     }
                   ]
                 }
               },
               "sourceTrackingId" => "6e1cf9a4-7bde-4834-8200-ed424b50c8a7"
             }
    end
  end
end
