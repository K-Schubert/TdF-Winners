import pandas as pd
import glob
import re

def getRiderNames(path):
    
    return list(pd.read_csv(path))

def loadRiderResults(rider_name):
    
    path = f'../data/pcs-scraping/results/rider/{rider_name}'
        
    df_rider_clean = {rider_name: {}}

    for file in glob.glob(f'{path}/*_clean.csv'):

        year = re.search('\d{4}', file).group(0)
        df_rider_clean[rider_name][year] = pd.read_csv(file)
        
    return df_rider_clean