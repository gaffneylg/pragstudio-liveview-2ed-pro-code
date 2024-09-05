defmodule LiveViewStudioWeb.AthletesLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Athletes

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        filter: %{sport: "", status: ""},
        athletes: Athletes.list_athletes()
      )

    {:ok, socket, temporary_assigns: [athletes: []]}
  end

  def handle_event("sport-filter", params, socket) do
    %{"sport" => sport, "status" => status} = params
    filter = %{sport: sport, status: status}
    athletes = Athletes.list_athletes(filter)
    socket =
      socket
      |> assign(athletes: athletes)
      |> assign(filter: filter)

    {:noreply, socket}
  end

  defp sport_options do
    [
      "All Sports": "",
      Surfing: "Surfing",
      Rowing: "Rowing",
      Swimming: "Swimming"
    ]
  end

  defp status_options do
    [
      "All Statuses": "",
      Training: :training,
      Competing: :competing,
      Resting: :resting
    ]
  end
end
