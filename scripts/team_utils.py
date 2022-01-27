import pandas as pd

def getTeams(rider_name):
    
    df_teams = pd.read_csv(f'../data/pcs-scraping/teams/rider/{rider_name}/teams.csv')
    df_teams.rename(columns={'season': 'year'}, inplace=True)
    
    return df_teams

def getRankings(rider_name):
    
    df_rankings = pd.read_csv(f'../data/pcs-scraping/pcs-ranking/rider/{rider_name}/pcs_ranking.csv')

    return df_rankings

def mergeTeamsRankings(df_rankings, df_teams):
    
    df_performance = pd.merge(df_rankings, df_teams, on='year', how='inner')

    return df_performance

def getTeamChange(df_performance):
    
    df_change = df_performance.copy()
    df_change['teamChange'] = df_change['team'].shift(1, fill_value=df_change['team'].head(1)) != df_change['team']
    team_change_text = df_change['teamChange'].map({True: 'Team Change', False: ''})
    df_change['teamChangeText'] = team_change_text
    
    return df_change.drop('teamChange', axis=1)

def teamChangeAutoCheck(df_change):
    
    team_change_col = []

    for i, row in df_change.iterrows():

        if row['teamChangeText']:

            team_name = [x.split('-') for x in row['team'].split(' ')]
            team_name = [item.lower() for sublist in team_name for item in sublist]
            team_name = list(filter(None, team_name))
            team_name = [x for x in team_name if x != 'team']

            team_name_cache = [x.split('-') for x in df_change.loc[i-1, 'team'].split(' ')]
            team_name_cache = [item.lower() for sublist in team_name_cache for item in sublist]
            team_name_cache = list(filter(None, team_name_cache))
            team_name_cache = [x for x in team_name_cache if x != 'team']

            team_change_text = []
            for prev_team in team_name:
                if prev_team in team_name_cache:
                    team_change_text.append(True)
                else:
                    team_change_text.append(False)

            if any(team_change_text):
                team_change_col.append('')
            else:
                team_change_col.append('Team Change')

        else:
            team_change_col.append('')
    
    df_change['teamChangeText'] = team_change_col
    
    return df_change

def getTeamFlag(df_change):

    x = 0
    team = []

    for i, row in df_change.iterrows():
        
        if not row['teamChangeText']:
            
            team.append(x)
        
        else:
            
            x += 1
            team.append(x)

    return team

def getAllTeamFlag(df_change):

    x = 0
    team = []

    for i, row in df_change.iterrows():
        
        if i == 0:
            
            team.append(x)
        
        elif i >= 1 and row['team'] == df_change.loc[i-1, 'team']:
            
            team.append(x)
        
        elif i >= 1:
            
            x += 1
            team.append(x)
            


    return team