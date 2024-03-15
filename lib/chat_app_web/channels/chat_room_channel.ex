defmodule ChatAppWeb.ChatRoomChannel do
  use ChatAppWeb, :channel
  alias Phoenix.PubSub

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
  def handle_in("new_message", payload, socket) do
    broadcast(socket, "new_message", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_client_message", payload, socket) do
    broadcast(socket, "new_message", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_liveview_message", payload, socket) do
    Logger.info("Receieved message in Channel: #{inspect(payload)}")
    broadcast(socket, "new_message", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in(event, payload, socket) do
    Logger.info("New message in catchall handle_in: #{inspect(event)}")
    {:noreply, socket}
  end

  # For handling internal broadcasts
  @impl true
  def handle_info(%{ event: "new_liveview_message", payload: message}, socket) do
    Logger.info("Receieved new message in Channel from local broadcast: #{inspect(message)}")
    # PubSub.broadcast(ChatApp.PubSub, "chat_room:lobby", %{event: "new_message", payload: message})
    broadcast(socket, "new_message", message)
    {:noreply, socket}
  end

  @impl true
  def handle_info(msg, socket) do
    Logger.info("Catchall Handle info in Channel Process: Message:#{inspect(msg)}")
    Logger.info("Catcahll Handle Info in channel: Socket: #{inspect(socket)}")
    {:noreply, socket}
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
