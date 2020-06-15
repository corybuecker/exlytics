user_agents = [
  "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.24 (KHTML, like Gecko) Chrome/12.0.702.0 Safari/534.24",
  "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.0; Trident/5.0; chromeframe/11.0.696.57)",
  "Opera/9.80 (X11; Linux i686; U; it) Presto/2.7.62 Version/11.00"
]

pages = [
  "/test",
  "/test_2",
  "/not_here",
  nil
]

Enum.each(0..2000, fn _ ->
  {:ok, datetime} =
    with {:ok, date} <- Date.new(Enum.random(2018..2020), Enum.random(1..12), Enum.random(1..28)),
         {:ok, time} <- Time.new(Enum.random(0..23), Enum.random(0..59), Enum.random(0..59), 0),
         {:ok, datetime} <- NaiveDateTime.new(date, time) do
      DateTime.from_naive(datetime, "Etc/UTC")
    end

  %Exlytics.Data.Event{
    time: datetime,
    metadata: %{
      account_id: "3ecfe3ec-8a01-4a3a-8982-1b6248af39a7",
      host: "exlytics.corybuecker.com",
      user_agent: user_agents |> Enum.random(),
      page: pages |> Enum.random()
    }
  }
  |> Exlytics.Data.Repo.insert!()
end)
