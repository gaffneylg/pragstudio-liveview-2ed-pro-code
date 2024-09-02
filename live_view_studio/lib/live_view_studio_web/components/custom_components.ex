defmodule LiveViewStudioWeb.CustomComponents do
  use Phoenix.Component

  attr :expiration, :integer, default: 24
  slot :inner_block, required: true
  slot :legal

  def promo(assigns) do
    ~H"""
      <div class="promo">
        <div class="deal">
          <%= render_slot(@inner_block) %>
        </div>
        <div class="expiration">
          Deal expires in <%= @expiration %> hours.
        </div>
        <div class="legal">
          <%= render_slot(@legal) %>
        </div>
      </div>
    """
  end
end
