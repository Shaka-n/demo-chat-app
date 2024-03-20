defmodule ChatAppWeb.ChatRoomChannel do
  use ChatAppWeb, :channel

  require Logger

  @impl true
  def join("chat_room:lobby", payload, socket) do
    Logger.info("+++++NEW JOINER IN CHANNEL+++++")
    # PubSub.subscribe(ChatApp.PubSub, "chat_room:lobby")
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in("new_client_message", payload, socket) do
    broadcast(socket, "new_message", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in(event, payload, socket) do
    Logger.info("New message in Channel Catchall. Event: #{inspect(event)}, Payload: #{inspect(payload)}")
    {:noreply, socket}
  end

  # Generic PubSub broadcast handling
  @impl true
  def handle_info(%{ event: "new_message", payload: message} = msg, socket) do
    IO.inspect("Receieved new message in Channel from PubSub broadcast: #{inspect(msg)}")
    IO.inspect(self(), label: "My PID: ")
    push(socket, "new_message", message)
    {:noreply, socket}
  end

  @impl true
  def handle_info(msg, socket) do
    IO.inspect("Catchall Handle info in Channel Process: Message:#{inspect(msg)}")
    {:noreply, socket}
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
