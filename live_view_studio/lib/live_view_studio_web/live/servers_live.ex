defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()

    socket =
      socket
      |> assign(servers: servers)
      |> assign(coffees: 0)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.link class="add" patch={~p"/servers/new"}>
            + Add new server
          </.link>
          <.link
            :for={server <- @servers}
            patch={~p"/servers/#{server}"}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link>
        </div>
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <div class="wrapper">
          <div>
            <%= if @live_action == :new do %>
              <.form for={@form} phx-submit="save" phx-change="validate">
                <div class="field">
                  <.input field={@form[:name]} placeholder="Name" autocomplete="off" phx-debounce="1500"/>
                </div>
                <div class="field">
                  <.input field={@form[:framework]} placeholder="Framework" autocomplete="off" phx-debounce="1500"/>
                </div>
                <div class="field">
                  <.input field={@form[:size]} placeholder="Size (Mb)" autocomplete="off" type="number" phx-debounce="1500"/>
                </div>
                <.button phx-disable-with="Saving...">
                  Save
                </.button>
                <.link class="cancel" patch={~p"/servers/"}>
                  Cancel
                </.link>
              </.form>
            <% else %>
              <.server server={@selected_server} />
            <% end %>
          </div>
          <div class="links">
            <.link navigate={~p"/light"}>
              Adjust Lights
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def server(assigns) do
    ~H"""
      <div class="server">
        <div class="header">
          <h2><%= @server.name %></h2>
          <button class={@server.status} phx-click="toggle-status" phx-value-id={@server.id}>
            <%= @server.status %>
          </button>
        </div>
        <div class="body">
          <div class="row">
            <span>
              <%= @server.deploy_count %> deploys
            </span>
            <span>
              <%= @server.size %> MB
            </span>
            <span>
              <%= @server.framework %>
            </span>
          </div>
          <h3>Last Commit Message:</h3>
          <blockquote>
            <%= @server.last_commit_message %>
          </blockquote>
          <br />
          <button class="cancel" phx-click="delete">
            Delete
          </button>
        </div>
      </div>
    """
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    server = Servers.get_server!(id)
    socket =
      socket
      |> assign(selected_server: server)
      |> assign(page_title: "#{server.name}")

    {:noreply, socket}
  end

  def handle_params(params, _uri, socket) do
    socket = apply_action(socket, socket.assigns.live_action, params)
    {:noreply, socket}
    end

  def handle_event("save", %{"server" => server_params}, socket) do
    server_params = Map.put(server_params, "last_commit_message", "Server creation.")
    case Servers.create_server(server_params) do
      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
      {:ok, server} ->
        socket =
          socket
          |> update(:servers, fn servers -> [server | servers] end)

        empty_changeset = Servers.change_server(%Server{})
        socket =
          socket
          |> assign(:form, to_form(empty_changeset))
          |> push_patch(to: ~p"/servers/#{server.id}")

      {:noreply, socket}
    end
  end

  def handle_event("delete", _params, socket) do
    Servers.delete_server(socket.assigns.selected_server)
    updated_servers = Servers.list_servers()
    most_recent = hd(updated_servers)
    socket =
      socket
      |> assign(selected_server: most_recent)
      |> assign(servers: updated_servers)
      |> push_patch(to: ~p"/servers/#{most_recent.id}")

    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id" => id} = _params, socket) do
    server = Servers.get_server!(id)
    {:ok, switch} = Servers.toggle_status(server)
    updated = Servers.change_server(switch)
    updated_servers = Servers.list_servers()

    socket =
      socket
      |> assign(selected_server: updated)
      |> assign(servers: updated_servers)
      |> push_patch(to: ~p"/servers/#{switch.id}")

    {:noreply, socket}
  end

  def handle_event("validate", %{"server" => server_params}, socket) do

    changeset =
      %Server{}
      |> Servers.change_server(server_params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(form: to_form(changeset))

    {:noreply, socket}
  end

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def apply_action(socket, :new, _params) do
    socket
    |> assign(form: to_form(Servers.change_server(%Server{})))
    |> assign(selected_server: nil)
  end

  def apply_action(socket, _, _params) do
    assign(socket, selected_server: hd(socket.assigns.servers))
  end
end
