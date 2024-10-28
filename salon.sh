#!/bin/bash

# Función para mostrar el menú de servicios
show_menu() {
  # Ejecuta la consulta SQL y guarda los resultados
  services=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT service_id, name FROM services ORDER BY service_id;")

  # Imprime la cabecera
  echo "~~~~~ MY SALON ~~~~~"
  echo ""
  echo "Welcome to My Salon, how can I help you?"
  echo ""

  # Itera sobre los resultados y muestra las opciones
  IFS=$'\n'
  for service in $services; do
    service_id=$(echo $service | cut -d'|' -f1)
    service_name=$(echo $service | cut -d'|' -f2)
    echo "$service_id) $service_name"
  done
}

# Bucle para solicitar una selección válida
while true; do
  # Muestra el menú de servicios
  show_menu

  # Solicita al usuario que seleccione un servicio
  echo "Please select a service by entering the service ID:"
  read SERVICE_ID_SELECTED

  # Verifica si la selección es válida
  service_exists=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT EXISTS(SELECT 1 FROM services WHERE service_id = $SERVICE_ID_SELECTED);")

  if [[ $service_exists == "t" ]]; then
    # Obtener el nombre del servicio seleccionado
    SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

    # Solicita el número de teléfono del cliente
    echo "Please enter your phone number:"
    read CUSTOMER_PHONE

    # Verifica si el cliente ya existe
    customer_name=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

    # Si el cliente no existe, solicita el nombre y lo inserta en la base de datos
    if [[ -z $customer_name ]]; then
      echo "It seems you're a new customer. Please enter your name:"
      read CUSTOMER_NAME
      psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
    else
      CUSTOMER_NAME=$customer_name
    fi

    # Solicita la hora del servicio
    echo "Please enter the time you'd like to schedule (e.g., 14:00):"
    read SERVICE_TIME

    # Inserta la cita en la base de datos
    customer_id=$(psql --username=freecodecamp --dbname=salon -t -A -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($customer_id, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

    # Mensaje de confirmación
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    break
  else
    echo "Invalid selection. Please try again."
  fi
done




