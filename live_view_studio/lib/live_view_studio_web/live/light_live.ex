defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  #mount
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(brightness: 10)
      |> assign(temp: "3000")
    {:ok, socket}
  end


  #render
  def render(assigns) do
    ~H"""
    <h1>Front Porch Light</h1>
    <form phx-change="temp">
      <div class="temps">
        <%= for temp <- ["3000", "4000", "5000"] do %>
          <div>
            <input type="radio" id={temp} name="temp" value={temp} checked={temp == @temp}/>
            <label for={temp}><%= temp %></label>
          </div>
        <% end %>
      </div>
    </form>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%; background: #{temp_color(@temp)}"}>
          <%= @brightness %>%
        </span>
      </div>
      <button phx-click="on">
        <img src="/images/light-on.svg" alt="Light On">
      </button>
      <button phx-click="up">
        <img src="/images/up.svg" alt="Dimmer up">
      </button>
      <button phx-click="down">
        <img src="/images/down.svg" alt="Dimmer down">
      </button>
      <button phx-click="off">
        <img src="/images/light-off.svg" alt="Light Off">
      </button>
      <button phx-click="rand">
        <img src="/images/fire.svg" alt="Random brightness">
      </button>
    </div>
    <br/>
    <div>
      <form action="" phx-change="slider">
        <input type="range" min="0" max="100" name="brightness" value={@brightness} phx-debounce="250">
      </form>
    </div>
    """
  end

  #handle_event
  def handle_event("on", _, socket) do
    socket =
      socket
      |> assign(brightness: 50)
    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket =
      socket
      |> assign(brightness: 0)
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket =
      socket
      |> update(:brightness, &(min(100, &1 + 10)))
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket =
      socket
      |> update(:brightness, &(max(0, &1 - 10)))
    {:noreply, socket}
  end

  def handle_event("rand", _, socket) do
    socket =
      socket
      |> assign(:brightness, Enum.random(0..100))
    {:noreply, socket}
  end

  def handle_event("slider", params, socket) do
    %{"brightness" => brightness} = params
    socket =
      socket
      |> assign(:brightness, String.to_integer(brightness))
    {:noreply, socket}
  end

  def handle_event("temp", params, socket) do
    %{"temp" => temp} = params
    socket =
      socket
      |> assign(:temp, temp)
    {:noreply, socket}
  end

  def handle_event(event, _unsigned_params, socket) do
    IO.inspect("Catch all handle_evenet hit with: #{event}")
    {:noreply, socket}
  end

  defp temp_color("3000"), do: "#F1C40D"
  defp temp_color("4000"), do: "#FEFF66"
  defp temp_color("5000"), do: "#99CCFF"
end
