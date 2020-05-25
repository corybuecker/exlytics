import "phoenix";

interface DataPoints {
  data: Array<DataPoint>;
}

interface DataPoint {
  date: string;
  count: number | undefined;
}

const margin = { top: 50, right: 20, bottom: 60, left: 90 },
  width = 1000 - margin.left - margin.right,
  height = 600 - margin.top - margin.bottom;

const writeChart = async (d3, url, element): Promise<boolean> => {
  const time = d3.timeParse("%Y-%m-%d");
  const timeFormat = d3.timeFormat("%Y-%m-%d");

  const svg = d3
    .create("svg")
    .attr("viewBox", [0, 0, width, height])
    .attr("fill", "none")
    .attr("stroke-linejoin", "round")
    .attr("stroke-linecap", "round");

  return d3.json(url).then((dataPoints: DataPoints) => {
    const data = dataPoints.data;
    const [firstDate, lastDate] = d3.extent(data, (d) => time(d.date));
    const timeDomain = d3.timeDay.every(1).range(firstDate, lastDate);
    const allPresentDates: Array<number> = data.map((d) =>
      time(d.date).getTime()
    );

    const missingDates = timeDomain.filter(
      (x: Date) => !allPresentDates.includes(x.getTime())
    );

    missingDates.forEach((element: Date) => {
      data.push({ date: timeFormat(element), count: undefined });
    });

    data.sort((d1, d2) => time(d1.date) > time(d2.date));

    const x = d3
      .scaleTime()
      .domain([firstDate, lastDate])
      .range([margin.left, width - margin.right]);

    const xAxis = (
      g: d3.Selection<SVGGElement, {}, HTMLElement, {}>
    ): d3.Selection<SVGGElement, {}, HTMLElement, {}> =>
      g.attr("transform", `translate(0,${height - margin.bottom})`).call(
        d3
          .axisBottom(x)
          .ticks(width / 80)
          .tickSizeOuter(0)
      );

    const y = d3
      .scaleLinear()
      .domain([0, d3.max(data, (d: DataPoint) => d.count)])
      .nice()
      .range([height - margin.bottom, margin.top]);

    const yAxis = (
      g: d3.Selection<SVGGElement, {}, HTMLElement, {}>
    ): d3.Selection<SVGGElement, {}, HTMLElement, {}> =>
      g.attr("transform", `translate(${margin.left},0)`).call(d3.axisLeft(y));

    const line = d3
      .line()
      .defined((d: DataPoint) => d.count != undefined)
      .x((d: DataPoint) => x(time(d.date)))
      .y((d: DataPoint) => y(d.count));

    svg.append("g").call(xAxis);
    svg.append("g").call(yAxis);

    svg
      .append("path")
      .datum(data.filter(line.defined()))
      .attr("stroke", "#ccc")
      .attr("d", line);

    svg
      .append("path")
      .datum(data)
      .attr("stroke", "steelblue")
      .attr("stroke-width", 2)
      .attr("d", line);

    d3.select(element).node().appendChild(svg.node());
    return true;
  });
};

const initializeCharts = (): boolean => {
  import(/* webpackChunkName: "d3" */ "d3").then((d3) => {
    writeChart(d3, "/api/page_views", "#page_views");
    writeChart(d3, "/api/link_clicks", "#link_clicks");
  });
  return true;
};

document.addEventListener("DOMContentLoaded", initializeCharts);