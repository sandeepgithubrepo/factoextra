#' @include utilities.R dist.R
NULL
#' Assessing Clustering Tendency
#' 
#' @description Assess clustering tendency using Hopkins' statistic and visual approach. 
#' An ordered dissimilarity image (ODI) is shown. Objects belonging to the same cluster are displayed in consecutive order 
#' using hierarchical clustering. 
#' @param data a numeric data frame or matrix. Columns are variables and rows are samples. 
#' Computation are done on rows (samples) by default. If you want to calculate Hopkins statistic on 
#' variables, transpose the data before.
#' @param n the number of points selected from sample space which is also the number of 
#' points selected from the given sample(data).
#' @param graph logical value; if TRUE the ordered dissimilarity image (ODI) is shown.
#' @param gradient a list containing three elements specifying the colors for low, mid and high values in 
#'  the ordered dissimilarity image. The element "mid" can take the value of NULL.
#' @param seed an integer specifying the seed for random number generator. Specify seed for reproducible results.
#' @return 
#' A list containing the elements: \cr\cr
#' - hopkins_stat for Hopkins statistic value\cr\cr
#' - plot for ordered dissimilarity image. This is generated using the function fviz_dist(dist.obj).\cr
#' 
#' @examples 
#' \donttest{
#' data(iris)
#' 
#' # Clustering tendency
#' get_clust_tendency(iris[,-5], 50)
#' 
#' # Customize the dissimilarity image
#' fviz_dist(dist(iris[, -5]), 
#'    gradient = list(low = "black", mid = NULL, high = "white"))
#' }
#' @export
get_clust_tendency <- function(data, n, graph = TRUE,
                               gradient = list(low = "red", mid = "white", high = "blue"),
                               seed = 123) 
{
  
  set.seed(seed)
  if (is.data.frame(data)) 
    data <- as.matrix(data)
  if (!(is.matrix(data))) 
    stop("data must be data.frame or matrix")
  if (n >= nrow(data)) 
    stop("n must be no larger than num of samples")
  if (!requireNamespace("reshape2", quietly = TRUE)) {
    stop("reshape2 package needed for this function to work. Please install it.")
   }
  
  data <- na.omit(data)
  rownames(data) <- paste0("r", 1:nrow(data))
  plot <- NULL
  if(graph){
    plot <- fviz_dist(dist(data), order = TRUE, 
                      show_labels = FALSE)
    print(plot)
  }
  
  # Hopkins statistic
  p <- apply(data, 2, function(x, n){runif(n, min(x), max(x))}, n)

  
  k <- round(runif(n, 1, nrow(data)))
  q <- as.matrix(data[k, ])
  distp = rep(0, nrow(data))
  distq = 0
  minp = rep(0, n)
  minq = rep(0, n)
  for (i in 1:n) {
    distp[1] <- dist(rbind(p[i, ], data[1, ]))
    minqi <- dist(rbind(q[i, ], data[1, ]))
    for (j in 2:nrow(data)) {
      distp[j] <- dist(rbind(p[i, ], data[j, ]))
      error <- q[i, ] - data[j, ]
      if (sum(abs(error)) != 0) {
        distq <- dist(rbind(q[i, ], data[j, ]))
        if (distq < minqi) 
          minqi <- distq
      }
    }
    minp[i] <- min(distp)
    minq[i] <- minqi
  }
  
  list(hopkins_stat = sum(minq)/(sum(minp) + sum(minq)), plot = plot)
}