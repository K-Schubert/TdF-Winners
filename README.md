# Project Description
This project was initially started during my studies with R. The idea was to scrap "https://www.procyclingstats.com" rider results to build a predictive model based on historical race results which could predict the next Tour de France winner.

More recently, I've revisited this project with Python. Below you will find the new objectives and implementation. I'd like to share the final project as an interactive dashboard to be able to visualize results, queries, predictions, etc.

# Objectives
The main objectives are:

1. To retrieve data from PCS.
2. Visualizations: to create an interactive dashboard for rider data, results and progression visualization.
3. Talent Identification: to predict junior/U23/neopro/etc. rider potential.
4. Team Performance Analysis: to analyze team performance and how new signings can influence future results.
5. Race Winner Prediction: to predict race winners (alternatively a rider's position in the final classification) for big races (e.g. TdF).
6. Racing Calendar Optimization: to optimize race calendars and potential UCI points on offer for teams wanting to avoid relegation or climb up a racing category.

# Web Mining
Historical race results are scraped for UCI World Tour male riders. The goal is to retrieve data on: 

- race results (final classification)
- race leader jersey classification
- race distance and elevation
- UCI race categorisation (UWT, Pro, 1, 2, etc.)
- race difficulty
- rider age, weight, height
- rider speciality
- UCI individual, team and one day race ranking
- PCS rider speciality ranking

Another feature of interest will be race day weather. Race results will be augmented using historical weather reports. Gathering data on injuries could also add value in the future. Having access to personal rider physiological data would bring many insights as to current form and training, but this is reserved to team data scientists and coaches (which I am not!).

# Dashboard
A dashboard (see Figure 1 for a preliminary mockup) is being developed for visualizations and data analysis. A first step will be to represent a rider's seasonal and career results through plots which add value:

- seasonal results
- seasonal wins, top 5, top 10, top 20 results
- number of race days
- progression of results over N seasons
- etc.

<p align="center">
  <img width="600" height="900" src="https://github.com/K-Schubert/TdF-Winners/blob/master/media/dash_app_screenshot.png">
</p>
<p align="center">
  <em>Figure 1</em>
</p>

Then the dashboard will aim to provide insights into how established and successful professional riders have achieved their status throughout the years. Visualizations will provide information about "success trends" for top professionals (see Figure 2). Another type of visualization will focus on clustering successful rider's results to try and extract features of success. One can imagine clustering cross-sectional features or time-series of results.

<p align="center">
  <img width="400" height="300" src="https://github.com/K-Schubert/TdF-Winners/blob/master/media/uci_points_trend.png">
  <img width="400" height="300" src="https://github.com/K-Schubert/TdF-Winners/blob/master/media/uci_position_trend.png">
</p>
<p align="center">
  <em>Figure 2</em>
</p>

In Figure 3 and Figure 4, we can see how a rider has progressed over seasons through his seasonal PCS points with different teams. Figure 3 compares his progression in his current team to his entire career with trendlines. This can help analyze how potential contract changes (signing from a small team to a larger budget team) can affect performance. It has often been the case that riders underperform after a breakout season and signing to a larger team (see this [article](https://beyondthepeloton.substack.com/p/2021-rider-previews-preview-who-will)). Figure 4 shows how many points were won or lost on average per team by modelling rider results with linear regression (left figure indicates all teams, right figure considers a change of title sponsor is not equal to a team change).

<p align="center">
  <img width="400" height="300" src="https://github.com/K-Schubert/TdF-Winners/blob/master/media/mvdp_points_progression.png">
</p>
<p align="center">
  <em>Figure 3</em>
</p>

<p align="center">
  <img width="400" height="300" src="https://github.com/K-Schubert/TdF-Winners/blob/master/media/mvdp_team_progression.png">
  <img width="400" height="300" src="https://github.com/K-Schubert/TdF-Winners/blob/master/media/mvdp_all_teams_progression.png">
</p>
<p align="center">
  <em>Figure 4</em>
</p>

We can also determine which teams have helped riders develop and climb the rankings the most for a sample of riders (Figure 5, top 20 best and worst teams). The values on the y-axis show how much a rider has progressed in terms of PCS points per year in each team. We see that some teams contribute to rider success a lot more than others for a sample of n=100 top riders. The next step could be to include team size (e.g. via team budget) to remove this component from the analysis and extract teams with the best structures for athlete progression.

<p align="center">
  <img width="600" height="300" src="https://github.com/K-Schubert/TdF-Winners/blob/master/media/avg_progression_per_team.png">
</p>
<p align="center">
  <img width="400" height="300" src="https://github.com/K-Schubert/TdF-Winners/blob/master/media/avg_progression_per_team_top20.png">
  <img width="400" height="300" src="https://github.com/K-Schubert/TdF-Winners/blob/master/media/avg_progression_per_team_worst20.png">
</p>
<p align="center">
  <em>Figure 5</em>
</p>

Next I propose a metric called *team progression index* or *TPI* to compare rider progression between teams (Table 1, coming soon).

# Modelling 1
The model will be used to predict whether a junior/neopro/U23 rider has the potential to win big races at the highest level. Based on a time-series (1) and cross-sectional (2) approach, I will first compare established pro riders progression to candidate riders. 

For (1), we can for example compare trends in UCI rankings progression or seasonal results for selected riders, then model these trends to extract parameters of successful progression. These parameters can then be compared to candidate riders to see if they "fit" a succesful rider's progression.

For (2), we can extract cross-sectional features of many successful riders and run a clustering algoritm to determine what features contribute to a rider's success. A comparison can then be made with a candidate rider.

# Modelling 2
The model will be built to try and predict final race classification for a given rider. The intuition is that:

- previous results from past seasons can help the model to reason about what type of races the rider excels in.
- current season results can help reason about the rider's current form.
- weather data can help indicate how tough a race will be, and if the rider has benefited from adverse weather conditions in the past.

The type of model to generate baseline results will a classical ML model. It is most likely unfeasible to apply deep learning to this problem due to the small dataset size, but I will think of ways to augment the data.

# Modelling 3
The idea is to prepare a race calendar for professional teams wanting to avoid relegation from the World Tour or to progress up to the higher racing category by gaining enough UCI points per season. The model will be akin to the 'Knapsack' problem where one has to select the optimal combination of elements given a budget. The task here will be to target (select) the optimal races given UCI points on offer to optimize chances of gaining enough points in a season based on rider speciality and past results in a given team.
