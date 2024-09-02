defmodule LiveViewStudioWeb.VehiclesLive do
  use LiveViewStudioWeb, :live_view
  alias LiveViewStudio.Vehicles, as: Vehicles
  import LiveViewStudioWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        query: "",
        vehicles: [],
        loading: false,
        matches: %{}
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>🚙 Find a Vehicle 🚘</h1>
    <div id="vehicles">
      <form phx-submit="search" phx-change="suggest">
        <input
          type="text"
          name="query"
          value={@query}
          placeholder="Make or model"
          autofocus
          autocomplete="off"
          list="matches"
          phx-debounce="5000"
        />

        <button>
          <img src="/images/search.svg" />
        </button>
      </form>

      <datalist id="matches">
        <option :for={car <- @matches} value={car}>
          <%= car %>
        </option>
      </datalist>

      <.loading_dots loading={@loading} />

      <div class="vehicles">
        <ul>
          <li :for={vehicle <- @vehicles}>
            <span class="make-model">
              <%= vehicle.make_model %>
            </span>
            <span class="color">
              <%= vehicle.color %>
            </span>
            <span class={"status #{vehicle.status}"}>
              <%= vehicle.status %>
            </span>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def handle_info(:filter, socket) do
    code = socket.assigns.query
    vehicles = Vehicles.search(code)
    socket =
      socket
      |> assign(vehicles: vehicles)
      |> assign(query: code)
      |> assign(loading: false)

    {:noreply, socket}
  end


  def handle_event("search", params, socket) do
    send(self(), :filter)
    %{"query" => code} = params
    socket =
      socket
      |> assign(query: code)
      |> assign(vehicles: [])
      |> assign(loading: true)

    {:noreply, socket}
  end

  def handle_event("suggest", params, socket) do
    %{"query" => code} = params
    suggestions = Vehicles.suggest(code)
    socket =
      socket
      |> assign(query: code)
      |> assign(matches: suggestions)
      |> assign(loading: false)

    {:noreply, socket}
  end
end
