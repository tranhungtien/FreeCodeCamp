#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align --tuples-only -c"

if [[ ! $1 ]] 
then
  echo "Please provide an element as an argument."
else 
  if [[ $1 =~ ^[0-9]+$ ]]
  then 
    CONDITION="atomic_number = $1"
  else 
    CONDITION="symbol = '$1' OR name = '$1'"
  fi
  GET_ELEMENT=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass AS MASS, melting_point_celsius AS MELTING, boiling_point_celsius AS BOILING, type FROM elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE $CONDITION;")
  if [[ -z $GET_ELEMENT ]]
  then
    echo "I could not find that element in the database."
  else 
    echo "$GET_ELEMENT" | while IFS="|" read ATOMIC_NUMBER SYMBOL NAME MASS MELTING BOILING TYPE
    do
      #echo "$ATOMIC_NUMBER $SYMBOL $NAME $MASS $MELTING $BOILING $TYPE"
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  fi
fi
