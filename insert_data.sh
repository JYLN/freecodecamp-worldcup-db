#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Clear tables for re-run of script
echo $($PSQL "TRUNCATE TABLE games, teams")

# Read data from CSV and establish loop for each row
cat games.csv | while IFS="," read YEAR ROUND WINNER_NAME OPPONENT_NAME WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # get winner team id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER_NAME'")

    # if winner team id not found
    if [[ -z $WINNER_ID ]]
    then
      # insert into table
      INSERT_WINNER_TEAM_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER_NAME')")
      if [[ $INSERT_WINNER_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams: $WINNER_NAME
      fi
      # get new winner team id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER_NAME'")
    fi

    # get opponent team id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT_NAME'")

    # if opponent team id not found
    if [[ -z $OPPONENT_ID ]]
    then
      # insert into table
      INSERT_OPPONENT_TEAM_RESULT=$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT_NAME')")
      if [[ $INSERT_OPPONENT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams: $OPPONENT_NAME
      fi
      # get new opponent team id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT_NAME'")
    fi

    # Get game_id if game already exists between 2 teams, as data doesn't show that the 2 same teams face each other multiple times
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id='$WINNER_ID' AND opponent_id='$OPPONENT_ID'")
    if [[ -z $GAME_ID ]]
    then
      # Insert game into games table
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into games: $YEAR - $WINNER_NAME vs. $OPPONENT_NAME 
      fi
    fi
  fi
done