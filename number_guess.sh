#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USER_NAME

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "$SECRET_NUMBER"

GET_USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name = '$USER_NAME';")

if [[ -z $GET_USER_ID ]]
then
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
  ADD_NEW_USER=$($PSQL "INSERT INTO users(user_name) VALUES('$USER_NAME');")
  GET_USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name = '$USER_NAME';")
else 
  GET_INFO_GAME=$($PSQL "SELECT COUNT(game_id), MIN(moves) FROM games WHERE user_id = $GET_USER_ID;")
  IFS='|' read TOTAL_GAMES BEST_GAME <<< "$GET_INFO_GAME"
  #echo "$TOTAL_GAMES $BEST_GAME"
  echo "Welcome back, $USER_NAME! You have played $TOTAL_GAMES games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read USER_GUESS

NUMBER_OF_GUESSES=1


while (( $USER_GUESS != $SECRET_NUMBER ))
do
  while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read USER_GUESS
  done
  if (( $SECRET_NUMBER > $USER_GUESS ))
  then
    echo "It's higher than that, guess again:"
  elif (( $SECRET_NUMBER < $USER_GUESS ))
  then 
    echo "It's lower than that, guess again:"
  else 
    #echo "$NUMBER_OF_GUESS"
    INSERT_GAME_INFO=$($PSQL "INSERT INTO games(user_id, moves) VALUES($GET_USER_ID, $NUMBER_OF_GUESSES);")
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
  read USER_GUESS
  ((NUMBER_OF_GUESSES++))
done

INSERT_GAME_INFO=$($PSQL "INSERT INTO games(user_id, moves) VALUES($GET_USER_ID, $NUMBER_OF_GUESSES);")
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
