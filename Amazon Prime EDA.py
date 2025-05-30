#!/usr/bin/env python
# coding: utf-8

# PROJECT NAME- Amazon Prime EDA
# 
# 

# PROJECT TYPE- Exploratory Data Analysis

# Individual Project

# # Project Summary
# 
# The dataset contains information regarding movies and TV shows streaming on Prime video. Through the exploratory data analysis (EDA) of Amazon Prime Movies and TV Shows, the aim is to unveil significant insights into the content landscape of Amazon Prime Video. These analysis have the potential to enlighten both users and content creators about popular genres, historical patterns in content offerings, and the distribution ratio between TV shows and movies. With the growing number of TV shows and movies, data driven insights play a crucial role in understanding audience preferences, trends and content strategy.
# The dataset consists of 2 csv files listing all the content available on prime video with it's attributes like runtime, release year, the actor, director etc.
# Initially i started with basic understanding of the dataset: datatypes of attributes, missing or null values, dropping unnecessary columns or rows, statistical observation of datapoints. Various EDA techniques were applied to analyse the data and derive important insights which will help Netflix to increase it's business

# Github Link-
# 

# Problem statement- This dataset was created to analyse all shows avalilable on Amazon Prime Video, allowing us to extract valuable insights like: Content diversity, regional avaliability, trends over time, IMDb ratings and popularity. By analysing all these areas, we can recommend data backed changes to prime video to increase its business 

# Business Objective-
# Analyse the data and uncover trends that influence subscription growth, user engagement, and content investment strategies in the streaming service

# In[19]:


# importing libraries

import pandas as pd
import numpy as np
import seaborn as sns

import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
import matplotlib
plt.style.use('ggplot')
from matplotlib.pyplot import figure

get_ipython().run_line_magic('matplotlib', 'inline')
matplotlib.rcParams['figure.figsize'] = (12,8)


# In[20]:


# load the dataset

titles= pd.read_csv(r'titles.csv')


# In[21]:


credits= pd.read_csv(r'credits.csv')


# In[4]:


titles.head(10)


# In[6]:


credits.head(10)


# In[11]:


# count of rows and columns

print(f"number of rows and columns in titles= {titles.shape}")
print(f"number of rows and columns in credits= {credits.shape}")


# In[12]:


# dataset info

titles.info()


# In[13]:


credits.info()


# Both the datasets have numerical as well as categorical data. release_year is of integer datatype which will be changed to datetime

# In[16]:


# duplicate values

print(f"number of duplicate values in title dataset= {titles.duplicated().sum()}")
print(f"number of duplicate values in credits dataset= {credits.duplicated().sum()}")


# In[18]:


# missing or null values

titles.isnull().sum()


# In[19]:


credits.isnull().sum()


# In[5]:


# percentage of null values in titles dataset

for i in titles.columns:
    pct_null = titles[i].isnull().sum() / len(titles)*100
    if pct_null > 0 :
        print( "{}'s null percentage: {}%".format(i, round(pct_null, 2)))


# In[6]:


# percentage of null values in credits dataset

for i in credits.columns:
    pct_null = credits[i].isnull().sum() / len(credits)*100
    if pct_null > 0 :
        print( "{}'s null percentage: {}%".format(i, round(pct_null, 2)))


# observation: in the titles dataset, there are (9871 rows and 15 columns). There are significant null values present in the dataset namely season and age certification columns They will need imputation later on . There are only 3 duplicate rows so we can drop them 
# Coming to the credits dataset, there are (124235 rows, 5 columns). There are only 13% of null values in the character column, so we drop it. 56 duplicate records are also dropped.
# titles and credits datasets can be joined on the basis of id column to gain more insights

# In[20]:


# understanding variables
#dataset columns

titles.columns


# In[21]:


credits.columns


# In[22]:


# statistical overview of the data

titles.describe()


# In[24]:


credits.describe()


# In[26]:


# uniques values in the dataset

titles.nunique()


# In[27]:


credits.nunique()


# # Data wrangling

# In[22]:


# making copy of the raw datasets

df1= titles.copy()
df2= credits.copy()


# In[31]:


df1


# In[23]:


df3_year= titles.copy()


# In[23]:


# changing the datatype of release_year column

df1['release_year'] = pd.to_datetime(df1['release_year'])

df1['year_released']= df1['release_year'].dt.strftime('%Y') # extracting year 


# In[24]:


# dropping columns

df1.drop(['release_year', 'description', 'imdb_id'], inplace= True, axis=1)


# In[25]:


# modifying country column for further analysis

df1['production_countries'] = df1['production_countries'].replace('[]', np.nan) # removing brackets


# In[26]:


# imputing the country coulmn with the mode

df1['production_countries'] = df1['production_countries'].fillna(df1['production_countries'].mode()[0])


# In[27]:


df1['production_countries'].nunique()


# In[28]:


# creating a new column which will have the first country name

df1['country'] = df1['production_countries'].apply(lambda x: x.split(",")[0].strip("[]"))

df1['country']


# In[11]:


df1['country'].nunique()


# In[29]:


# dropping the ould production country column

df1.drop(columns=['production_countries'], inplace= True)


# In[30]:


# data imputation for handling missing values

df1['imdb_score'].fillna(df1['imdb_score'].median(), inplace=True)
df1['tmdb_popularity'].fillna(df1['tmdb_popularity'].mean(), inplace=True)
df1['tmdb_score'].fillna(df1['tmdb_score'].median(), inplace=True)


# In[13]:


df1


# In[31]:


# dropping imdb votes column

df1.drop(columns=["imdb_votes"], inplace=True)


# In[32]:


df1['imdb_score'] = df1['imdb_score'].round(1)
df1['tmdb_score'] = df1['tmdb_score'].round(1)
df1['tmdb_popularity'] = df1['tmdb_popularity'].round(1)


# In[31]:


df1


# In[33]:


# age_certification column is imputed with the mode

df1['age_certification'].fillna(df1['age_certification'].mode()[0], inplace= True)


# In[34]:


# seasons column is filled with data not available

df1['seasons']= df1['seasons'].fillna("Data not available")


# In[18]:


df1


# In[37]:


# removing special characters from genres column

df1['genres'] = df1['genres'].apply(lambda x: str(x).replace('[', '').replace(']', '').replace("'", "").replace(",", "").strip() if isinstance(x, (str, list)) else x)


# In[20]:


df1['genres']


# In[28]:


df1


# In[29]:


df1.isnull().sum() # checking to see if null are replaced


# In[38]:


df1.drop_duplicates(inplace= True) # dropping duplicate rows in titles dataset


# In[31]:


df2


# In[39]:


df2.drop_duplicates(inplace= True) # dropping duplicate rows in credits dataset


# In[34]:


df2


# In[40]:


# dropping character column from credits dataset

df2.drop(columns= ['character'], inplace= True)


# In[36]:


df2


# In[24]:


# joining the two dataframes

df_joined= pd.merge(df1, df2, on='id')


# In[25]:


df_joined


# #  What all manipulations have you done and insights you found
# 
# 1. Dropped description, imdb_id and imdb votes columns in the title dataset
# 2. Removed special characters from country and genres columns
# 3. Imputed age certification coulmn with mode and season column with data not available. 
# 4. imdb_score and tmdb_score columns were imputed with the median and tmdb_popularity was filled with the mean of the column
# 5. Removed character column from credits dataset
# 6. After cleaning, both the datasets were joined on the basis of id column
#  

# # Data Vizualization, Storytelling & Experimenting with charts : Understand the relationships between variable

# In[39]:


# Percentage of movies Vs. TV shows

label= ['TV Show', 'Movie']
plt.pie(df1['type'].value_counts().sort_values(), labels=label, 
        autopct='%1.2f%%')
plt.title('Percentage of Movies Vs. TV Shows')
plt.show()


# Why did you pick the specific chart? Pie charts are very useful in depicting part to whole relationship in the data. Percentage comparison can also be easily done so the above chart was chosen to express the share of movies Vs TV shows
# 
# What is/are the insight(s) found from the chart? More than 85% of the content on amazon Prime consists of movies. Approximately 14% comprises of TV shows
# 
# Will the gained insights help creating a positive business impact? yes, Prime should maintain the movie content to increase viewership

# In[40]:


# Top 10 countries with maximum content 

grouping= df1.groupby(['type']).country.value_counts().groupby(level=0).head(10)
grouping


# In[43]:


# Plot the graph
sns.countplot(y='country', hue='type', data=df1, order=df1.country.value_counts().iloc[:10].index)

# Set labels
plt.title('Top Ten Countries With Most Content')
plt.ylabel('Country')
plt.xlabel('total movies and TV shows')

# Display Chart
plt.show()


# Why did you pick the specific chart? Bar graphs are useful for comparing data across different categories, so to display total number of movies and tv shows in various countries bar graph is appropriate
# 
# What is/are the insight(s) found from the chart? US tops the list with maximum number of movies as well as TV shows followed by India.
# 
# Will the gained insights help creating a positive business impact? Amazon prime should add more movies in USA as well as India

# In[55]:


#Year in which maximum movies were released

df_tv = df3_year[df3_year["type"] == "SHOW"]
df_movie = df3_year[df3_year["type"] == "MOVIE"]

ax = sns.countplot(y="release_year", data=df_movie, order=df_movie['release_year'].value_counts().index[0:15])
for container in ax.containers:
    ax.bar_label(container)

plt.title('Year of Maximum movie release', fontsize=15)
plt.show()


# In[54]:


# Year in which maximum TV shows were released

ax = sns.countplot(y="release_year", data=df_tv, order=df_tv['release_year'].value_counts().index[0:15])
for container in ax.containers:
    ax.bar_label(container)

plt.title('Year of maximum TV show releases', fontsize=15)
plt.show()


# Why did you pick the specific chart? Bar graphs are useful for comparing data across different categories, so to show the year in which highest number of movies and tv shows were released, bar graph is used
# 
# What is/are the insight(s) found from the chart Most of the movies were released in the year 2021 (715 movies) followed by 2019 and 2020. Most of the TV Shows were released in 2021 followed by 2020 and 2018. Substantial growth in content mainly movies  started from 2016 to 2021
# 
# Will the gained insights help creating a positive business impact? The highest number of movies got released in 2021 and 2019 and tv shows got released in 2021 and 2020. Movies released were more as compared to TV shows very few tv shows were released before 2010

# In[45]:


# top movies and TV shows based on IMDb score

df_sorted = df1.groupby('type', group_keys=True).apply(lambda x: x.sort_values('imdb_score', ascending=False)).reset_index(drop=True)

df_sorted


# In[53]:


top_movies = df_sorted[df_sorted['type']== 'MOVIE'].head(5)[['title','imdb_score']]
top_movies


# In[54]:


top_shows= df_sorted[df_sorted['type']== 'SHOW'].head(5)[['title','imdb_score']]


# In[55]:


top_shows


# In[56]:


# Plot top movies
plt.barh(top_movies['title'], top_movies['imdb_score'], color='blue', label='Top Movies')

# Plot top shows
plt.barh(top_shows['title'], top_shows['imdb_score'], color='green', label='Top Shows')

# Set labels and title
plt.xlabel('IMDb Score')
plt.ylabel('Movie')
plt.title('Top Movies and Shows based on IMDb Score')
plt.legend()

# Display the plot
plt.show()


# 1. Why did you pick the specific chart? Bar graphs are useful for comparing data across different categories so top movies and tv shows based on imdb score is best represented by bar graph, in this case horizontal bar graph where y axis consists of the categorical variable and x axis consists of numerical variable
# 
# 2. What is/are the insight(s) found from the chart? the highest rated movie is "Water Helps the Blood Run" with imdb score of 9.7 and "Pawankhind" is the highest rated TV show with 9.9 as imdb score.
# 
# 3. Will the gained insights help creating a positive business impact? Amazon prime should never take these movies and shows off their platform because most people tend to watch highest rated content by IMDb 

# In[63]:


# Most popular genres on TMDb based on mean tmdb_popularity

# Split genres into individual entries
genres_split = df1['genres'].str.split(' ', expand=True)

# Combine genre information with the original DataFrame
df_genres = pd.concat([df1['title'], genres_split, df1['tmdb_popularity']], axis=1)
df_genres = df_genres.melt(id_vars=['title', 'tmdb_popularity'], value_vars=list(genres_split.columns))

# Calculate the mean popularity for each genre
mean_popularity_by_genre = df_genres.groupby('value')['tmdb_popularity'].mean().sort_values(ascending=False)
mean_popularity_by_genre


# In[64]:


# Plot the graph
sns.barplot(x=mean_popularity_by_genre.values, y=mean_popularity_by_genre.index)

# Set labels and title
plt.xlabel('Mean TMDb Popularity')
plt.ylabel('Genre')
plt.title('Most Popular Genre on TMDb')

# Display the plot
plt.show()


# 1. Why did you pick the specific chart? Bar charts are used to compare the size or frequency of different categories or groups of data. Bar charts are useful for comparing data across different categories.
# 
# 2. What is/are the insight(s) found from the chart? Leading the chart is fantasy closely followed by sci fi and animation
# 
# 3. Will the gained insights help creating a positive business impact? Yes prime viseo should increase its content in fantasy, sci fi and animation categories to increase user engagement on its platform

# In[66]:


# Count plot for number of movies and shows for each rating
sns.countplot(x='age_certification', hue='type', data=df1)

# Set Labels
plt.title('Count of movies and shows for each rating')
plt.xlabel('Ratings')
plt.xticks(rotation = 60)

# Display Chart
plt.show()

# Printing The Counts of Each Rating for Different Type Shows
print('Each Rating Counts for Different Types of Shows:')
print(df1.groupby(['age_certification', 'type']).size())


# 1. Why did you pick the specific chart? Bar charts are used to compare the size or frequency of different categories or groups of data. Bar charts are useful for comparing data across different categories.
# 
# 2. What is/are the insight(s) found from the chart? R rated movies and tv shows dominate the category followed by PG 13 movies. There are no PG 13 rated shows and R rated shows are also very low in number. This variance could be due to lack of data present as there were almost 66% null values in the age certification column which was imputed by the mode of the coulmn which was R rated
# 
# 3. Will the gained insights help creating a positive business impact? Yes, prime video should increase its content with R rated movies and TV shows. PG 13 rated movies should also be regularly added to the platform

# In[11]:


# Number of content released over time

# Grouping the data on the basis of release year and type of movie and tv show
df_grouped = df3_year.groupby(['release_year', 'type']).size().reset_index(name='count')

# reshape the data
df_pivot = df_grouped.pivot(index='release_year', columns='type', values='count').fillna(0)

# plotting the graph
df_pivot.plot(kind='line', figsize=(10, 6))

# setting labels
plt.title('Release Trends Over Time')
plt.xlabel('Release Year')
plt.ylabel('Count')
plt.legend(title='Type')
plt.grid(True)
plt.show()


# 1. Why did you pick the specific chart? Line plots in pandas are a way to visualize the relationship between two or more variables, often showing trends over time or across categories
# 
# 2. What is/are the insight(s) found from the chart? the content addition started as early as 1920 with almost equal number of movies and tv shows but over the years the number of tv shows remained the same till 2000. There was a spike in addition of tv shows in 2020. As for the movies, it was a gradual increase in number from the begining but it spiked to almost 700 in 2019 to 2021
# 
# 3. Will the gained insights help creating a positive business impact? 2020 to 2021 was the covid time period with countries on lockdown so prime video added content for the people to watch with extra time on their hands for binge watching

# In[16]:


# Histogram for distribution of minutes

plt.figure(figsize=(8,4), dpi=120)
ax= sns.histplot(df3_year.runtime)
plt.xticks(np.arange(0,200,20))
plt.xticks(rotation = 60)
plt.tight_layout()
ax.margins(x=0)

# Set Labels
plt.title("Duration Distribution for Prime Movies and TV shows")
plt.ylabel("% of All Prime content", fontsize=9)
plt.xlabel("Duration (minutes)", fontsize=9)

# Display Chart
plt.show()


# 1. Why did you pick the specific chart? A histogram is a statistical graph that uses vertical bars to represent the frequency distribution of a dataset. The height of each bar represents the frequency or count of data points within that specific bin. Histograms help visualize the shape of the data distribution, whether it's symmetrical, skewed, or has multiple peaks.
# 
# 2. What is/are the insight(s) found from the chart? The duration of maximum movies and tv shows on prime video is around 90 to 110 mins.
# 
# 3. Will the gained insights help creating a positive business impact? So, prime video has to try to keep only those content on its platform which are around 90 to 110 mins to keep its viewership growing and increase user engagement

# # Other Insights
# 

# In[29]:


# Count actor occurrences
actor_counts = df_joined['name'].value_counts()

# Find the actor with the most movies
most_frequent_actor = actor_counts.idxmax()
max_movies_count = actor_counts.max()

# Print the results
print(f"The actor with the most movies is: {most_frequent_actor} with {max_movies_count} movies.")


# In[30]:


# Group by actor name and calculate the average rating
actor_ratings = df_joined.groupby('name')['imdb_score'].mean()

# Sort the results
sorted_actor_ratings = actor_ratings.sort_values(ascending=False)

# Get the actor with the highest average rating
top_actor = sorted_actor_ratings.head(1)

# Print the actor with the highest average rating
print(f"The actor with the highest average IMDb rating is:\n{top_actor}")


# In[34]:


# correlation between different variables

# select numerical variables
df_selected = df3_year[['release_year', 'runtime', 'imdb_score', 'tmdb_score', 'tmdb_popularity']]

# plot the graph
correlation_matrix = df_selected.corr()
plt.figure(figsize=(10, 6)) 
sns.heatmap(correlation_matrix, annot=True, cmap="coolwarm", fmt=".2f")
plt.title("Correlation Heatmap")
plt.show()


# # Solution to Business Objective
# 
# The analysis revealed that Netflix has a greater number of movies than TV shows with a rapidly growing collection of shows from the United States, so Prime Video sholud keep on increasing it's movies which are of 90-110 mins duration
# 
# Fantasy movies should be regularly added on the paltform followed by sci fi and animation as they are the top 3 genres that most people like to watch
# 
# R rated movies dominate the platform which means restricted (content too mature for young audiences) followed by PG 13 not suitable for children below the age of 13. Amazon should cater to adult audiences above 17 years of age

# # Conclusion
# 
# Exploring the dataset which consisted of two datasets with a focus on missing value imputation and exploratory data analysis (EDA) to make the data analysis ready. After closely analysing the data, there were many valuable insights found which if implemented will surely help prime video to grow its subscriptions. Since data is cleaned and is ready for applying machine learning models which can predict what kind of movies and tv shows will be watched by the audience and help grow the business of Amazon Prime Video
