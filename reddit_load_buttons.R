# Load packages
library(RSelenium)
start_time <- Sys.time()
# Start the server
rs_driver_object <- rsDriver(browser = 'firefox', verbose = FALSE, port = 4567L, chromever = NULL)

# Create a client object
remDr <- rs_driver_object$client

# Open a browser
remDr$open()

# Maximize window
remDr$maxWindowSize()

####################Reading text file for URLS #######
file_path <- "reddit_urls.txt"

if (file.exists(file_path)) {
  
  # Read lines from the file and store them in a list
  lines_list <- readLines(file_path, warn=FALSE)
  
} else{
  print("File to read URLS does not exist. Hardcoding URL")
  lines_list <- c("https://www.reddit.com/r/AnimeReviews/comments/essf1u/assassination_classroom_is_a_1010_the_charm_the/")
}

# Create an empty list to store dataframes
df_list <- list()

for (each_url in lines_list){
  # Create an empty dataframe for each URL
  comments_df <- data.frame(POSTNAME = character(), AUTHOR = character(), COMMENT = character(), stringsAsFactors = FALSE)
  
  # Navigate to the Reddit page
  remDr$navigate(each_url)
  
  # Scroll to the end of the webpage
  remDr$executeScript("window.scrollTo(0, document.body.scrollHeight);")
  Sys.sleep(2)
  remDr$executeScript("window.scrollTo(0, document.body.scrollHeight);")
  Sys.sleep(2)
  
  # Set flag to control the loop
  load_more_available <- TRUE
  
  # Find and click the button to load more comments
    ##
    tryCatch({
      suppressMessages({
        loadmore <- remDr$findElement(using = 'xpath', '//*[@id="comment-tree"]/faceplate-partial/div[1]/button')
        while(loadmore$isElementDisplayed()[[1]]){
          loadmore$clickElement() 
          Sys.sleep(2)
          remDr$executeScript("window.scrollTo(0, document.body.scrollHeight);")
          Sys.sleep(2)
          loadmore <- remDr$findElement(using = 'xpath', '//*[@id="comment-tree"]/faceplate-partial/div[1]/button')
          
        }
      })
    }, 
    error = function(e) {
      NA_character_
    }
    )
    ##
  
  # Pickup title
  title <- remDr$findElement(using = 'xpath', '//*[@id="main-content"]/shreddit-title')$getElementAttribute('title')
  print(title)
  # Find all comment elements
  comment_list <- remDr$findElements(using = 'tag name', 'shreddit-comment')
  
  # Iterate through each comment element and append to the dataframe
  for (c in comment_list) {
    author <- unlist(c$getElementAttribute('author'))
    comment <- unlist(lapply(c$findChildElements(using = "xpath", value = ".//div[3]/div/p"), \(p) {
      p$getElementText()
    }))
    if (is.null(comment)){
      comment <- "delete me"
    }
    comment_row <- data.frame(POSTNAME = title, AUTHOR = author, COMMENT = comment, stringsAsFactors = FALSE)
    colnames(comment_row) <- c("POSTNAME", "AUTHOR", "COMMENT")
    comments_df <- rbind(comments_df, comment_row)
  }
  
  # Add the dataframe to the list
  df_list[[each_url]] <- comments_df
}

# Combine all dataframes in the list into a single dataframe
comments_df <- do.call(rbind, df_list)

# Write the dataframe to a CSV file
write.csv(comments_df, "reddit_scraped_comments.csv", row.names = FALSE)

# Print message
cat("Comments appended to existing file 'reddit_scraped_comments.csv'.\n")
end_time <- Sys.time()
print(start_time)
print(end_time)

# Close the browser and shut down the Selenium server
#remDr$close()r̥̥
#rs_driver_object$server$stop()
