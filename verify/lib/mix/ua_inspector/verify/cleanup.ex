defmodule Mix.UAInspector.Verify.Cleanup do
  @moduledoc """
  Cleans up testcases.
  """

  @empty_to_quotes [
    [:bot, :category],
    [:bot, :producer, :name],
    [:bot, :producer, :url],
    [:bot, :url]
  ]

  @empty_to_unknown [
    [:client],
    [:client, :engine],
    [:client, :engine_version],
    [:client, :version],
    [:device, :brand],
    [:device, :model],
    [:device, :type],
    [:os, :platform],
    [:os, :version]
  ]

  @number_to_string [
    [:client, :engine_version],
    [:client, :version],
    [:device, :brand],
    [:device, :model],
    [:os, :version]
  ]

  @unknown_to_atom [
    [:browser_family],
    [:os_family]
  ]

  @doc """
  Cleans up a test case.
  """
  @spec cleanup(testcase :: map) :: map
  def cleanup(testcase) do
    testcase
    |> convert_empty(@empty_to_quotes, "")
    |> convert_empty(@empty_to_unknown, :unknown)
    |> convert_numbers(@number_to_string)
    |> convert_unknown(@unknown_to_atom)
    |> cleanup_client_engine()
    |> cleanup_client_engine_version()
    |> cleanup_os_entry()
    |> remove_unknown_device()
  end

  defp convert_empty(testcase, [], _), do: testcase

  defp convert_empty(testcase, [path | paths], replacement) do
    testcase
    |> get_in(path)
    |> case do
      :null -> put_in(testcase, path, replacement)
      "" -> put_in(testcase, path, replacement)
      _ -> testcase
    end
    |> convert_empty(paths, replacement)
  rescue
    FunctionClauseError -> convert_empty(testcase, paths, replacement)
  end

  defp convert_numbers(testcase, []), do: testcase

  defp convert_numbers(testcase, [path | paths]) do
    testcase
    |> get_in(path)
    |> case do
      v when is_number(v) -> put_in(testcase, path, to_string(v))
      _ -> testcase
    end
    |> convert_numbers(paths)
  rescue
    FunctionClauseError -> convert_numbers(testcase, paths)
  end

  defp convert_unknown(testcase, []), do: testcase

  defp convert_unknown(testcase, [path | paths]) do
    testcase
    |> get_in(path)
    |> case do
      "Unknown" -> put_in(testcase, path, :unknown)
      _ -> testcase
    end
    |> convert_unknown(paths)
  end

  defp cleanup_client_engine(%{client: client} = testcase) when is_map(client) do
    client =
      if Map.has_key?(client, :engine) do
        client
      else
        Map.put(client, :engine, :unknown)
      end

    %{testcase | client: client}
  end

  defp cleanup_client_engine(testcase), do: testcase

  defp cleanup_client_engine_version(%{client: client} = testcase) when is_map(client) do
    client =
      if Map.has_key?(client, :engine_version) do
        client
      else
        Map.put(client, :engine_version, :unknown)
      end

    %{testcase | client: client}
  end

  defp cleanup_client_engine_version(testcase), do: testcase

  defp cleanup_os_entry(%{os: os} = testcase) do
    os =
      case Map.keys(os) do
        [] -> :unknown
        _ -> os
      end

    %{testcase | os: os}
  end

  defp cleanup_os_entry(testcase), do: testcase

  defp remove_unknown_device(
         %{device: %{type: :unknown, brand: :unknown, model: :unknown}} = result
       ) do
    %{result | device: :unknown}
  end

  defp remove_unknown_device(result), do: result
end
