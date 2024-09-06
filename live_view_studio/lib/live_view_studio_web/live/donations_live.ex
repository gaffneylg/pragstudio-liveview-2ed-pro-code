defmodule LiveViewStudioWeb.DonationsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _uri, socket) do
    sort_by = valid_sort_by(params)
    sort_order = valid_sort_order(params)

    page = (params["page"] || "1") |> String.to_integer()
    per_page = (params["per_page"] || "10") |> String.to_integer()

    options = %{
      sort_by: sort_by,
      sort_order: sort_order,
      page: page,
      per_page: per_page
    }

    donations = Donations.list_donations(options)

    socket =
      socket
      |> assign(donations: donations)
      |> assign(options: options)

    {:noreply, socket}
  end

  def handle_event("per-page", %{"per-page" => per_page}, socket) do
    params = socket.assigns.options

    socket = push_patch(socket, to: ~p"/donations?#{%{params | per_page: per_page}}")

    {:noreply, socket}
  end

  attr :sort_by, :atom, required: true
  attr :options, :map, required: true
  slot :inner_block, required: true

  def sort_link(assigns) do
    params = %{
      assigns.options
      | sort_by: assigns.sort_by,
        sort_order: next_sort_order(assigns.options.sort_order)}

    assigns = assign(assigns, params: params)

    ~H"""
    <.link patch={
      ~p"/donations?#{@params}"
    }>
      <%= render_slot(@inner_block) %>
      <%= sort_arrow(@sort_by, @options) %>
    </.link>
    """
  end

  # =================================================================
  # Private functions
  # =================================================================

  defp next_sort_order(:asc), do: :desc
  defp next_sort_order(:desc), do: :asc

  defp sort_arrow(column, %{sort_by: sort_by, sort_order: sort_order})
       when column == sort_by do
    arrow(sort_order)
  end

  defp sort_arrow(_, _), do: ""

  defp arrow(:asc), do: "⬆"
  defp arrow(:desc), do: "⬇"

  defp valid_sort_by(%{"sort_by" => sort_by})
       when sort_by in ~w(item quantity days_until_expires) do
    String.to_atom(sort_by)
  end

  defp valid_sort_by(_params), do: :id

  defp valid_sort_order(%{"sort_order" => sort_order})
       when sort_order in ~w(asc desc) do
    String.to_atom(sort_order)
  end

  defp valid_sort_order(_params), do: :asc
end
