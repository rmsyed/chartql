# chartql Documentation

## Description
ChartQL uses a very simple syntax for the user to specify what kind of plot(s) they want to generate without having to remember complicated syntax. The ChartQL library uses ggplot2 and manages all the syntax complexities internally. As an example, to generate a bar chart of company sales faceted by product category further faceted by season of the year, we simply write:

> **CHART** bar **X** category, season **Y** sales

## Usage

 ```cql (source_frame, cql_string)```


| Parameter | Description |
| --- | --- |
|source_frame |	DataFrame object. Used as the source to build the plot.|
|cql_string	| ChartQL query string. Used to specify options in terms of how to build the plot. This includes the type of plot, choice of x and y variables, axis titles and more. Full parameter list below.

## Details

The ChartQL query language uses a fairly simple format to let users generate amazing plots but with minimal scripting, allowing for much faster prototyping. The ChartQL string uses the following general format:

> **CHART** <chart_type> **X** <x_var> **Y** <y_var> (Options) \<options>

The main variables that are required for all types of plots are:

| Prefix | Argument | Description |
| --- | --- | --- |
|**Chart** |	<chart_type> |	```bar \| scatter \| hist \| line```|
|**X**|  <x_var>, (<x_facet>) |				X-axis variable. May include a second categorical variable (comma separated)|
|**Y** | y_var |				Y-axis variable. *Not used for hist.|

#### Optional Variables

All optional variable values must be enclosed in single-quotes.

| Prefix | Argument | Description |
| --- | --- | --- |
|**X_label** | '\<xlab>' |	X-axis custom label. Defaults to ```<x_var>```|
|**Y_label** | '\<ylab>' |	Y-axis custom label. Defaults to ```<y_var>```|
|**Legend** | '\<legend>' |	Legend custom label. Defaults to ```<x_category>```|
|**Colorset** | '\<clist>' |	Custom set of colors for ```<x_category>``` levels. Must be comma-separated list.|
|**AggFunc** | '\<func>' |	Summary function for bar type. <br />Valid types: ```mean \| median \| count \| sum```<br />Defaults to ```mean```.|


## Examples

\# Bar chart with product category on x-axis and total sales on y-axis

```python
cql_str <- "CHART bar X category Y sales";
cql(dframe, cql_str);
```


\# Bar chart but facet x-axis with both category and season of the year

```python
cql_str <- "CHART bar X category, season Y sales";
cql(dframe, cql_str);
```

\# Bar chart but specify the colors for each season

```ruby
cql_str <- "CHART bar X category, season Y sales 
Colorset '#FF9900, #990099, #BBBBBB, #33CC99'";
cql(dframe, cql_str);
```   
   
\# Scatter plot of square footage of house and house price

```python
cql_str <- "CHART scatter X square_foot Y price";
cql(dframe, cql_str);
```

\# Scatter plot but facet by state

```python
cql_str <- "CHART scatter X square_foot, state Y price";
cql(dframe, cql_str);
```

## Contact
For any feedback, bug reports or questions, please contact: rohailsyed@gmail.com
