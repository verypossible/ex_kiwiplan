# ExKiwiplan

Register a callback function to Kiwiplan Hosts.

Whenever a message is received from a Kiwiplan Host, the callback will be invoked.

### Installation

1. Clone this repo

```bash
git clone https://github.com/verypossible-labs/ex_kiwiplan.git
```

### Usage

Add ExKiwiplan to your module's supervision tree:

```
children = [
  {Kiwiplan.Server, [port: 4040, callback: callback]}
]
```

Alternativelty, accept the default port 4040 and callback &IO.inspect/1

```
children = [
  {Kiwiplan.Server, []}
]
```

## Example client

There is also a python `client.py` for testing sending TCP messages.

- Start the Kiwiplan Server
  - `iex -S mix`
  - `ExKiwiplan.Server.start_link([])`
- Start the python client

```
$ python client.py
message: GGKKnore     # input message
'GGKKnore'            # reply
b'\x0201AK\x03'       # ack message
```

If multiple connections are made, the older will be dropped in favor of the new.

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_kiwiplan](https://hexdocs.pm/ex_kiwiplan).
