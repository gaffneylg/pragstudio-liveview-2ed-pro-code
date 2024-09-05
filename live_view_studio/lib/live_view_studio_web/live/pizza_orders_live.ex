defmodule LiveViewStudioWeb.PizzaOrdersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.PizzaOrders
  import Number.Currency

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _uri, socket) do
    sort_by = valid_sort_by(params)
    sort_order = valid_sort_order(params)

    options = %{sort_by: sort_by, sort_order: sort_order}

    pizza_orders = PizzaOrders.list_pizza_orders(options)

    socket =
      socket
      |> assign(pizza_orders: pizza_orders)
      |> assign(options: options)


    {:noreply, socket}
  end


  attr :sort_by, :atom, required: true
  attr :options, :map, required: true
  slot :inner_block, required: true

  def sort_link(assigns) do
    ~H"""
      <.link patch={~p"/pizza-orders?#{%{sort_by: @sort_by, sort_order: next_sort_order(@options.sort_order)}}"} >
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
      when sort_by in ~w(id size style topping_1 topping_2 price) do
    String.to_atom(sort_by)
  end

  defp valid_sort_by(_params), do: :id

  defp valid_sort_order(%{"sort_order" => sort_order})
      when sort_order in ~w(asc desc) do
    String.to_atom(sort_order)
  end

  defp valid_sort_order(_params), do: :asc
end
