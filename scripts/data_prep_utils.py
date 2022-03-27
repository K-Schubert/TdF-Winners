import pandas as pd
import numpy as np
import os
from datetime import datetime
import math
import csv
import re

from dotenv import load_dotenv

def convert_to_datetime(date, year):
    
    if date == 0:
        pass
    
    elif isinstance(date, datetime):
        return date
    
    elif len(date) == 5:
        
        try:
            return datetime.strptime(date, '%d.%m').replace(year=int(year))
        except ValueError as e:
            return datetime.strptime(date.replace('29', '28'), '%d.%m').replace(year=int(year))
    
    elif len(date) == 13:
        
        dates = date.split('»')
        return [convert_to_datetime(d.strip(), year) for d in dates]

def getStageRaceName(df):
    
    from_dates = df[df.Race.str.contains('Stage 1 |Prologue')].FromDate
    
    for from_date in from_dates:
        
        end_date = df[df.FromDate == from_date].iloc[0].ToDate
        #start_date = df[df.Race.str.contains('Stage 1 -')].FromDate.iloc[0]
        mask = (df.FromDate >= from_date) & (df.FromDate <= end_date)
        idx = df.loc[mask].index[[0, -1]]

        df.loc[range(idx[0], idx[1]+1), 'RaceName'] = df.loc[idx[0]].Race
        
    return df

def getClassificationDate(df):
    
    for race in df[df.Race.str.contains('classification')].iterrows():

        df.loc[race[1].name, 'FromDate'] = df[df.Race == race[1].RaceName].ToDate.values[0]
        df.loc[race[1].name, 'ToDate'] = df[df.Race == race[1].RaceName].ToDate.values[0]
        
    return df

def getGCResult(df):
    
    for result in df[df.Result.isna()].iterrows():
    
        try:
            gc_result = df.loc[(df.Race == 'General classification') & (df.RaceName == result[1].RaceName)].Result.values[0]
            df.loc[result[1].name, 'Result'] = gc_result
        except Exception as e:
            pass

        
    return df

def clean_data(df, rider_name, year, save=False):
    
    # define Type col
    df['Type'] = 'OneDayRace'
    idx = df.Date.str.contains('»').fillna(False)
    df.loc[idx, 'Type'] = 'StageRace'
    idx = df.Race.str.contains('Stage|Prologue|classification')
    df.loc[idx, 'Type'] = 'StageRace'

    # normalize date
    #df.dropna(subset=['Date'], inplace=True)
    #df = df[~df.Date.str.contains('»')]
    df.Date.fillna(0, inplace=True)
    df.Date = [convert_to_datetime(date, year) for date in df.Date]

    df.rename(columns={'Date': 'FromDate'}, inplace=True)
    df['ToDate'] = df.FromDate
    df['ToDate'] = [x[1] if isinstance(x, list) else x for x in df.ToDate]
    df['FromDate'] = [x[0] if isinstance(x, list) else x for x in df.FromDate]

    # define RaceName col
    idx = (df.Type == 'OneDayRace')
    df.loc[idx, 'RaceName'] = df.Race[idx]
    df = getStageRaceName(df)

    # get date for final classifications
    df = getClassificationDate(df)

    # result to int
    idx = df.Result.isna()
    df.loc[idx, 'Result'] = 0
    df = getGCResult(df)
    df.Result = [int(x) if x not in ['DNF', 'DNS', 'DSQ'] else x for x in df.Result]
    #df = df[df.Result != 0]
    
    if save:
        df.to_csv(os.path.join(RESULTS_PATH, rider_name, f'{year}_clean.csv',), index=False, encoding='utf-8')
    
    return df