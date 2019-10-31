# ---
# title: "Collecting Twitter Data using rtweet (workshop material)"
# author: "Justin Ho"
# last updated: "30/10/2019"
# ---

################################################################
#                           Setting Up                         #
################################################################

# Install the library
install.packages("rtweet")
install.packages("quanteda")

# Load the library
library(rtweet)

# Copy and paste these from your developer account
api_key <- "lLkH2H1fe9MqfGDlSs80Ao8VN"
api_secret_key <- "uQJCGYS1YKSxQc1SjD1WpcsPM2gnfXpIFrYdmjXwJfLEmUNCUb"
access_token <- "1189518014959493121-4ih6Bwz2vFMuIpYJo2T3WuzjMuX5e8"
access_token_secret <- "fqclBPkWyxz3t0msM7E6rVaHnFoexFjenT00neXNs18qc"

token <- create_token(
  app = "uped",
  consumer_key = api_key,
  consumer_secret = api_secret_key,
  access_token = access_token,
  access_secret = access_token_secret)

################################################################
#                      Search by Keywords                      #
################################################################

tweets <- search_tweets("#Brexit", n = 1000, retryonratelimit = FALSE)

library(quanteda)
corpus <- corpus(tweets, text_field = "text")
dfm <- dfm(corpus, remove_punct = TRUE, remove = stopwords("english"))
textplot_wordcloud(dfm)

################################################################
#                     Search by User Handles                   #
################################################################

# Specifying the user handles
user_handles <- c("@UKLabour","@Conservatives", "@LibDems", "@theSNP")

# Getting user timelines by handle
tmls <- get_timelines(user_handles, n = 200)

# Simple visualisation
tmls %>%
  dplyr::group_by(screen_name) %>%
  ts_plot("days", trim = 1L) +
  ggplot2::geom_point() +
  ggplot2::theme_minimal() +
  ggplot2::theme(
    legend.title = ggplot2::element_blank(),
    legend.position = "bottom",
    plot.title = ggplot2::element_text(face = "bold")) +
  ggplot2::labs(
    x = NULL, y = NULL,
    title = "Frequency of Twitter statuses posted by UK Political Parties",
    subtitle = "Twitter status (tweet) counts aggregated by day",
    caption = "\nSource: Justin Chun-ting Ho"
  )


################################################################
#                          Streaming                           #
################################################################

# Stream keywords used to filter tweets
q <- "Trump"

# Stream time in seconds so for one minute set timeout = 60
# For larger chunks of time, I recommend multiplying 60 by the number
# of desired minutes. This method scales up to hours as well
# (x * 60 = x mins, x * 60 * 60 = x hours)
# Stream for 30 minutes
streamtime <- 2 * 60

# Filename to save json data (backup)
filename <- "rtelect.json"

# Start streaming
rt <- stream_tweets(q = q, timeout = streamtime, file_name = filename)

# Plot time series of all tweets aggregated by second
ts_plot(rt, by = "secs")

# Plot wordcloud
corpus <- corpus(rt, text_field = "text")
dfm <- dfm(corpus, remove_punct = TRUE, remove = c(stopwords("english"), "https", "t.co", "amp"))
textplot_wordcloud(dfm)

# List of top words
topfeatures(dfm)
