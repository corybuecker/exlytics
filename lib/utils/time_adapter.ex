defmodule Exlytics.Utils.TimeAdapter do
  def current_time do
    DateTime.now!("Etc/UTC")
  end
end
