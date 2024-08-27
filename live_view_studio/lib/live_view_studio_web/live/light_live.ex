defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  #mount
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(brightness: 10)
    {:ok, socket}
  end


  #render
  def render(assigns) do
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%"}>
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

  def handle_event(event, _unsigned_params, socket) do
    IO.inspect("Catch all handle_evenet hit with: #{event}")
    {:noreply, socket}
  end
end
