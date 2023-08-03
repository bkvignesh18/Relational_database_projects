#!/bin/bash
#Program for Simple Salon
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n\n~~~~~ MY SALON ~~~~~\n\n"

MAIN_MENU() {

  echo -e "Welcome to My Salon, how can I help you?\n"
  SERVICES
}

SERVICES() {
  
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICE=$($PSQL "SELECT service_id, name FROM services")

  echo "$SERVICE" | while read ID BAR NAME
  do
    echo "$ID) $NAME"
  done
  
  read SERVICE_ID_SELECTED
  
  if [[ $SERVICE_ID_SELECTED =~ ^[1-5]$ ]]
  then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    CUSTOMER 
  else
    echo -e "\nI could not find that service. What would you like today?\n"
    SERVICES 
  fi
}

CUSTOMER() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER_DETAILS=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  FIX_APPOINTMENT
}
    
FIX_APPOINTMENT() {
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"

}

MAIN_MENU

