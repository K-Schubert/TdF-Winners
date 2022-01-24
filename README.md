# Project Description
This project was initially started during my studies with R. The idea was to scrap "https://www.procyclingstats.com" rider results to build a predictive model based on historical race results which could predict the next Tour de France winner.

More recently, I've revisited this project with Python. Below you will find the new objectives and implementation. I'd like to share the final project as an interactive dashboard to be able to visualize results, queries, predictions, etc.

# Objectives
The main objectives are:

1. To retrieve data from PCS.
2. To predict junior/U23/neopro/etc. rider potential based on past results and a clustering approach.
3. To predict race winners (alternatively a rider's position in the final classification) for big races (e.g. TdF).
4. To optimize race calendars and potential UCI points on offer for teams wanting to avoid relegation or climb up a racing category.

# Web Mining
Historical race results are scraped for UCI World Tour male riders. The goal is to retrieve data on: 

- race results (final classification)
- race leader jersey classification
- race distance and elevation
- UCI race categorisation (UWT, Pro, 1, 2)
- race difficulty
- rider age, weight, height
- rider speciality
- UCI individual, team and one day race ranking
- PCS rider speciality ranking

Another feature of interest will be race day weather. Race results will be augmented using historical weather reports. Gathering data on injuries could also add value in the future. Having access to personal rider physiological data would bring many insights as to current form and training, but this is reserved to team data scientists and coaches (which I am not!).

# Dashboard
A dashboard is being developed for visualizations and data analysis. A first step will be to represent a rider's seasonal and career results through plots which add value:

- seasonal results
- seasonal wins, top 5, top 10, top 20 results
- number of race days
- progression of results over N seasons
- etc.

<p align="center">
  <img width="400" height="300" src="https://github.com/K-Schubert/TdF-Winners/blob/master/media/dash_app_screenshot.png">
</p>

Then the dashboard will aim to provide insights into how established and successful professional riders have achieved their status throughout the years. Visualizations will provide information about "success trends" for top professionals (see Figure 1). Another type of visualization will focus on clustering successful riders to try and extract features of success.

<p align="center">
  <img width="400" height="300" src="https://github.com/K-Schubert/TdF-Winners/blob/master/media/uci_points_trend.png">
  <img width="400" height="300" src="https://github.com/K-Schubert/TdF-Winners/blob/master/media/uci_position_trend.png">
</p>
<p align="center">
  <em>Figure 1</em>
 </p>

# Modelling 1
The model will be used to predict whether a junior/neopro/U23 rider has the potential to win big races at the highest level. Based on a cross-sectional and autoregressive approach, I will first compare established pro riders progression to candidate riders. Using a clustering algorithm, the idea is to project a successful pro rider's results into a lower dimensional space and see if the candidate rider's features are clustered with the successful professional's features.

# Modelling 2
The model will be built to try and predict final race classification for a given rider. The intuition is that:

- previous results from past seasons can help the model to reason about what type of races the rider excels in.
- current season results can help reason about the rider's current form.
- weather data can help indicate how tough a race will be, and if the rider has benefited from adverse weather conditions in the past.

The type of model to generate baseline results will a classical ML model. It is most likely unfeasible to apply deep learning to this problem due to the small dataset size, but I will think of ways to augment the data.

# Modelling 3
The idea is to prepare a race calendar for professional teams wanting to avoid relegation from the World Tour or to progress up to the higher racing category by gaining enough UCI points per season. The model will be akin to the 'Knapsack' problem where one has to select the optimal combination of elements given a budget. The task here will be to target (select) the optimal races given UCI points on offer to optimize chances of gaining enough points in a season based on rider speciality and past results in a given team.
