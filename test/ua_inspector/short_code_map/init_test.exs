defmodule UAInspector.ShortCodeMap.InitTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias UAInspector.ShortCodeMap

  @pathname "something_that_does_not_exist"

  setup do
    app_path = Application.get_env(:ua_inspector, :database_path)

    Application.put_env(:ua_inspector, :database_path, @pathname)

    on_exit(fn ->
      Application.put_env(:ua_inspector, :database_path, app_path)
    end)
  end

  test "log info when load fails (client browsers)" do
    log =
      capture_log(fn ->
        ShortCodeMap.ClientBrowsers.init(:ignored)
        :timer.sleep(100)
      end)

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end

  test "log info when load fails (device brands)" do
    log =
      capture_log(fn ->
        ShortCodeMap.DeviceBrands.init(:ignored)
        :timer.sleep(100)
      end)

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end

  test "log info when load fails (mobile browsers)" do
    log =
      capture_log(fn ->
        ShortCodeMap.MobileBrowsers.init(:ignored)
        :timer.sleep(100)
      end)

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end
end
