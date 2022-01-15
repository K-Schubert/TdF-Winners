# Project Description
This project was initially started during my studies with R. The idea was to scrap "https://www.procyclingstats.com" rider results to build a predictive model based on historical race results which could predict the next Tour de France winner.

More recently, I've revisited this project with Python. Below you will find the new objectives and implementation.

# Objectives
The main objectives are:

1. To retrieve data from PCS.
2. To predict race winners (alternatively a rider's position in the final classification) for big races (e.g. TdF).
3. Perhaps more interestingly, to predict amateur/U23/etc. non-professional rider's potential based on past results.

# Web Mining
Historical race results are scraped for UCI World Tour male riders. The goal is to retrieve data on: 

- race results (final classification)
- race leader jersey classification
- race distance
- UCI race importance (UWT, Pro, 1, 2)
- rider age, weight, height
- rider speciality
- UCI individual, team and one day race ranking
- PCS rider speciality ranking

Another feature of interest will be race day weather. Race results will be augmented using historical weather reports. Gathering data on injuries could also add value in the future. Having access to personal rider physiological data would bring many insights as to current form and training, but this is reserved to team data scientists and coaches (which I am not!).

# Modelling
The model will be built to try and predict final race classification for a given rider. The intuition is that:

- previous results from past seasons can help the model to reason about what type of races the rider excels in.
- current season results can help reason about the rider's current form.
- weather data can help indicate how tough a race will be, and if the rider has benefited from adverse weather conditions in the past.

The type of model to generate baseline results will a classical ML model. It is most likely unfeasible to apply deep learning to this problem due to the small dataset size, but I will think of ways to augment the data.
