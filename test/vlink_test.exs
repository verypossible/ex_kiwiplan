defmodule VLinkTest do
  use ExUnit.Case
  @stx 2
  @etx 3

  def test_frame(msg_id, body, with_stx \\ true, with_etx \\ true) do
    case {with_stx, with_etx} do
      {true, true} -> <<@stx>> <> msg_id <> body <> <<@etx>>
      {true, false} -> <<@stx>> <> msg_id <> body
      {false, true} -> msg_id <> body <> <<@etx>>
      {false, false} -> msg_id <> body
    end
  end

  test "extract_frame/1 parses messages with no remainder" do
    frame = test_frame("11", "AK")
    assert ExKiwiplan.VLink.extract_frame(frame) == {frame, ""}
  end

  test "extract_frame/1 parses messages with remainder" do
    remainder = "whatever"
    frame = test_frame("11", "AK")
    frame_with_remainder = frame <> remainder
    assert ExKiwiplan.VLink.extract_frame(frame_with_remainder) == {frame, remainder}
  end

  test "extract_frame/1 passes incomplete messages to the buffer" do
    frame = test_frame("11", "AK", true, false)
    assert ExKiwiplan.VLink.extract_frame(frame) == {"", frame}
  end

  test "extract_frame/1 parses empty messages" do
    frame = ""
    assert ExKiwiplan.VLink.extract_frame(frame) == {"", ""}
  end

  test "Ack message has the message_id in it" do
    msg_id = "11"
    input = %{command: "cmd", data: "data", message_id: msg_id}
    ack = test_frame(msg_id, "AK")
    assert ExKiwiplan.VLink.ack_message(input) == ack
  end

  test "parse_frame" do
    frame = test_frame("11", "GGKKnore")

    expected = %{
      command: "GG",
      data: %{"KK" => "nore"},
      message_id: "11"
    }

    assert ExKiwiplan.VLink.parse_frame!(frame) == expected
  end
end
