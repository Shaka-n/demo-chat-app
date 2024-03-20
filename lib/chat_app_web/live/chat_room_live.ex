defmodule ChatAppWeb.ChatRoomLive do
  use Phoenix.LiveView
  alias Phoenix.PubSub

  require Logger
  def render(assigns) do
    ~H"""
    <div class = "pt-5 mt-10">
    <h1>LiveView Page</h1>
      <h3>Welcome to the Chat, <%= @current_user.username %></h3>
      <div id="chat-box">
        <%= for message <- @messages do %>
          <p><strong><%= message["username"] %>:</strong> <%= message["content"] %></p>
        <% end %>
      </div>
      <form phx-submit="submit_message">
        <input type="text" name="content" placeholder="Type your message here." phx-debounce="blur" />
        <button id="send-button">Send</button>
      </form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    PubSub.subscribe(ChatApp.PubSub, "chat_room:lobby")
    {:ok, assign(socket, current_user: %{username: "Stefan"}, messages: [])}
  end

  def handle_event("submit_message", %{"content" => content}, socket) do
    PubSub.broadcast_from(ChatApp.PubSub, self(), "chat_room:lobby", %{ event: "new_message", sender_id: self(), payload: %{
      "username" => socket.assigns.current_user.username,
      "content" => content,
      "inserted_at" => DateTime.utc_now()
    }})

    {:noreply, assign(socket, messages: [ %{"username"=> socket.assigns.current_user.username, "content" => content} | socket.assigns.messages])}
  end

  # Handling for LiveView Messages
  def handle_info(%{event: "new_message", payload: %{sender_id: sender_id} = new_message }, socket) do
    Logger.info("Received new message in LiveView: #{inspect(new_message)}")
    # IO.inspect(self(), label: "My PID: ")
    if self() == sender_id do
      {:noreply, socket}
    else
      {:noreply, update(socket, :messages, fn messages -> [ new_message| messages] end)}
    end
  end

  # Handling for Channel client messages
  def handle_info(%{event: "new_message", payload: new_message } = msg, socket) do
    Logger.info("Received new message in LiveView: #{inspect(msg)}")
      {:noreply, update(socket, :messages, fn messages -> [ new_message| messages] end)}
  end

  def handle_info(msg, socket) do
    Logger.info("Received new message in Liveview Catchall: #{inspect(msg)}")
    {:noreply, socket}
  end



  # defp message(%{"username" => username, "content" => content}) do
  #   %{"username" => username, "content" => content}
  # end

end
