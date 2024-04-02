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

write.csv(new_df, "preprocessed_reddit_comments.csv", row.names = FALSE)
