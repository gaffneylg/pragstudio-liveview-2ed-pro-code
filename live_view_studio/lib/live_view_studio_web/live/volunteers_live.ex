defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    changeset = Volunteers.change_volunteer(%Volunteer{})

    socket =
      socket
      |> assign(volunteers: volunteers)
      |> assign(form: to_form(changeset))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.form for={@form} phx-submit="save">
        <.input field={@form[:name]} placeholder="Name" autocomplete="off" />
        <.input field={@form[:phone]} type="tel" placeholder="Phone Number" autocomplete="off" />
        <.button phx-disable-with="Saving...">
          Check in
        </.button>
      </.form>
      <.flash_group flash={@flash} />
      <div
        :for={volunteer <- @volunteers}
        class={"volunteer #{if volunteer.checked_out, do: "out"}"}
      >
        <div class="name">
          <%= volunteer.name %>
        </div>
        <div class="phone">
          <%= volunteer.phone %>
        </div>
        <div class="status">
          <button>
            <%= if volunteer.checked_out, do: "Check In", else: "Check Out" %>
          </button>
        </div>
      </div>
    </div>
    """
  end


  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:error, changeset} ->
        socket = put_flash(socket, :error, "Volunteer could not be checked in.")
        {:noreply, assign(socket, :form, to_form(changeset))}
      {:ok, volunteer} ->
        socket =
          socket
          |> update(:volunteers, fn volunteers -> [volunteer | volunteers] end)

        empty_changeset = Volunteers.change_volunteer(%Volunteer{})
        socket =
          socket
          |> assign(:form, to_form(empty_changeset))

        socket = put_flash(socket, :info, "Volunteer checked in successfully.")
      {:noreply, socket}
    end
  end

end
