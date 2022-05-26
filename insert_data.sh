#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Empty the tables
echo $($PSQL "TRUNCATE teams, games")

# Getting the info in the cvs file:
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Excluding the title columns
  if [[ $WINNER != winner ]]
  then
    # Check that winner is in db
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $WINNER_ID ]]
    then
      # If its empty, insert the team
      INSERT_TEAM=$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER')")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo "team $WINNER added to teams"
      fi
      # And get the new id for that team
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # Now do the same with opponent team
    OPPONENT_ID=$($PSQL "SELECT team_id from teams WHERE name='$OPPONENT'")
    # Let's check if there is into the db
    if [[ -z $OPPONENT_ID ]]
    then
      #if's not, it's time to added it
      INSERT_TEAM=$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT')")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo "team $OPPONENT added into teams"
      fi
      # time to get the opponent id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    fi

    # Finally, let's add the info into games table:
    GAME_INSERT=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $GAME_INSERT == "INSERT 0 1" ]]
    then
      echo "Game $ROUND: $WINNER vs $OPPONENT added."
    fi
  fi
done