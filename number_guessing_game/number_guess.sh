#!/bin/bash
#Number_guessing_game
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1001))
NUMBER_OF_GUESSES=0

USER_TRIES() {

  while [[ ! $USER_GUESS -eq $SECRET_NUMBER ]]
  do 
 
    read USER_GUESS

    if [[ ! $USER_GUESS  =~ ^[0-9]+$ ]]
    then 
      echo -e "\nThat is not an integer, guess again:"
      

    elif [[ $USER_GUESS -gt $SECRET_NUMBER ]]
    then
      echo -e "\nIt's higher than that, guess again:"
      ((NUMBER_OF_GUESSES ++))
    
      
    elif [[ $USER_GUESS -lt $SECRET_NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:"
      ((NUMBER_OF_GUESSES ++))

    else
      ((NUMBER_OF_GUESSES ++))  
      return    
    fi
  done      
}


echo -e "\nEnter your username:"
read USER_NAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USER_NAME'")

if [[ -z $USER_ID ]]
then
  echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here."
  INSERT_NAME=$($PSQL "INSERT INTO users(username) VALUES('$USER_NAME')")

else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")
  echo -e "\nWelcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


echo -e "\nGuess the secret number between 1 and 1000:"

USER_TRIES


if [[ -z $USER_ID ]]
then 
  INSERT_GAME_PLAYED=$($PSQL "UPDATE users SET games_played = 1 WHERE username = '$USER_NAME'" )
  INSERT_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USER_NAME'")

else 
  INSERT_GAME_PLAYED=$($PSQL "UPDATE users SET games_played = $(($GAMES_PLAYED + 1)) WHERE user_id = $USER_ID")
  if [[  $BEST_GAME -gt $NUMBER_OF_GUESSES  ]]
  then
  INSERT_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE user_id = $USER_ID")
  fi
fi


echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
