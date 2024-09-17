defmodule LiveViewStudioWeb.PizzaOrdersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.PizzaOrders
  import Number.Currency

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [pizza_orders: []]}
  end

  def handle_params(params, _uri, socket) do
    sort_by = valid_sort_by(params)
    sort_order = valid_sort_order(params)

    page = (params["page"] || "1") |> Integer.parse() |> param_to_int(1)
    per_page = (params["per_page"] || "10") |> Integer.parse() |> param_to_int(10)

    options = %{
      sort_by: sort_by,
      sort_order: sort_order,
      page: page,
      per_page: per_page
    }

    pizza_orders = PizzaOrders.list_pizza_orders(options)
    count = PizzaOrders.count_orders()

    socket =
      socket
      |> assign(pizza_orders: pizza_orders)
      |> assign(options: options)
      |> assign(order_count: count)
      |> assign(more_pages: more_pages?(options, count))

    {:noreply, socket}
  end

  def handle_event("per-page", %{"per-page" => per_page}, socket) do
    params = socket.assigns.options

    socket = push_patch(socket, to: ~p"/pizza-orders?#{%{params | per_page: per_page}}")

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

  defp more_pages?(options, count) do
    options.page * options.per_page < count
  end

  defp pages(options, count) do
    page_count = ceil(count/ options.per_page)

    for page_number <- (options.page - 2)..(options.page + 2),
        page_number > 0 do
      if page_number <= page_count do
        current_page? = page_number == options.page
        {page_number, current_page?}
      end
    end
  end

  defp param_to_int(nil, default), do: default
  defp param_to_int(:error, default), do: default
  defp param_to_int({page, _}, _), do: page

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
