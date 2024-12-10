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
update_passenger() {
    identifier=$1
    operation=$2  # Μορφή: fullname:<νέα τιμή> ή record:<νέα εγγραφή>

    if [[ ! -f "$FILE" ]]; then
        echo "Το αρχείο $FILE δεν υπάρχει. Βεβαιωθείτε ότι έχει δημιουργηθεί."
        exit 1
    fi

    # Εύρεση γραμμής του επιβάτη
    matched_line=$(grep -E "\b$identifier\b" "$FILE")

    if [[ -z "$matched_line" ]]; then
        echo "Δεν βρέθηκε επιβάτης με τον κωδικό, το όνομα ή το επώνυμο: $identifier."
        exit 1
    fi

    echo "Βρέθηκε η εγγραφή: $matched_line"

    # Διάσπαση της ενέργειας (operation) σε πεδίο και νέα τιμή
    IFS=":" read -r field new_value <<< "$operation"

    if [[ $field == "record" ]]; then
        # Ενημέρωση ολόκληρης της εγγραφής
        sed -i "s|$matched_line|$new_value|g" "$FILE"
        echo "Η εγγραφή ενημερώθηκε:"
        echo "Παλαιά: $matched_line"
        echo "Νέα: $new_value"
    else
        # Ενημέρωση συγκεκριμένου πεδίου
        field_index=-1
        case $field in
            code) field_index=1 ;;
            fullname) field_index=2 ;;
            age) field_index=3 ;;
            country) field_index=4 ;;
            status) field_index=5 ;;
            rescued) field_index=6 ;;
            *) echo "Άγνωστο πεδίο: $field" && exit 1 ;;
        esac

        # Αντικατάσταση του πεδίου με τη νέα τιμή
        updated_line=$(echo "$matched_line" | awk -F';' -v idx="$field_index" -v val="$new_value" '
            BEGIN {OFS = FS}
            {$idx = val; print}
        ')
        sed -i "s|$matched_line|$updated_line|g" "$FILE"
        echo "Το πεδίο ενημερώθηκε:"
        echo "Παλαιά: $matched_line"
        echo "Νέα: $updated_line"
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


read -p "Δώσε τον αριθμό ή Όνομα ή το Επώνυμο του επιβαίνοντα: " identifier operation
        update_passenger "$identifier" "$operation"








