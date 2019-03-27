cql <- function(dframe, quick_str, colorlist) {
  require(ggplot2)
  require(stringr)
  mystr = quick_str
  #... do more versatile checking so that order doesn't matter

  pattset = c("chart\\s+(bar|scatter|hist|line)(?:\\s+|$)",
              "X\\s+([A-Za-z][A-Za-z0-9_\\.]*?)( *, *([A-Za-z][A-Za-z0-9_\\.]*?))?(?:\\s+|$)",
              "Y\\s+([A-Za-z][A-Za-z0-9_\\.]*?)(?:\\s+|$)",
              "X_label\\s+'(.*?)'(?:\\s+|$)",
              "Y_label\\s+'(.*?)'(?:\\s+|$)",
              "Legend\\s+'(.*?)'(?:\\s+|$)",
              "Colorset\\s+'(.*?)'(?:\\s+|$)",
              "AggFunc\\s+'(.*?)'(?:\\s+|$)");

  vars = list();
  msgs = list(); #... output messages
  
  aggfunc <- function(x) {
    agg = vars[["aggfunc"]];
    if(agg=="mean") {
      return (mean(x, na.rm=TRUE))
    }
    else if(agg=="sum") {
      return (sum(x, na.rm=TRUE))
    }
    else if(agg=="median") {
      return (median(x, na.rm=TRUE))
    }
    else if(agg=="count") {
      return (length(x[!is.na(x)]))
    }
  }

  counter=0;
  while(TRUE) {
    earliest_found = nchar(mystr)+1;
    best_res = NULL;
    best_loc = NULL;
    best_idx = -1;
    for(i in 1:length(pattset)) {
      patt = paste("(?i)",pattset[i],sep="");
      results = str_match(mystr, patt)[1,];
      loc_point = str_locate(mystr, patt);
      if(!is.na(loc_point[1,c("start")])) {
        #... this is a valid pattern
        curfound =  as.numeric(loc_point[1,c('start')]);
        if(curfound<earliest_found) {
          earliest_found = curfound;
          best_res = results;
          best_loc = loc_point;
          best_idx = i;
        }
      }
    }

    if(best_idx==-1) {
      break;
    }


    mystr = substr(mystr, as.numeric(best_loc[1,c("end")]), nchar(mystr));
    results = best_res;
    i = best_idx;
    vars[["aggfunc"]] = "mean";
    if(i==1) {
      #... chart type
      vars[["type"]] = results[2];
    }
    else if(i==2) {
      #... x variable(s)
      vars[["x_var"]] = results[2];
      if(!is.na(results[3])) {
        vars[["x_category"]] = results[4];
      }
    }
    else if(i==3) {
      #... y variable
      vars[["y_var"]] = results[2];
    }
    else if(i==4) {
      #... x label variable
      vars[["x_label"]] = str_replace_all(results[2], "\\\\n", intToUtf8(10));
    }
    else if(i==5) {
      #... y label variable
      vars[["y_label"]] = str_replace_all(results[2], "\\\\n", intToUtf8(10));
    }
    else if(i==6) {
      #... legend label variable
      vars[["legend"]] = str_replace_all(results[2], "\\\\n", intToUtf8(10));
    }
    else if(i==7) {
      #... colorset variable
      vars[["colorset"]] = str_split(gsub(" ", "", results[2]), ",")[[1]];
    }
    else if(i==8) {
      #... barchart aggregating variable
      vars[["aggfunc"]] = str_split(gsub(" ", "", results[2]), ",")[[1]];
    }
    

    counter = counter + 1;
    if(counter>200) {
      #print ("Malformed String");
      return (list("response"="Malformed String", "plot_obj"=NULL));
      break
    }
  }



  if (!("type" %in% names(vars))) {
    print ("Invalid chart type specified");
    return (list("response"=msgs, "plot_obj"=NULL));
  }

  ctype = vars[["type"]];
  x1_var = vars[["x_var"]];
  x2_var = vars[["x_category"]];
  y_var = vars[["y_var"]];
  legend = vars[["legend"]];
  if(!("x_label" %in% names(vars))) {
    vars[["x_label"]] = x1_var;
  }
  if(!("y_label" %in% names(vars))) {
    vars[["y_label"]] = y_var;
  }
  if(!("legend" %in% names(vars))) {
    vars[["legend"]] = x2_var;
  }
  if(ctype=="hist") {
    vars[["y_label"]] = "Count";
  }
  p1 = NULL;


  if(is.null(x1_var) | is.null(y_var)) {
    return (list("response"="Malformed String", "plot_obj"=p1));
  }

  #   SCATTER: generate the plot
  if(ctype=="scatter") {
    p1 = ggplot(data=dframe, aes_string(x=x1_var, y=y_var)) + geom_point();
    if(!is.null(x2_var)) {
      dframe[,c(x2_var)] = factor(dframe[,c(x2_var)]);
      p1 = ggplot(data=dframe, aes_string(x=x1_var, y=y_var, color=x2_var)) + geom_point();
      if(!is.null(vars[["colorset"]])) {
        p1 <- p1 + scale_color_manual(values=vars[["colorset"]])
      }
      if(vars[["legend"]]!="<>") {
        p1 <- p1 + guides(color=guide_legend(title=vars[["legend"]]))
      }
    }
  }


  #   LINE: generate the plot
  if(ctype=="line") {
    p1 = ggplot(data=dframe, aes_string(x=x1_var, y=y_var)) + geom_line()
    if(!is.null(x2_var)) {
      dframe[,c(x2_var)] = factor(dframe[,c(x2_var)]);
      p1 = ggplot(data=dframe, aes_string(x=x1_var, y=y_var, color=x2_var)) + geom_line()
      if(!is.null(vars[["colorset"]])) {
        p1 <- p1 + scale_color_manual(values=vars[["colorset"]])
      }
      if(vars[["legend"]]!="<>") {
        p1 <- p1 + guides(color=guide_legend(title=vars[["legend"]]))
      }
    }
  }


  #   BAR: generate the plot
  if(ctype=="bar") {
    dframe[,c(x1_var)] = factor(dframe[,c(x1_var)]);
    p1 = ggplot(data=dframe, aes_string(x=x1_var, y=y_var)) +
      geom_bar(stat="summary", position="dodge", fun.y=aggfunc);
    if(!is.null(x2_var)) {
      dframe[,c(x2_var)] = factor(dframe[,c(x2_var)]);
      p1 = ggplot(data=dframe, aes_string(x=x1_var, y=y_var, fill=x2_var)) +
        geom_bar(stat="summary", position="dodge", fun.y=aggfunc);
      if(!is.null(vars[["colorset"]])) {
        p1 <- p1 + scale_fill_manual(values=vars[["colorset"]])
      }
      if(vars[["legend"]]!="<>") {
        p1 <- p1 + guides(fill=guide_legend(title=vars[["legend"]]))
      }
    }
  }



  #   HIST: generate the plot
  if(ctype=="hist") {
    p1 = ggplot(data=dframe, aes_string(x=x1_var))+
      geom_histogram(position="identity", bins=50);
    if(!is.null(x2_var)) {
      dframe[,c(x2_var)] = factor(dframe[,c(x2_var)]);
      p1 = ggplot(data=dframe, aes_string(x=x1_var, fill=x2_var)) +
        geom_histogram( position="identity", alpha=0.9);
      if(!is.null(vars[["colorset"]])) {
        p1 <- p1 + scale_fill_manual(values=vars[["colorset"]])
      }
      if(vars[["legend"]]!="<>") {
        p1 <- p1 + guides(fill=guide_legend(title=vars[["legend"]]))
      }
    }
  }


  #   Finalize the parameters and output
  if(!is.null(p1)) {
    p1 <- p1 + theme(text = element_text(size=16))+
      xlab(vars[["x_label"]]) + ylab(vars[["y_label"]]);
    if(!is.null(vars[["legend"]])) {
      if(vars[["legend"]]=="<>") {
        p1 <- p1 + guides(fill=FALSE);
      }
    }
    p1
  }
  return (list("response"=vars, "plot_obj"=p1));

}