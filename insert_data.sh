#!/bin/bash
if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Clear old rows
$PSQL "TRUNCATE TABLE games, teams"

# Insert every unique team in one query
TEAM_VALUES=$(tail -n +2 games.csv | cut -d, -f3,4 | tr ',' '\n' | sort -u | sed "s/'/''/g; s/.*/('&')/" | paste -sd, -)
$PSQL "INSERT INTO teams(name) VALUES $TEAM_VALUES"

# Insert every game in one query, looking up team IDs with subqueries
GAME_VALUES=$(tail -n +2 games.csv | while IFS=, read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  echo "($YEAR,'$ROUND',(SELECT team_id FROM teams WHERE name='$WINNER'),(SELECT team_id FROM teams WHERE name='$OPPONENT'),$WINNER_GOALS,$OPPONENT_GOALS)"
done | paste -sd, -)
$PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES $GAME_VALUES"