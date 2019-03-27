\name{cql}
\alias{cql}
\title{ChartQL Chart Generator}
\usage{
cql(source_frame, cql_string)
}
\description{
Generates a chart/plot using \code{source_frame} as the source dataframe and using \code{cql_string} as the query string. Options and structure of the query string are described below
}
\arguments{
\item{source_frame}{DataFrame object. Used as the source to build the plot.}
\item{cql_string}{ChartQL query string. Used to specify options in terms of how to build the plot. This includes the type of plot, choice of x and y variables, axis titles and more. Full parameter list below.}
}
\details{
The ChartQL query language uses a fairly simple format to let users generate amazing plots but with minimal scripting, allowing for much faster prototyping. The ChartQL string uses the following general format:

\code{CHART <chart_type> X <x_var> Y <y_var> (Options) <options>}

The main variables that are required for all types of plots are:


\tabular{rllll}{
\bold{Chart} chart_type: \tab\tab\tab\tab \code{bar|scatter|hist|line}\cr
\bold{X} x_var, (x_facet): \tab\tab\tab\tab  X-axis variable. May include a second categorical\cr
\tab\tab\tab\tab variable (comma separated)\cr
\bold{Y} y_var: \tab\tab\tab\tab Y-axis variable. *Not used for \code{hist}.\cr
}


\bold{Optional Variables}

\tabular{rllll}{
\bold{X_label} '<xlab>': \tab\tab\tab\tab  X-axis custom label. Defaults to <x_var>\cr
\bold{Y_label} '<ylab>': \tab\tab\tab\tab  Y-axis custom label. Defaults to <y_var>\cr
\bold{Legend} '<legend>': \tab\tab\tab\tab  Legend custom label. Defaults to <x_category>\cr
\bold{Colorset} '<clist>': \tab\tab\tab\tab  Custom set of colors for <x_category> levels.\cr
\tab\tab\tab\tab Must be comma-separated list.\cr
\bold{AggFunc} '<func>': \tab\tab\tab\tab Summary function for \code{bar} type.\cr
\tab\tab\tab\tab Valid types: \code{mean|median|count|sum}.\cr
\tab\tab\tab\tab Defaults to \code{mean}.
}

}
\examples{
# Bar chart with product category on x-axis and total sales on y-axis
cql_str <- "CHART bar X category Y sales";
cql(dframe, cql_str);
   
   
# Bar chart but facet x-axis with both category and season of the year
cql_str <- "CHART bar X category, season Y sales";
cql(dframe, cql_str);


# Bar chart but specify the colors for each season
cql_str <- "CHART bar X category, season Y sales Colorset '#FF9900, #990099, #BBBBBB, #33CC99'";
cql(dframe, cql_str);
   
   
# Scatter plot of square footage of house and house price
cql_str <- "CHART scatter X square_foot Y price";
cql(dframe, cql_str);


# Scatter plot but facet by state
cql_str <- "CHART scatter X square_foot, state Y price";
cql(dframe, cql_str);
}
