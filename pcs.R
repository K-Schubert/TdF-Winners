library(robotstxt)
library(rvest)
library(selectr)
library(xml2)
library(dplyr)
library(stringr)
library(forcats)
library(magrittr)
library(tidyr)
library(ggplot2)
library(lubridate)
library(tibble)
library(purrr)

rm(list=ls())

##### UCI INDIVIDUAL RANKINGS : 2019 - 2016
years <- rep(2019:2016, each=2)

#### REFRESH LINK TO RE-DL!!!
path <- c("https://www.procyclingstats.com/rankings.php?id=40310&id=40310&nation=&team=&page=0&prev_rnk_days=1&younger=&older=&limit=200&filter=Filter&morefilters=0",
          "https://www.procyclingstats.com/rankings.php?id=40310&id=40310&nation=&team=&page=200&prev_rnk_days=1&younger=&older=&limit=200&filter=Filter&morefilters=0",
          "https://www.procyclingstats.com/rankings.php?id=40310&id=32609&nation=&team=&page=0&prev_rnk_days=1&younger=&older=&limit=200&filter=Filter&morefilters=0",
          "https://www.procyclingstats.com/rankings.php?id=32609&id=32609&nation=&team=&page=200&prev_rnk_days=1&younger=&older=&limit=200&filter=Filter&morefilters=0",
          "https://www.procyclingstats.com/rankings.php?id=32609&id=10949&nation=&team=&page=0&prev_rnk_days=1&younger=&older=&limit=200&filter=Filter&morefilters=0",
          "https://www.procyclingstats.com/rankings.php?id=10949&id=10949&nation=&team=&page=200&prev_rnk_days=1&younger=&older=&limit=200&filter=Filter&morefilters=0",
          "https://www.procyclingstats.com/rankings.php?id=10949&id=1192&nation=&team=&page=0&prev_rnk_days=1&younger=&older=&limit=200&filter=Filter&morefilters=0",
          "https://www.procyclingstats.com/rankings.php?id=1192&id=1192&nation=&team=&page=200&prev_rnk_days=1&younger=&older=&limit=200&filter=Filter&morefilters=0")

if (
  path %>%
  paths_allowed %>%
  sum == length(path)){

  for (i in 1:length(path)){
    x <- read_html(path[i])
    
    x %>%
      html_nodes("table") %>%
      html_table(fill=T) %>%
      extract2(1) -> x
    
    # Data Cleanup
    x %>%
      select(Rider, Team, Pnts) -> x

    if (i %% 2 == 1){
      name <- paste('uci_indiv_', years[i], sep='')
      assign(name, x)
    } else {
      assign(name, rbind(get(name), x))
    }
  }
}

merge(uci_indiv_2019, uci_indiv_2018, by="Rider") %>% 
  rename(Team_2019=Team.x, Team_2018=Team.y, Pnts_2019=Pnts.x, Pnts_2018=Pnts.y) %>%
  merge(uci_indiv_2017, by="Rider") %>%
  rename(Team_2017=Team, Pnts_2017=Pnts) %>% 
  merge(uci_indiv_2016, by="Rider") %>%
  rename(Team_2016=Team, Pnts_2016=Pnts) -> uci_indiv

uci_indiv %>% head
uci_indiv %>% dim

##### INDIVIDUAL RIDER STATS
uci_indiv %>%
  select(Rider) -> names

name_surname <- sapply(strsplit(names$Rider, "\\s+"), function(x) paste(rev(x), collapse="-"))

path <- paste('https://www.procyclingstats.com/rider/', name_surname, sep='')

if (
  path %>%
  paths_allowed %>%
  sum == length(path)){
  
  for (i in 1:length(path)){
    x <- read_html(path[i])
    
    tofind <- paste(c("\\(\\d\\d\\)","\\d\\d\\skg", "\\d\\d[.]", "\\d+One\\sday",
                      "\\d+GC", "\\d+Time\\strial", "\\d+Sprint"), collapse="|")
    
    x %>% 
      html_nodes('.rdr-info-cont') %>% 
      html_text() %>% 
      str_extract_all(tofind) %>%
      as.character %>%
      str_extract_all('\\d+') %>%
      unlist %>%
      as.numeric -> stats
    
    if (length(stats) != 6){
      
      stats <- rep(NA, 6)
      
    } else {
      
      names(stats) <- c("Age", "Weight", "One_Day_Race", "GC", "Time_Trial", "Sprint")
    
      stats %>%
        lapply(type.convert) %>%
        data.frame(stringsAsFactors=FALSE) -> stats
      
        stats %>%
          mutate(Name=names$Rider[i]) %>%
          select(-Age, -Weight, -Name) %>%
          sort(decreasing = T) %>%
          mutate(First_Speciality=names((.[1])), Second_Speciality=names(.[2])) %>%
          select(First_Speciality, Second_Speciality) %>%
          cbind(stats, .) %>%
          mutate(Rider=names$Rider[i]) -> stats
      
      if (i == 1){
        a <- stats
      } else {
        a <- rbind(a, stats)
      }
    }
  }
}

uci_indiv %>%
  merge(a, by='Rider') %>%
  select(Rider, Age, Weight, First_Speciality, Second_Speciality, everything()) -> uci_indiv

# Transform from int to num
uci_indiv %>% 
  colnames() %>%
  uci_indiv[.] %>%
  sapply(is.integer) %>%
  which(.==T) %>%
  names -> int_cols

uci_indiv[int_cols] <- lapply(uci_indiv[int_cols], as.numeric)

uci_indiv %>% head
uci_indiv %>% dim
    
write.csv(uci_indiv, "/Users/kieranschubert/Desktop/R_Projects/uci_indiv.csv", row.names = F)

##### 2019 RACE GC RANKS + RACE DIFFICULTY
##### EXTRA: POINTS; YOUTH; KOM; TEAM CLASSIFICATIONS
##### CAREER WINS (GRAND TOURS, ETC) : https://www.procyclingstats.com/rider/peter-sagan/statistics/wins
##### CAREER INJURIES: https://www.procyclingstats.com/rider/francesco-gavazzi/statistics/injury-history
##### KMS THIS SEASON (BOTTOM OF RIDER PAGE)
##### GRAND TOUR STARTS
##### NATIONAL CHAMPS
##### SEASON START
##### TEAM STATISTICS
##### !!!! RIDER SEASON STATISTICS : https://www.procyclingstats.com/rider/francesco-gavazzi/statistics/season-statistics

###### TOP 10s STAGE RACES 2019 - 2016 ######
stage_races <- c("tour-down-under", "uae-tour", "paris-nice", "tirreno-adriatico",
                 "volta-a-catalunya", "itzulia-basque-country", "tour-of-turkey",
                 "tour-de-romandie", "giro-d-italia", "tour-of-california",
                 "dauphine")
acronyms <- c("TDU", "UAE", "PN", "TA", "VC", "BC", "TT", "TR", "GIRO", "TC", "CD")

seq(2019, 2016) %>%
  paste0('/', .) -> years

for (k in 1:length(years)) {
  path <- paste0(paste0(paste0('https://www.procyclingstats.com/race/', stage_races), years[k]))
  
  for (i in 1:length(stage_races)){ 
    x <- read_html(path[i])
    
    x %>%
      html_nodes("table") %>%
      html_table(fill=T) %>%
      extract2(2) -> x
    
    x %>%
      select(Rider) -> x
    
    x %>%
      select(Rider) %>%
      apply(., 1, function(a) str_extract_all(a, '[^-]*[a-z][A-Z]')) %>% 
      unlist %>% 
      as.data.frame %>%
      apply(., 1, function(a) substr(a, 1, nchar(a)-1)) %>% 
      as.data.frame -> gc
    
    colnames(gc) <- 'Rider'
    
    a <- paste0(paste0('top_10_', acronyms[i]), years[k])
    assign(a, gc$Rider[1:10])
    uci_indiv$Rider %in% get(a) %>% 
      as.integer -> b
    assign(a, b)
    
    uci_indiv <- cbind(uci_indiv, get(a))
  
  }
  
  new_names <- paste0(paste0('top_10_', acronyms), years[k])
  colnames(uci_indiv)[(ncol(uci_indiv)-length(new_names)+1):ncol(uci_indiv)] <- new_names
  
  uci_indiv %>%
    select(starts_with('top_10')) %>%
    rowSums() -> d
  c <- paste0('stage_races_top_10s_', substr(years[k], 2, 6))
  assign(c, d)
  
  uci_indiv %>%
    select(-starts_with('top_10')) %>%
    mutate(!!c := get(c)) -> uci_indiv
}    

uci_indiv %>% head()

###### TOP 10s MONUMENTS 2019 - 2016 ######
###### TOP 10s CLASSICS 2019 - 2016 ######

# MONUMENTS TOP 3 : 2019 - 2016
monuments <- c("strade-bianche", "milano-sanremo", "ronde-van-vlaanderen",
               "paris-roubaix", "liege-bastogne-liege")

path <- paste0(paste0(paste0('https://www.procyclingstats.com/race/', monuments), '/2019'), '/history')

for (j in 1:length(path)){
  x <- read_html(path[j])
  
  x %>%
    html_nodes("table") %>%
    html_table(fill=T) %>%
    extract2(1) -> x
  
  x %>% 
    slice(1:4) -> top3
  
  years <- seq(2019, 2016)
  cols <- paste0(monuments[j], paste0(years, '_top3'))
  
  for (i in 1:4){
    a <- paste0('ind_', years[i])
    assign(a, names$Rider %in% top3[i,])
    uci_indiv$Rider %in% names$Rider[get(a)] %>% 
      as.integer -> temp
    if (i == 1){
      b <- temp
    } else {
      b <- cbind(b, temp)
    }
  }
  
  b <- as.data.frame(b)
  colnames(b) <- cols
  uci_indiv <- cbind(uci_indiv, b)
}


uci_indiv %>%
  select(ends_with('top3')) %>%
  rowSums() -> monument_top3s

uci_indiv %>%
  select(-ends_with('top3')) %>%
  mutate(monument_top3s_2019_2016=monument_top3s) -> uci_indiv

uci_indiv %>% head

# CLASSICS TOP 3 : 2019 - 2016
classics <- c("omloop-het-nieuwsblad", "driedaagse-vd-panne", "e3-harelbeke",
              "gent-wevelgem", "dwars-door-vlaanderen", "amstel-gold-race",
              "la-fleche-wallone", "Eschborn-Frankfurt")

path <- paste0(paste0(paste0('https://www.procyclingstats.com/race/', classics), '/2019'), '/history')

for (j in 1:length(path)){
  x <- read_html(path[j])
  
  x %>%
    html_nodes("table") %>%
    html_table(fill=T) %>%
    extract2(1) -> x
  
  x %>% 
    slice(1:4) -> top3
  
  years <- seq(2019, 2016)
  cols <- paste0(classics[j], paste0(years, '_top3'))
  
  for (i in 1:4){
    a <- paste0('ind_', years[i])
    assign(a, names$Rider %in% top3[i,])
    uci_indiv$Rider %in% names$Rider[get(a)] %>% 
      as.integer -> temp
    if (i == 1){
      b <- temp
    } else {
      b <- cbind(b, temp)
    }
  }
  
  b <- as.data.frame(b)
  colnames(b) <- cols
  uci_indiv <- cbind(uci_indiv, b)
}

uci_indiv %>%
  select(ends_with('top3')) %>%
  rowSums() -> classics_top3s

uci_indiv %>%
  select(-ends_with('top3')) %>%
  mutate(classics_top3s_2019_2016=classics_top3s) -> uci_indiv

uci_indiv %>% head

# STAGE RACES TOP 3: 2019 - 2016
stage_races <- c("tour-down-under", "uae-tour", "paris-nice", "tirreno-adriatico",
                 "volta-a-catalunya", "itzulia-basque-country", "tour-of-turkey",
                 "tour-de-romandie", "giro-d-italia", "tour-of-california",
                 "dauphine")

path <- paste0(paste0(paste0('https://www.procyclingstats.com/race/', stage_races), '/2019'), '/history')

for (j in 1:length(path)){
  x <- read_html(path[j])
  
  x %>%
    html_nodes("table") %>%
    html_table(fill=T) %>%
    extract2(1) -> x
  
  x %>% 
    slice(1:4) -> top3
  
  years <- seq(2019, 2016)
  cols <- paste0(stage_races[j], paste0(years, '_top3'))
  
  for (i in 1:4){
    a <- paste0('ind_', years[i])
    assign(a, names$Rider %in% top3[i,])
    uci_indiv$Rider %in% names$Rider[get(a)] %>% 
      as.integer -> temp
    if (i == 1){
      b <- temp
    } else {
      b <- cbind(b, temp)
    }
  }
  
  b <- as.data.frame(b)
  colnames(b) <- cols
  uci_indiv <- cbind(uci_indiv, b)
}

uci_indiv %>%
  select(ends_with('top3')) %>%
  rowSums() -> stage_races_top3s

uci_indiv %>%
  select(-ends_with('top3')) %>%
  mutate(stage_races_top3s_2019_2016=stage_races_top3s) -> uci_indiv

uci_indiv %>% head
#STOPPED HERE
#######################################################################################

# PCS INDIVIDUAL RANKING
paths_allowed(
  paths = c("https://www.procyclingstats.com/rankings/me/season/individual")
)

pcs_ranking_2019 <- read_html("https://www.procyclingstats.com/rankings/me/season/individual")
pcs_ranking_2019

pcs_ranking_2019 %>%
  html_nodes("table") %>%
  html_table(fill=T) %>%
  extract2(1) -> pcs_ranking_2019

pcs_ranking_2019

# Data Cleanup
pcs_ranking_2019 %>%
  select(Rider, Team, Pnts) -> pcs_ranking_2019

# RACEDAYS
paths_allowed(
  paths = c("https://www.procyclingstats.com/rankings/me/season/racedays")
)

racedays_2019 <- read_html("https://www.procyclingstats.com/rankings/me/season/racedays")
racedays_2019

racedays_2019 %>%
  html_nodes("table") %>%
  html_table(fill=T) %>%
  extract2(1) -> racedays_2019

racedays_2019

# Data Cleanup
racedays_2019 %>%
  select(Rider, Team, Pnts) -> racedays_2019

# WINS
paths_allowed(
  paths = c("https://www.procyclingstats.com/rankings/me/wins/individual")
)

wins_2019 <- read_html("https://www.procyclingstats.com/rankings/me/wins/individual")
wins_2019

wins_2019 %>%
  html_nodes("table") %>%
  html_table(fill=T) %>%
  extract2(1) -> wins_2019

wins_2019

# Data Cleanup
wins_2019 %>%
  select(Rider, Team, Wins, '2nd', '3rd') -> wins_2019

# SEASON START
paths_allowed(
  paths = c("https://www.procyclingstats.com/statistics/riders/where-will-the-top-100-start-their-season")
)

start_2019 <- read_html("https://www.procyclingstats.com/statistics/riders/where-will-the-top-100-start-their-season")
start_2019

start_2019 %>%
  html_nodes("table") %>%
  html_table(fill=T) %>%
  extract2(1) -> start_2019

start_2019

# Data Cleanup
start_2019 %>%
  select(Rider, Date) -> start_2019

# NATIONAL CHAMPION
paths_allowed(
  paths = c("https://www.procyclingstats.com/statistics/start/national-champions")
)

champ_2019 <- read_html("https://www.procyclingstats.com/statistics/start/national-champions")
champ_2019

champ_2019 %>%
  html_nodes("table") %>%
  html_table(fill=T) %>%
  extract2(1) -> champ_2019

champ_2019

# Data Cleanup
champ_2019 %>%
  select(Winner) %>%
  mapply(tolower, .) %>%
  mapply(tools::toTitleCase, .) %>% 
  as.character -> names

champ_2019 %>%
  mutate(National_Champ=1, Rider=names) %>%
  select(Rider, Nation, National_Champ) -> champ_2019

# TOTAL WINS
paths_allowed(
  paths = c("https://www.procyclingstats.com/statistics/start/active-riders-victory-ranking")
)

total_wins <- read_html("https://www.procyclingstats.com/statistics/start/active-riders-victory-ranking")
total_wins

total_wins %>%
  html_nodes("table") %>%
  html_table(fill=T) %>%
  extract2(1) -> total_wins

total_wins

# Data Cleanup
total_wins %>%
  rename(Total_Career_Wins=Wins) %>%
  select(Rider, Total_Career_Wins) -> total_wins
  
# TEAM WINS
paths_allowed(
  paths = c("https://www.procyclingstats.com/teams.php?s=wins&year=2019&filter=Filter")
)

team_wins_2019 <- read_html("https://www.procyclingstats.com/teams.php?s=wins&year=2019&filter=Filter")
team_wins_2019

team_wins_2019 %>%
  html_nodes("table") %>%
  html_table(fill=T) %>%
  extract2(1) -> team_wins_2019

team_wins_2019 %>%
  rename(Team_wins=Wins, Team_Top3='Top-3s', Team_Top10='Top-10s') -> team_wins_2019


##### DATA VISUALIZATION #####
# General Rider Characterisics

# Age Distribution by First Speciality
uci_indiv %>%
  select(Age, First_Speciality) %>%
  ggplot(aes(x=Age)) +
  geom_density(aes(fill=factor(First_Speciality)), alpha=0.5) +
  xlim(c(18, 43)) + 
  labs(title="Age Density plot", 
       subtitle="Age Distribution by First Speciality",
       x="Age",
       fill="First Speciality")
  
# Weight Distribution by First Speciality

### MODE CALCULATION FOR VERTICAL LINE
uci_indiv %>%
  select(Weight, First_Speciality) %>%
  group_by(First_Speciality) %>%
  which.max(tabulate(.))
  summarise(mean=mean(Weight), density=density(Weight)) -> FS_weights

uci_indiv %>%
  select(Weight, First_Speciality) %>%
  group_by(First_Speciality) %>% 
  summarise(dens=max(density(Weight)))

density_estimate <- density(data_df$values)
density_estimate$x[which.max(density_estimate$y)]
###############

uci_indiv %>%
  select(Weight, First_Speciality) %>%
  ggplot(aes(x=Weight)) +
  geom_density(aes(fill=factor(First_Speciality)), alpha=0.5) +
  geom_vline(xintercept=FS_weights$mean, linetype="dashed", size=0.25) +
  xlim(c(45, 90)) + 
  labs(title="Weight Density plot", 
       subtitle="Weight Distribution by First Speciality",
       x="Weight",
       fill="First Speciality")

# Weight Distribution by Second Speciality
uci_indiv %>%
  select(Weight, Second_Speciality) %>%
  ggplot(aes(x=Weight)) +
  geom_density(aes(fill=factor(Second_Speciality)), alpha=0.5) +
  xlim(c(45, 90)) + 
  labs(title="Weight Density plot", 
       subtitle="Weight Distribution by Second Speciality",
       x="Weight",
       fill="Second Speciality")

# Rider UCI Points Evolution
uci_indiv %>% 
  arrange(desc(Pnts_2019)) %>% 
  slice(1:10) %>%
  select(Rider, starts_with('Pnts')) %>%
  gather(key='Year', value='UCI_Points', Pnts_2019:Pnts_2016) %>%
  separate(Year, c("Pnts", "Year"), sep='_') %>%
  select(Rider, Year, UCI_Points) %>% 
  ggplot(aes(x=as.numeric(Year), y=UCI_Points, color=Rider)) +
  geom_point() +
  geom_line() + 
  labs(title='Rider Points Evolution', y='UCI Points', x='Year')

# Rider First Speciality by Age
uci_indiv %>%
  select(Age, First_Speciality) %>%
  ggplot(aes(x=Age, fill=First_Speciality)) +
  geom_bar(stat='count') +
  labs(title='Rider First Speciality by Age')

# Rider First Speciality by Weight
uci_indiv %>%
  select(Weight, First_Speciality) %>%
  ggplot(aes(x=Weight, fill=First_Speciality)) +
  geom_bar(stat='count') +
  labs(title='Rider First Speciality by Weight')


# TO DO
############################################################################
# Team Evolution
uci_indiv %>%
  select(starts_with('Team')) %>%
  mapply(unique, .) %>%
  do.call(cbind, .) %>%
  as.data.frame -> teams

teams %>%
  arrange %>%
  order %>%
  arrange
sort

teams %>%
  mapply(grepl, 'Quick', .)


unique(uci_indiv[, c('Team_2019')]) 
unique(uci_indiv[, c('Team_2018')])
unique(uci_indiv[, c('Team_2017')])
unique(uci_indiv[, c('Team_2016')])

uci_indiv %>%
  select(Team_2019) %>%
  mapply(grepl, 'Movistar', .)

uci_indiv %>%
  filter(Team_2019 == 'Movistar Team')
############################################################################


################
# Merge all data
################
uci_ranking_2019 %>% head
pcs_ranking_2019 %>% head
racedays_2019
wins_2019
start_2019
champ_2019 
total_wins
team_wins_2019


uci_ranking_2019$Rider %in% champ_2019$Rider %>%
  as.integer -> uci_ranking_2019$National_Champ

merge(uci_ranking_2019, start_2019, by="Rider") %>%
  merge(wins_2019, by="Rider") %>%
  merge(total_wins, by="Rider") %>%
  rename(Team=Team.x, Season_Start=Date, UCI_pnts=Pnts) %>%
  select(-Team.y) %>%
  merge(team_wins_2019, by="Team") %>%
  select(-'#') -> data

data %>% head
data %>% colnames




####### RIDER INFO #######

path <- c("https://www.procyclingstats.com/rider.php?id=primoz-roglic&p=results&xseason=2019&sort=date&race=&km1=&km2=&limit=200&page=0&topx=&continent=&pnts=&level=&rnk=&exclude_tt=0&filter=Filter&morefilters=0")

mapply(tolower, name_surname) %>%
  as.character -> names

years <- seq(2019, 2016)

paths_allowed(
  paths = path
)

#for (rider in 1:length(path)){
  
  for (yr in 1:length(years)){
  
    path <- paste0(paste0(paste0(paste0("https://www.procyclingstats.com/rider.php?id=", names), '&p=results&xseason='), years[yr]), '&sort=date&race=&km1=&km2=&limit=200&page=0&topx=&continent=&pnts=&level=&rnk=&exclude_tt=0&filter=Filter&morefilters=0')
    
    x <- read_html(path[rider])
    
    x %>%
      html_nodes("table") %>%
      html_table(fill=T) %>%
      extract2(1) -> x
    
    # Total season PCS points
    a <- paste0('pcs_pnts_', years[yr])
    x %>%
      select('PCS points') %>%
      filter(row_number()==n()) -> pcs_pnts
    assign(a, pcs_pnts)
    
    #get(a)
    
    # Replace - by 0 for PCS points
    x$`PCS points` %>%
      as.numeric %>%
      replace(., is.na(.), 0) -> x$`PCS points`
    
    # Cumulative season PCS points
    b <- paste0('cumsum_PCS_pnts_', years[yr])
    x %>% 
      select('PCS points') %>%
      slice(1:(n()-1)) %>%
      map_df(rev) %>%
      cumsum %>%
      map_df(rev) %>%
      as.data.frame -> cumsum_pcs
    assign(b, cumsum_pcs)
    
    # Replace - by 0 for UCI points
    x$`UCI points` %>%
      as.numeric %>%
      replace(., is.na(.), 0) -> x$`UCI points`
    
    # Total season UCI points
    c <- paste0('uci_pnts_', years[yr])
    x %>%
      select('UCI points') %>%
      filter(row_number()==n()) -> uci_pnts
    assign(c, uci_pnts)
    
    # Cumulative season UCI points
    d <- paste0('cumsum_UCI_pnts_', years[yr])
    x %>% 
      select('UCI points') %>%
      slice(1:(n()-1)) %>%
      map_df(rev) %>%
      cumsum %>%
      map_df(rev) %>%
      as.data.frame -> cumsum_uci
    assign(d, cumsum_uci)
    
    # Replace NA's by 0
    x %>%
      select(KMs) %>%
      mutate(KMs=replace(KMs, is.na(KMs), 0)) -> x$KMs
    
    # Total season kms
    e <- paste0('total_kms_', years[yr])
    assign(e, sum(x$KMs))
    # get(b)
    
    # Cumulative season kms
    f <- paste0('cumsum_kms_', years[yr])
    x$KMs %>% 
      map_df(rev) %>%
      cumsum %>%
      map_df(rev) %>%
      as.data.frame -> cumsum_km
    assign(f, cumsum_km)
    
    # Combined dataframe
    g <- paste(paste0('results_', years[yr]), gsub('-', '_', names[rider]), sep='_')
    x %>%
      select(Date, Result, Race) %>%
      #spread(Race, Result) -> results
      mutate(cumsum_kms=get(f), cumsum_pcs=get(b), cumsum_uci=get(d))
    
    mutate(!!c := get(c)) 

    
}

#}




