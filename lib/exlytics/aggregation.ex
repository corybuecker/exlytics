defmodule Exlytics.Aggregation do
  @moduledoc false
  require Logger

  def remove do
    {:ok, %Mongo.DeleteResult{acknowledged: true, deleted_count: count}} =
      Mongo.delete_many(:mongo, "aggregations", %{})

    Logger.info("deleted #{count} documents")
  end

  def overall_page_counts do
    counts =
      Mongo.find(:mongo, "events", %{
        "host" => %{"$in" => ["analytics.corybuecker.com", "exlytics.corybuecker.com"]}
      })
      |> Enum.reduce(%{}, fn event, acc ->
        acc
        |> Map.update(
          event["event_timestamp"] |> DateTime.to_date() |> Date.to_iso8601(),
          1,
          fn a -> a + 1 end
        )
      end)

    Mongo.insert_one(:mongo, "aggregations", %{"overall_page_counts" => counts})
  end

  def overall_click_counts do
    counts =
      Mongo.find(:mongo, "events", %{
        "$and" => [
          %{"host" => %{"$in" => ["analytics.corybuecker.com", "exlytics.corybuecker.com"]}},
          %{"click_link" => %{"$exists" => true, "$type" => "string"}}
        ]
      })
      |> Enum.reduce(%{}, fn event, acc ->
        acc
        |> Map.update(
          event["event_timestamp"] |> DateTime.to_date() |> Date.to_iso8601(),
          1,
          fn a -> a + 1 end
        )
      end)

    Mongo.insert_one(:mongo, "aggregations", %{"overall_click_counts" => counts})
  end

  def specific_click_counts do
    counts =
      Mongo.aggregate(:mongo, "events", [
        %{
          "$match" => %{
            "$and" => [
              %{
                "host" => %{"$in" => ["analytics.corybuecker.com", "exlytics.corybuecker.com"]}
              },
              %{"click_link" => %{"$exists" => true, "$type" => "string"}}
            ]
          }
        },
        %{
          "$project" => %{
            "event_date" => %{
              "$dateToString" => %{"date" => "$event_timestamp", "format" => "%Y-%m-%d"}
            },
            "click_link" => true
          }
        },
        %{
          "$group" => %{
            "_id" => %{"event_date" => "$event_date", "click_link" => "$click_link"},
            "count" => %{"$sum" => 1}
          }
        },
        %{
          "$project" => %{
            "event_date" => "$_id.event_date",
            "click_link" => "$_id.click_link",
            "count" => true,
            "_id" => false
          }
        }
      ])
      |> Enum.each(&Logger.info/1)
  end
end
