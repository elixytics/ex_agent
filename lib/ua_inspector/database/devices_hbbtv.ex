defmodule UAInspector.Database.DevicesHbbTV do
  @moduledoc false

  use UAInspector.Database

  alias UAInspector.Config
  alias UAInspector.Util

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def sources do
    [{"", "device.televisions.yml", Config.database_url(:device, "televisions.yml")}]
  end

  def to_ets({brand, data}, type) do
    data = Enum.into(data, %{})
    models = parse_models(data)

    %{
      brand: brand,
      models: models,
      device: data["device"],
      regex: Util.build_regex(data["regex"]),
      type: type
    }
  end

  defp parse_models(data) do
    device = data["device"]

    if data["model"] do
      [
        %{
          brand: nil,
          device: device,
          model: data["model"] || "",
          regex: Util.build_regex(data["regex"])
        }
      ]
    else
      Enum.map(data["models"], fn model ->
        model = Enum.into(model, %{})

        %{
          brand: model["brand"],
          device: model["device"] || device,
          model: model["model"] || "",
          regex: Util.build_regex(model["regex"])
        }
      end)
    end
  end
end
