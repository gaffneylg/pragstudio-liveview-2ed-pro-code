defmodule LiveViewStudioWeb.FlightsLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        airport: "",
        flights: LiveViewStudio.Flights.list_flights(),
        loading: false
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Find a Flight</h1>
    <div id="flights">
      <form phx-submit="search">
        <input
          type="text"
          name="airport"
          value={@airport}
          placeholder="Airport Code"
          autofocus
          autocomplete="off"
          readonly={@loading}
        />

        <button>
          <img src="/images/search.svg" />
        </button>
      </form>

      <div :if={@loading} class="loader">Loading...</div>

      <div class="flights">
        <ul>
          <li :for={flight <- @flights}>
            <div class="first-line">
              <div class="number">
                Flight #<%= flight.number %>
              </div>
              <div class="origin-destination">
                <%= flight.origin %> to <%= flight.destination %>
              </div>
            </div>
            <div class="second-line">
              <div class="departs">
                Departs: <%= flight.departure_time %>
              </div>
              <div class="arrives">
                Arrives: <%= flight.arrival_time %>
              </div>
            </div>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def handle_info(:filter, socket) do
    code = socket.assigns.airport
    flights = LiveViewStudio.Flights.search_by_airport(code)
    socket =
      socket
      |> assign(airport: code)
      |> assign(flights: flights)
      |> assign(loading: false)

    {:noreply, socket}
  end

  def handle_event("search", params, socket) do
    send(self(), :filter)
    %{"airport" => code} = params
    socket =
      socket
      |> assign(airport: code)
      |> assign(flights: [])
      |> assign(loading: true)

    {:noreply, socket}
  end
end
