defmodule Exlytics.Data.Repo.Migrations.CreateMaterializedViews do
  use Ecto.Migration

  def up do
    execute("""
      CREATE VIEW page_views WITH (timescaledb.continuous) AS
      SELECT
        time_bucket ('1day', time) AS day,
        count(1)
      FROM
        events
      WHERE
        metadata ? 'page'
      GROUP BY
        day
      ;
    """)

    execute("""
      CREATE VIEW link_clicks WITH (timescaledb.continuous) AS
      SELECT
        time_bucket ('1day', time) AS day,
        count(1)
      FROM
        events
      WHERE
        metadata ? 'click_link'
      GROUP BY
        day
      ;
    """)

    execute("""
      CREATE VIEW specific_page_views WITH (timescaledb.continuous) AS
      SELECT
        time_bucket ('1day', time) AS day,
        metadata ->> 'page' as page,
        count(1)
      FROM
        events
      WHERE
        (metadata ? 'page')
      GROUP BY
        day,
        page
      ;
    """)

    execute("""
      CREATE VIEW specific_link_clicks WITH (timescaledb.continuous) AS
      SELECT
        time_bucket ('1day', time) AS day,
        metadata ->> 'click_link' as click_link,
        count(1)
      FROM
        events
      WHERE
        metadata ? 'click_link'
      GROUP BY
        day,
        click_link
      ;
    """)
  end

  def down do
    execute("drop view if exists page_views cascade;")
    execute("drop view if exists specific_page_views cascade;")
    execute("drop view if exists link_clicks cascade;")
    execute("drop view if exists specific_link_clicks cascade;")
  end
end