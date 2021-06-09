# ExKiwiplan

### Installation

1. Clone this repo

```bash
git clone https://github.com/verypossible-labs/ex_kiwiplan.git
```

### Usage

Register a listener function to Kiwiplan Hosts.

Add it to your module's supervision tree with:

```
handler = &IO.inspect/1

children = [
  {Task.Supervisor, name: Server.TaskSupervisor},
  {Kiwiplan.Server, [port: 4040, handler: handler]}
]
```

Alternativelty, accept the default port 4040 and handler &IO.inspect/1

```
children = [
  {Task.Supervisor, name: Server.TaskSupervisor},
  {Kiwiplan.Server, []}
]
```

## As a dependency

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_kiwiplan` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_kiwiplan, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_kiwiplan](https://hexdocs.pm/ex_kiwiplan).
