# Paubox Elixir API Client

This is a simple Elixir client for the Paubox Email API. More about the API can
be found at [Paubox](https://docs.paubox.com/docs/paubox_email_api/quickstart).


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `paubox` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:paubox, "~> 1.0.0"}
  ]
end
```

## Usage

You can either pass in an API key and API user to the client or set them as
environment variables, `PAUBOX_API_KEY` and `PAUBOX_API_USER`.

This is the `message` used in the examples below.
```elixir
message =  %Paubox.Message{
  subject:  "Hey y'all!",
  from: "messenger@example.local",
  recipients: ["someone@somewhere.local"]
}
```

### Sending a Single Message
```elixir
Paubox.API.Email.client(%{api_key: "your_api_key", api_user: "your_api_user"})
|> Paubox.API.Email.send_email(message)

# or if the environment variables are set
Paubox.API.Email.client() |> Paubox.API.Email.send_email(message)
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/paubox>.
