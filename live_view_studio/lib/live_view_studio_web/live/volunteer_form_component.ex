defmodule LiveViewStudioWeb.VolunteerFormComponent do

  use LiveViewStudioWeb, :live_component
  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(socket) do
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
      <div>
        <.form for={@form} phx-submit="save" phx-change="validate" phx-target={@myself}>
          <.input field={@form[:name]} placeholder="Name" autocomplete="off" phx-debounce="1500" />
          <.input field={@form[:phone]} type="tel" placeholder="Phone Number" autocomplete="off" phx-debounce="blur" />
          <.button phx-disable-with="Saving...">
            Check in
          </.button>
        </.form>
      </div>
    """
  end


  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:error, changeset} ->
        socket = put_flash(socket, :error, "Volunteer could not be checked in.")
        {:noreply, assign(socket, :form, to_form(changeset))}
      {:ok, volunteer} ->
        send(self(), {:vol_created, volunteer})
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

  # def handle_event("checking", %{"id" => id} = _params, socket) do
  #   volunteer = Volunteers.get_volunteer!(id)
  #   {:ok, updated} = Volunteers.toggle_status_volunteer(volunteer)

  #   socket =
  #     socket
  #     |> stream_insert(:volunteers, updated)

  #   {:noreply, socket}
  # end

  # def handle_event("delete", %{"id" => id} = _params, socket) do
  #   volunteer = Volunteers.get_volunteer!(id)
  #   {:ok, deleted} = Volunteers.delete_volunteer(volunteer)

  #   socket =
  #     socket
  #     |> stream_delete(:volunteers, deleted)

  #   {:noreply, socket}
  # end
end
