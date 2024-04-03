library(dplyr)
library(tidyverse)

#Read csv

df <- read_csv('reddit_scraped_comments.csv')


#Drop duplicates

print(paste("Dimensions of df before dropping duplicates :", dim(df)))

df <- distinct(df)


print(paste("Dimensions of df after dropping duplicates :", dim(df)))

# Remove rows where 'comment' column is NA
df <- df %>% filter(!is.na(COMMENT))

print(paste("Dimensions of df after filtering NA :", dim(df)))


# Remove rows where 'COMMENT' column is 'delete me'
df <- df %>% filter(COMMENT != 'delete me')

print(paste("Dimensions of df after deleteing DELETE ME COMMENTS :", dim(df)))


##Adding serial number

# Adding a new column named 'S_No' at the beginning with sequential numbers
#df <- df %>% mutate(S_No = seq_len(n()))

# re-order the columns so that 'S_No' is the first column:
#df <- df %>% select(S_No, everything())


### combining comments

# Group by columns POSTNAME and AUTHOR
new_df <- df %>%
  group_by(POSTNAME, AUTHOR) %>%
  # Combine values in column COMMENT by appending the COMMENT value of the second row to the COMMENT value of the first row
  summarize(COMMENT = paste(COMMENT, collapse = "\n")) %>%
  # Ungroup the dataframe
  ungroup()

print(paste("Dimensions of df after MERGING COMMENTS :", dim(new_df)))

## Removing outlier comments based on length by using the IQR method.

# Function to count words in a string
count_words <- function(text) {
  words <- unlist(strsplit(text, "\\s+"))
  return(length(words))
}

# Apply the function to each entry in column C and store the counts
word_counts <- sapply(new_df$COMMENT, count_words)

# Find first and third quartiles
first_quartile <- quantile(word_counts, 0.25)
third_quartile <- quantile(word_counts, 0.75)

iqr <- third_quartile - first_quartile

# Calculate the upper and lower bounds
lower_bound <- first_quartile - 1.5 * iqr
upper_bound <- third_quartile + 1.5 * iqr

# Filter rows based on the upper and lower bounds
filtered_data <- new_df[word_counts >= lower_bound & word_counts <= upper_bound, ]

print(paste("Dimensions of df after filtering on IQR :", dim(filtered_data)))


write.csv(filtered_data, "preprocessed_reddit_comments_2.csv", row.names = FALSE)
