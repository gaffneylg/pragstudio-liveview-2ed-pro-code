defmodule LiveViewStudioWeb.SandboxLive do
  use LiveViewStudioWeb, :live_view

  import Number.Currency
  alias LiveViewStudio.Sandbox, as: SB

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(length: "0", width: "0", depth: "0", cost: nil, weight: 0.0)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Build A Sandbox</h1>
    <div id="sandbox">
      <form phx-change="calculate" phx-submit="get-quote">
        <div class="fields">
          <div>
            <label for="length">Length</label>
            <div class="input">
              <input type="number" name="length" value={@length} />
              <span class="unit">feet</span>
            </div>
          </div>
          <div>
            <label for="width">Width</label>
            <div class="input">
              <input type="number" name="width" value={@width} />
              <span class="unit">feet</span>
            </div>
          </div>
          <div>
            <label for="depth">Depth</label>
            <div class="input">
              <input type="number" name="depth" value={@depth} />
              <span class="unit">inches</span>
            </div>
          </div>
        </div>
        <div class="weight">
          You need <%= @weight %> pounds of sand 🏝
        </div>
        <button type="submit">
          Get A Quote
        </button>
      </form>
      <div :if={@cost} class="quote">
        Get your personal beach today for only
        <%= number_to_currency(@cost) %>
      </div>
    </div>
    """
  end

  def handle_event("calculate", params, socket) do
    %{"length" => length, "width" => width, "depth" => depth} = params
    weight = SB.calculate_weight(length, width, depth)
    socket =
      socket
      |> assign(weight: weight)
      |> assign(length: length)
      |> assign(width: width)
      |> assign(depth: depth)
      |> assign(cost: nil)
    {:noreply, socket}
  end

  def handle_event("get-quote", _params, socket) do
    cost = SB.calculate_price(socket.assigns.weight)
    socket =
      socket
      |> assign(cost: cost)

    {:noreply, socket}
  end
end
