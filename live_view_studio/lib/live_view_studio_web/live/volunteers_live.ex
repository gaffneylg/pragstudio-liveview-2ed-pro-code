defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    changeset = Volunteers.change_volunteer(%Volunteer{})

    socket =
      socket
      |> stream(:volunteers, volunteers)
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.form for={@form} phx-submit="save" phx-change="validate" >
        <.input field={@form[:name]} placeholder="Name" autocomplete="off" phx-debounce="1500" />
        <.input field={@form[:phone]} type="tel" placeholder="Phone Number" autocomplete="off" phx-debounce="blur" />
        <.button phx-disable-with="Saving...">
          Check in
        </.button>
      </.form>
      <.flash_group flash={@flash} />
      <div id="volunteers" phx-update="stream">
        <div
          :for={{vol_id, volunteer} <- @streams.volunteers}
          class={"volunteer #{if volunteer.checked_out, do: "out"}"}
          id={vol_id}
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
          |> stream_insert(:volunteers, volunteer, at: 0)

        empty_changeset = Volunteers.change_volunteer(%Volunteer{})
        socket =
          socket
          |> assign(:form, to_form(empty_changeset))

        socket = put_flash(socket, :info, "Volunteer checked in successfully.")
      {:noreply, socket}
    end
  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do

    changeset =
      %Volunteer{}
      |> Volunteers.change_volunteer(volunteer_params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(form: to_form(changeset))

    {:noreply, socket}
  end

end
