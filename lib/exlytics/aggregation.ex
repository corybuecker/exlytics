defmodule Exlytics.Aggregation do
  @moduledoc false
  require Logger

  def rebuild do
    Logger.info("starting stats rebuild")

    remove()
    overall_page_views()
    specific_page_views()
    overall_click_counts()
    specific_click_counts()

    Logger.info("completed stats rebuild")
  end

  defp remove do
    {:ok, %Mongo.DeleteResult{acknowledged: true}} =
      Mongo.delete_many(:mongo, "overall_page_views", %{})

    {:ok, %Mongo.DeleteResult{acknowledged: true}} =
      Mongo.delete_many(:mongo, "specific_page_views", %{})

    {:ok, %Mongo.DeleteResult{acknowledged: true}} =
      Mongo.delete_many(:mongo, "overall_click_counts", %{})

    {:ok, %Mongo.DeleteResult{acknowledged: true}} =
      Mongo.delete_many(:mongo, "specific_click_counts", %{})
  end

  defp overall_page_views do
    Mongo.aggregate(:mongo, "events", [
      %{
        "$match" => %{
          "$and" => [
            %{
              "host" => %{"$in" => ["analytics.corybuecker.com", "exlytics.corybuecker.com"]}
            },
            %{"page" => %{"$exists" => true, "$type" => "string"}}
          ]
        }
      },
      %{
        "$project" => %{
          "event_date" => %{
            "$dateToString" => %{"date" => "$event_timestamp", "format" => "%Y-%m-%d"}
          }
        }
      },
      %{
        "$group" => %{
          "_id" => %{"event_date" => "$event_date"},
          "count" => %{"$sum" => 1}
        }
      },
      %{
        "$project" => %{
          "event_date" => "$_id.event_date",
          "count" => true,
          "_id" => false
        }
      },
      %{
        "$sort" => %{
          "event_date" => 1
        }
      }
    ])
    |> Enum.map(fn a -> a end)
    |> insert_many("overall_page_views")
  end

  defp specific_page_views do
    Mongo.aggregate(:mongo, "events", [
      %{
        "$match" => %{
          "$and" => [
            %{
              "host" => %{"$in" => ["analytics.corybuecker.com", "exlytics.corybuecker.com"]}
            },
            %{"page" => %{"$exists" => true, "$type" => "string"}}
          ]
        }
      },
      %{
        "$project" => %{
          "event_date" => %{
            "$dateToString" => %{"date" => "$event_timestamp", "format" => "%Y-%m-%d"}
          },
          "page" => true
        }
      },
      %{
        "$group" => %{
          "_id" => %{"event_date" => "$event_date", "page" => "$page"},
          "count" => %{"$sum" => 1}
        }
      },
      %{
        "$project" => %{
          "event_date" => "$_id.event_date",
          "page" => "$_id.page",
          "count" => true,
          "_id" => false
        }
      },
      %{
        "$sort" => %{
          "event_date" => 1
        }
      }
    ])
    |> Enum.map(fn a -> a end)
    |> insert_many("specific_page_views")
  end

  defp overall_click_counts do
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
          }
        }
      },
      %{
        "$group" => %{
          "_id" => %{"event_date" => "$event_date"},
          "count" => %{"$sum" => 1}
        }
      },
      %{
        "$project" => %{
          "event_date" => "$_id.event_date",
          "count" => true,
          "_id" => false
        }
      },
      %{
        "$sort" => %{
          "event_date" => 1
        }
      }
    ])
    |> Enum.map(fn a -> a end)
    |> insert_many("overall_click_counts")
  end

  defp specific_click_counts do
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
      },
      %{
        "$sort" => %{
          "event_date" => 1
        }
      }
    ])
    |> Enum.map(fn a -> a end)
    |> insert_many("specific_click_counts")
  end

  defp insert_many(documents, _collection) when documents == [] do
    :ok
  end

  defp insert_many(documents, collection) do
    {:ok,
     %Mongo.InsertManyResult{
       acknowledged: true
     }} = Mongo.insert_many(:mongo, collection, documents)
  end
end
