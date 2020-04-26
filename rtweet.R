# ---
# title: "Collecting Twitter Data using rtweet (workshop material)"
# author: "Justin Ho"
# last updated: "25/04/2020"
# ---

################################################################
#             Getting Twitter Developer Account                #
################################################################
#
# To access Twitter API, you will need four sets of keys: API Key, API Secret Key, Access Token, Access Token Secret.
# These are equivalent to the username and password you use when you login on Twitter, but for R.
#
# In order to do so, you need do two things, first, apply for a developer account:
# https://www.extly.com/docs/autotweetng_joocial/tutorials/how-to-auto-post-from-joomla-to-twitter/apply-for-a-twitter-developer-account/#apply-for-a-developer-account
#
# Second, create a App and get the keys and secrets:
# https://www.slickremix.com/docs/how-to-get-api-keys-and-tokens-for-twitter/
#

################################################################
#                           Setting Up                         #
################################################################

# Install the library
install.packages("rtweet")
# install.packages("quanteda")
# install.packages("tidyverse")

# Load the library
library(rtweet)

# Copy and paste these from your developer account, the following keys work, but not for long.
api_key <- "SJqRPYxvDXlvezYWnGp9YYewP"
api_secret_key <- "lOEgdnMRxfNWGOxjRvxwwIJHH6QbxuVXW44qS5B5JTtOlmhlwv"
access_token <- "1189518014959493121-81E4FGHqQECAAx9kcoWU9OVthJoOmi"
access_token_secret <- "A4c0Ygv6vZHAORXzISqSTpehzo4JzbndBznE3UXzNFonC"

token <- create_token(
  app = "cdcs",
  consumer_key = api_key,
  consumer_secret = api_secret_key,
  access_token = access_token,
  access_secret = access_token_secret)

################################################################
#                      Search by Keywords                      #
################################################################

tweets <- search_tweets("#COVIDIOTS", n = 100, retryonratelimit = FALSE)

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
tmls <- get_timelines(user_handles, n = 100)

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
q <- "#COVID19"

# Stream time in seconds so for one minute set timeout = 60
# For larger chunks of time, I recommend multiplying 60 by the number
# of desired minutes. This method scales up to hours as well
# (x * 60 = x mins, x * 60 * 60 = x hours)
# Stream for 30 minutes
streamtime <- 20

# Filename to save json data (backup)
filename <- "rtelect.json"

# Start streaming
rt <- stream_tweets(q = q, timeout = streamtime, file_name = filename, language = "en")

# Plot time series of all tweets aggregated by second
ts_plot(rt, by = "secs")

# Plot wordcloud
corpus <- corpus(rt, text_field = "text")
dfm <- dfm(corpus, remove_punct = TRUE, remove = c(stopwords("english"), "https", "t.co", "amp"))
textplot_wordcloud(dfm)

# List of top words
topfeatures(dfm)
