defmodule LiveViewStudioWeb.FlightsLive do
  use LiveViewStudioWeb, :live_view
  alias LiveViewStudio.Flights, as: Flights
  alias LiveViewStudio.Airports, as: Airports
  import LiveViewStudioWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        airport: "",
        flights: [],
        loading: false,
        matches: %{}
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Find a Flight</h1>
    <div id="flights">
      <form phx-submit="search" phx-change="suggest">
        <input
          type="text"
          name="airport"
          value={@airport}
          placeholder="Airport Code"
          autofocus
          autocomplete="off"
          readonly={@loading}
          list="matches"
          phx-debounce="1000"
        />

        <button>
          <img src="/images/search.svg" />
        </button>
      </form>

      <datalist id="matches">
        <option :for={{code, name} <- @matches} value={code}>
          <%= name %>
        </option>
      </datalist>

      <.loading_spinner loading={@loading} />

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
    flights = Flights.search_by_airport(code)
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

  def handle_event("suggest", params, socket) do
    %{"airport" => code} = params
    suggestions = Airports.suggest(code)
    socket =
      socket
      |> assign(airport: code)
      |> assign(matches: suggestions)
      |> assign(loading: false)

    {:noreply, socket}
  end
end
