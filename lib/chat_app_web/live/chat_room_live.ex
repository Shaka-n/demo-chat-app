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
          <p><strong><%= message.username %>:</strong> <%= message.content %></p>
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

  def handle_info(%{event: "new_message", payload: msg }, socket) do
    Logger.info("Received new message from topic broadcast: #{inspect(msg)}")
      {:noreply, update(socket, :messages, fn messages -> [ msg| messages] end)}
  end

  def handle_info(msg, socket) do
    Logger.info("Received new message in Liveview Catchall: #{inspect(msg)}")
    {:noreply, socket}
  end

  def handle_event("submit_message", %{"content" => content}, socket) do
    PubSub.broadcast(ChatApp.PubSub, "chat_room:lobby", %{ event: "new_liveview_message", payload: %{
      username: socket.assigns.current_user.username,
      content: content,
      inserted_at: DateTime.utc_now(),
      pid: self() |> inspect() |> Jason.encode!
    }})
    # ChatAppWeb.Endpoint.broadcast("chat_room:lobby", "new_local_message", %{payload: %{
    #   username: socket.assigns.current_user.username,
    #   content: content,
    #   pid: self()
    # }})
    {:noreply, socket}
    # {:noreply, assign(socket, messages: [ %{username: socket.assigns.current_user.username, content: content} | socket.assigns.messages])}
  end

  # defp message(%{"username" => username, "content" => content}) do
  #   %{"username" => username, "content" => content}
  # end

end
