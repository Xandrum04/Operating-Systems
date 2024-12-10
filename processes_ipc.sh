#!/bin/bash

FILE="passengers.csv"


input_from_keyboard() {
    echo "Εισάγετε δεδομένα επιβατών με τη μορφή [code];[fullname];[age];[country];[status (Passenger/Crew)];[rescued
(Yes/No)]"
    while read -r line; do
        echo "$line" >> "$FILE"
    done
    echo "Τα δεδομένα αποθηκεύτηκαν στο αρχείο $FILE."
}


input_from_file() {
     input_file=$1
    if [[ -f "$input_file" ]]; then
        cp "$input_file" "$FILE"
        echo "Τα δεδομένα από το αρχείο $input_file αποθηκεύτηκαν στο $FILE."
    else
        echo "Το αρχείο $input_file δεν βρέθηκε."
        exit 1
    fi
}


find_passenger() {
    NAME=$1
    if [[ -f "$FILE" ]]; then
        echo "Αναζήτηση για τον επιβάτη: $NAME"
        result=$(grep "\b$NAME\b" "$FILE")
        if [[ -n "$result" ]]; then
            echo "Βρέθηκαν τα εξής στοιχεία:"
            echo "$result"
        else
            echo "Δεν βρέθηκε επιβάτης με το όνομα ή το επώνυμο: $NAME."
        fi
    else
        echo "Το αρχείο $FILE δεν υπάρχει. Βεβαιωθείτε ότι έχει δημιουργηθεί."
        exit 1
    fi
}


read -p "Δώσε το Path του αρχείου: " input_file
if [ -f "$input_file" ]; then 
        input_from_file "$input_file"

elif [ ! -f "$input_file" ]; then
        echo "code;fullname;age;country;status;rescued" > "$FILE"
        input_from_keyboard

else    echo "Μη έγκυρη επιλογή."
        exit
        
fi

read -p "Δώσε το Όνομα ή το Επώνυμο του επιβαίνοντα: " NAME
        find_passenger "$NAME"












