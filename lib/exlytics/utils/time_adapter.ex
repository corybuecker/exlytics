defmodule Exlytics.Utils.TimeAdapter do
  @moduledoc false

  def current_time do
    DateTime.now!("Etc/UTC")
  end
end
