defmodule ExKiwiplan.Server do
  require Logger
  alias ExKiwiplan.VLink

  @read_timeout 60_000

  def start_link(port: port, handler: handler) do
    pid = spawn(fn -> accept(port, handler) end)
    {:ok, pid}
  end

  def start_link(_) do
    pid = spawn(fn -> accept(4040, &IO.inspect/1) end)
    {:ok, pid}
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent
    }
  end

  def accept(port, callback) do
    {:ok, socket} =
      :gen_tcp.listen(
        port,
        [:binary, packet: :raw, active: false, reuseaddr: true]
      )

    Logger.info("Accepting connections on port #{port}")

    loop_acceptor(socket, callback)
  end

  defp loop_acceptor(socket, callback, pid \\ nil) do
    {:ok, client} = :gen_tcp.accept(socket)
    unless pid == nil, do: Process.exit(pid, :kill)
    pid = spawn(fn -> serve(client, callback) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket, callback, pid)
  end

  defp serve(client, callback, buffer \\ "") do
    {frame, buffer} =
      case read_line(client) do
        {:ok, data} ->
          buffer = buffer <> data

          case VLink.extract_frame(buffer) do
            {"", ""} ->
              {"", ""}

            {"", buffer} ->
              {"", buffer}

            {frame, ""} ->
              parsed_frame = VLink.parse_frame!(frame)
              callback.(parsed_frame)
              ack = VLink.ack_message(parsed_frame)
              {ack, ""}

            {frame, buffer} ->
              parsed_frame = VLink.parse_frame!(frame)
              callback.(parsed_frame)
              ack = VLink.ack_message(parsed_frame)

              {ack, buffer}
          end

        {:error, _} = err ->
          {err, buffer}
      end

    Logger.info("Frame: #{inspect(frame)}, Buffer: #{inspect(buffer)}")

    write_line(client, frame)
    serve(client, callback, buffer)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0, @read_timeout)
  end

  defp write_line(socket, {:error, :unknown_command}) do
    # Known error; write to the client
    :gen_tcp.send(socket, "UNKNOWN COMMAND\r\n")
  end

  defp write_line(_socket, {:error, :closed}) do
    # The connection was closed, exit politely
    Logger.info("The connection was closed")
    exit(:shutdown)
  end

  defp write_line(_socket, {:error, :timeout}) do
    Logger.info("The connection timed out")
    exit(:timeout)
  end

  defp write_line(_socket, {:error, :enotconn}) do
    Logger.info("The connection failed")
    exit(:not_connected)
  end

  defp write_line(_socket, {:error, error}) do
    # Unknown error;
    exit(error)
  end

  defp write_line(socket, frame) do
    :gen_tcp.send(socket, frame)
  end
end
