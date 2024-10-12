defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer
  alias LiveViewStudioWeb.VolunteerFormComponent

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    socket =
      socket
      |> stream(:volunteers, volunteers)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.live_component module={VolunteerFormComponent} id={:new} />

      <.flash_group flash={@flash} />
      <div id="volunteers" phx-update="stream">
        <.volunteer
          :for={{vol_id, volunteer} <- @streams.volunteers}
          volunteer={volunteer}
          id={vol_id}
        />
      </div>
    </div>
    """
  end

  def volunteer(assigns) do
    ~H"""
      <div
        class={"volunteer #{if @volunteer.checked_out, do: "out"}"}
        id={@id}
      >
        <div class="name">
          <%= @volunteer.name %>
        </div>
        <div class="phone">
          <%= @volunteer.phone %>
        </div>
        <div class="status">
          <button phx-click="checking" phx-value-id={@volunteer.id}>
            <%= if @volunteer.checked_out, do: "Check In", else: "Check Out" %>
          </button>
        </div>
        <.link class="delete" phx-click="delete" phx-value-id={@volunteer.id} data-confirm="Are you sure?">
          <.icon name="hero-trash-solid" />
        </.link>
      </div>
    """
  end

  def handle_info({:vol_created, volunteer}, socket) do
    socket =
      socket
      |> stream_insert(:volunteers, volunteer, at: 0)

    empty_changeset = Volunteers.change_volunteer(%Volunteer{})
    socket =
      socket
      |> assign(:form, to_form(empty_changeset))

    socket = put_flash(socket, :info, "Volunteer checked in successfully.")
    {:noreply, socket}
  end

  def handle_event("checking", %{"id" => id} = _params, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    {:ok, updated} = Volunteers.toggle_status_volunteer(volunteer)

    socket =
      socket
      |> stream_insert(:volunteers, updated)

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id} = _params, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    {:ok, deleted} = Volunteers.delete_volunteer(volunteer)

    socket =
      socket
      |> stream_delete(:volunteers, deleted)

    {:noreply, socket}
  end
end
