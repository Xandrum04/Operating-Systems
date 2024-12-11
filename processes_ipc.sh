#!/bin/bash

# Δήλωση μεταβλητής FILE
FILE="passengers.csv" 

# Συνάρτηση για εισαγωγή δεδομένων από τον χρήστη
input_from_keyboard() {
    echo "Εισάγετε δεδομένα επιβατών με τη μορφή [code];[fullname];[age];[country];[status (Passenger/Crew)];[rescued
(Yes/No)]"

    # Κάθε γραμμή που εισάγει ο χρήστης, αντίγραψε την και πρόσθεσε την στο τέλος του αρχείου FILE 
    while read -r line; do
        echo "$line" >> "$FILE"
    done
    echo "Τα δεδομένα αποθηκεύτηκαν στο αρχείο $FILE."
}


# Συνάρτηση για εισαγωγή δεδομένων από αρχείο
input_from_file() {
    # Παράμετρος που αντιπροσωπέυει το Path του αρχείου  
    input_file=$1
    # Αν το αρχείο υπάρχει, αντίγραψε το στο αρχείο FILE 
    if [[ -f "$input_file" ]]; then
        cp "$input_file" "$FILE"
        echo "Τα δεδομένα από το αρχείο $input_file αποθηκεύτηκαν στο $FILE."
    # Αν δεν υπάρχει το αρχείο, σταμάτα 
    else
        echo "Το αρχείο $input_file δεν βρέθηκε."
        exit 1
    fi
}

# Συνάρτηση για αναζήτηση στοιχείων επιβάτη
find_passenger() {
    # Παράμετρος που αντιπροσωπέυει το Όνομα/Επώνυμο του επιβάτη
    local NAME=$1
    # Αν το αρχείο υπάρχει, βρες τον επιβάτη
    if [[ -f "$FILE" ]]; then
        echo "Αναζήτηση για τον επιβάτη: $NAME"
        # Αναζήτησε εγγραφές που ταιριάζουν στο πεδίο fullname (2η στήλη)
        # Χώρισε το πεδίο fullname σε όνομα και επώνυμο
        # Έλεγξε αν το NAME αντιστοιχεί σε όνομα ή απώνυμο ή full name
        local result=$(awk -F';' -v id="$NAME" '
    {
        split($2, names, " ")
        if ($2 == id || names[1] == id || names[2] == id) {
            print
        }
    }' "$FILE")

        
        # Αν το αποτέλεσμα είναι μη μηδενικό εμφάνισε το 
        if [[ -n "$result" ]]; then
            echo "Βρέθηκαν τα εξής στοιχεία:"
            echo "$result"
        # Αλλιώς σταμάτα
        else
            echo "Δεν βρέθηκε επιβάτης με το όνομα ή το επώνυμο: $NAME."
            exit 1
        fi
    # Αν δεν υπάρχει το αρχείο, σταμάτα
    else
        echo "Το αρχείο $FILE δεν υπάρχει. Βεβαιωθείτε ότι έχει δημιουργηθεί."
        exit 1
    fi
}

# Συνάρτηση για τροποποίηση στοιχείων επιβάτη
update_passenger() {
    # 1η παράμετρος που αντιπροσωπέυει το Όνομα ή το Επώνυμο ή τον αριθμό του επιβάτη
    local identifier=$1
    # 2η παράμετρος που αντιπροσωπέυει το πεδίο και τη τροποποιημένη μορφή που θέλουμε
    # Μορφή: fullname:<νέα τιμή> ή record:<νέα εγγραφή>
    local operation=$2  
    
    # Αν το αρχείο υπάρχει, βρες τον επιβάτη
    if [[ -f "$FILE" ]]; then
        echo "Αναζήτηση για τον επιβάτη: $identifier"
        # Αναζήτησε εγγραφές που ταιριάζουν στο πεδίο code ή fullname (1η ή 2η στήλη)
        # Χώρισε το πεδίο fullname σε όνομα και επώνυμο
        # Έλεγξε αν το NAME αντιστοιχεί σε όνομα ή απώνυμο ή full name ή code
        local matched_line=$(awk -F';' -v id="$identifier" '
    {
        split($2, names, " ")
        if ($1 == id || $2 == id || names[1] == id || names[2] == id) {
            print
        }
    }' "$FILE")
    
        # Αν το αποτέλεσμα είναι μη μηδενικό εμφάνισε το 
        if [[ -n "$matched_line" ]]; then
            echo "Βρέθηκαν τα εξής στοιχεία:"
            echo "$matched_line"
        # Αλλιώς σταμάτα
        else
            echo "Δεν βρέθηκε επιβάτης με το όνομα ή το επώνυμο ή τον αριθμό: $identifier."
            exit 1
        fi
    # Αν δεν υπάρχει το αρχείο, σταμάτα
    else
        echo "Το αρχείο $FILE δεν υπάρχει. Βεβαιωθείτε ότι έχει δημιουργηθεί."
        exit 1
    fi
   
    # Διάσπαση της ενέργειας (operation) σε πεδίο και τροποποιημένη μορφή που θέλουμε
    IFS=":" read -r field new_value <<< "$operation"

    # Αν αντί για πεδίο θέλω όλη την εγγραφή
    if [[ $field == "record" ]]; then
        # Κάνε την ενημέρωση του επιβάτη στο αρχείο απευθείας
        sed -i "s|$matched_line|$new_value|g" "$FILE"
        echo "Η εγγραφή ενημερώθηκε:"
        echo "Παλαιά: $matched_line"
        echo "Νέα: $new_value"
    else
        # Ενημέρωση συγκεκριμένου πεδίου
        local field_index=-1
        case $field in
            "code") field_index=1 ;;
            "fullname") field_index=2 ;;
            "age") field_index=3 ;;
            "country") field_index=4 ;;
            "status") field_index=5 ;;
            "rescued") field_index=6 ;;
            *) echo "Άγνωστο πεδίο: $field" && exit 1 ;;
        esac

        
        # Χρησιμοποιώντας την εντολή awk, όρισε το ; ως διαχωρίστικο, 
        # αποθήκευσε το field_index στο matched_index και την νέα τιμή στο Val
        # Όρισε τον διαχωριστή εξόδου ως ίδιο με τον διαχωριστή εισόδου: ";"
        # Γράψε στο πεδίο την νέα τιμή 
        # Αποθήκευσε την ενημερωμένη γραμμή
        local updated_line=$(echo "$matched_line" | awk -F';' -v matched_index="$field_index" -v val="$new_value" '
            BEGIN {OFS = FS}
            {$matched_index = val; print}
        ')
        # Κάνε την ενημέρωση του επιβάτη στο αρχείο απευθείας
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


read -p "Δώσε τον αριθμό ή Όνομα του επιβαίνοντα και την ενέργεια
        Μορφή: <identifier> πεδίο:<νέα τιμή> ή record:<νέα εγγραφή>: " identifier operation
        update_passenger "$identifier" "$operation"








