#!/bin/bash

# Δήλωση μεταβλητής FILE
FILE="passengers.csv"

# Συνάρτηση για εισαγωγή δεδομένων στο αρχείο
insert_data() {
# Παράμετρος που αντιπροσωπέυει το Path του αρχείου 
input_file=$1

# Αν το αρχείο υπάρχει, αντίγραψε το στο αρχείο FILE 
if [ -f "$input_file" ]; then 
        cp "$input_file" "$FILE"
        echo "Τα δεδομένα από το αρχείο $input_file αποθηκεύτηκαν στο $FILE."
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

# Αν το αρχείο δεν υπάρχει, δώσε τα δεδομένα
elif [ ! -f "$input_file" ]; then
        echo "code;fullname;age;country;status;rescued" > "$FILE"
        echo "Εισάγετε δεδομένα επιβατών με τη μορφή (Για έξοδο γράψε exit): 
        [code];[fullname];[age];[country];[status (Passenger/Crew)];[rescued (Yes/No)]"

    # Κάθε γραμμή που εισάγει ο χρήστης, αντίγραψε την και πρόσθεσε την στο τέλος του αρχείου FILE 
    while read -r line; do
        if [ $line == "exit" ]; then
            exit 1
        else
            echo "$line" >> "$FILE"
        fi
    done
    echo "Τα δεδομένα αποθηκεύτηκαν στο αρχείο $FILE."

else    echo "Μη έγκυρη επιλογή."
        exit
        
fi
}















# Συνάρτηση για αναζήτηση στοιχείων επιβάτη
search_passenger() {
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
            echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
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
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        echo "Παλαιά: $matched_line"
        echo "Νέα: $updated_line"
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    fi
}









# Συνάρτηση για προβολή του αρχείου
display_file() {
    # Αν το αρχείο υπάρχει, εμφάνισε τα περιέγχόμενα μέχρι να γεμίσει η οθόνη
    if [[ -f "$FILE" ]]; then
        echo "Προβολή περιεχομένων του αρχείου:"
        less "$FILE"
    # Αν δεν υπάρχει σταμάτα
    else
        echo "Το αρχείο $FILE δεν υπάρχει. Βεβαιωθείτε ότι έχει δημιουργηθεί."
        exit 1
    fi
}


# Συνάρτηση για δημιουργία αναφορών
generate_reports() {

# Δήλωση μεταβλητών αρχείων για τα reports
AGES="ages.txt"
PERCENTAGES="percentages.txt"
AVG_STATUS="avg.txt"
RESCUED="rescued.txt"

# Εμφάνισε menu επιλογής για τα γκρούπ ηλικείας
echo -e "1-18 (1)\n19-35 (2)\n36-50 (3)\n51+ (4)"
read -p "Δώσε το γκρουπ ηλικειακής ομάδας: " pick 
  case $pick in
            1)  
                # Αν επέλεξες 1, τότε ομαδοποίησε τις εγγραφες που έχουν 
                # ηλικεία μεταξύ 1 και 18 και αποθήκευσε τις στο age_group
                local age_group=$(awk -F';'  '{ if ($3 >= 1 && $3 <= 18) print }' "$FILE")
                # Αντέγραψε τις στο αρχείο ages.txt
                echo -e "$age_group\n" > "$AGES" 
                ;;
            2)  
                # Αν επέλεξες 2, τότε ομαδοποίησε τις εγγραφες που έχουν 
                # ηλικεία μεταξύ 19 και 35 και αποθήκευσε τις στο age_group
                local age_group=$(awk -F';'  '{ if ($3 >= 19 && $3 <= 35) print }' "$FILE")
                # Αντέγραψε τις στο αρχείο ages.txt
                echo -e "$age_group\n" > "$AGES" 
                ;;
            3)  
                # Αν επέλεξες 3, τότε ομαδοποίησε τις εγγραφες που έχουν 
                # ηλικεία μεταξύ 36 και 50 και αποθήκευσε τις στο age_group
                local age_group=$(awk -F';'  '{ if ($3 >= 36 && $3 <= 50) print }' "$FILE")
                # Αντέγραψε τις στο αρχείο ages.txt
                echo -e "$age_group\n" > "$AGES" 
                ;;
            4) 
                # Αν επέλεξες 4, τότε ομαδοποίησε τις εγγραφες που έχουν 
                # ηλικεία 51+ και αποθήκευσε τις στο age_group
                local age_group=$(awk -F';'  '{ if ($3 >= 51) print }' "$FILE")
                # Αντέγραψε τις στο αρχείο ages.txt
                echo -e "$age_group\n" > "$AGES" 
                ;;
            *) echo "Μη επιτρεπτή επιλογή: $pick" && exit 1 ;;
        esac

# Αποθήκευσε στην μεταβλητή total_count τον αριθμό γραμμών(εγγραφών) του ages report
local total_count=$(wc -l < "$AGES")
# Αποθήκευσε στην μεταβλητή has_rescued τον αριθμό γραμμών(εγγραφών) που περιέγχουν το pattern: "yes"
local has_rescued=$(grep -c "\byes\b" "$AGES")
# Αποθήκευσε στην μεταβλητή percentage το % ποσοστό των επιβατών που συμμετύχαν στην διάσωση προς τους συνολικούς
local percentage=$(( (has_rescued * 100) / total_count ))

#Αντέγραψε το ποσοστό στο αρχείο percentages.txt
echo -e "percentage for choice $pick: $percentage%\n" > "$PERCENTAGES" 


# Ομαδοποίησε τις εγγραφες που έχουν ως status crew, υπολόγισε
# το άθροισμα των ηλικειών τους και το πλήθος τους και υπολόγισε τον μέσο όρο
local crew_avg_age=$(awk -F';' '$5 == "Crew" {sum += $3; count++} END {if (count > 0) print sum / count; else print 0}' "$AGES")
# Ομαδοποίησε τις εγγραφες που έχουν ως status Passenger, υπολόγισε
# το άθροισμα των ηλικειών τους και το πλήθος τους και υπολόγισε τον μέσο όρο
local passenger_avg_age=$(awk -F';' '$5 == "Passenger" {sum += $3; count++} END {if (count > 0) print sum / count; else print 0}' "$AGES")

# Αποθήκευσε τις μέσες ηλικείες για κάθε status σε μεταβλήτες και αντίγραψε τις στο αρχείο avg.txt
echo -e "Μέση ηλικία πληρώματος: $crew_avg_age\nΜέση ηλικία επιβατών: $passenger_avg_age" > "$AVG_STATUS"

# Αποθήκευσε στην rescued τις εγγραφές οι οποίες περιέχουν το pattern: "yes" και αντέγραψε τις στο αρχείο rescued.txt
local rescued=$(grep "\byes\b" "$AGES")
echo "code;fullname;age;country;status;rescued" > "$RESCUED"
echo $rescued >> "$RESCUED"
}





# Συνάρτηση για έλεγχο ορισμάτων τροποποίησης
arguement_handler() {

# Αν δεν δίνονται 2 ορίσματα σταμάτα
if [ -z $1 -a -z $2 ]; then
     echo "Δεν δόθηκαν ορίσματα για τροποποίηση"

# Αν το όρισμα είναι "reports" κάλεσε τη συνάρτηση generate_reports
elif [ $1 == "reports" ]; then
    generate_reports



# Αν δίνεται 1 όρισμα κάλεσε την συνάρτηση αναζήτησης
elif [ -n $1 -a -z $2 ]; then
     search_passenger "$1"


    
# Αν δίνονται 2 ορίσματα κάλεσε την συνάρτηση τροποποίησης
else
    echo "Δοσμένο όρισμα: $1"
    echo "Αριθμός ορισμάτων: $#"
    update_passenger "$1" "$2"
fi
}






# MAIN

# Δώσε το Path του αρχείου και κάλεσε την συνάρτηση insert_data
read -p "Δώσε το Path του αρχείου: " input_file
    insert_data "$input_file"

# Δώσε το Όνομα ή το Επώνυμο του επιβάτη και κάλεσε την συνάρτηση search_passenger
read -p "Δώσε το Όνομα ή το Επώνυμο του επιβαίνοντα: " NAME
    search_passenger "$NAME"

# Ανάλογα με τα ορίσματα που δόθηκαν, είτε θα καλέσει η συνάρτηση arguement_hander την 
# συνάρτηση update_passenger(2 ορίσματα), είτε θα καλέσει την find_passenger (1 όρισμα),
# είτε την generate reports ( όρισμα: reports)
arguement_handler "$1" "$2"


read -p "Εμφάνιση περιεγχομένου του αρχείου; ΝΑΙ=1|ΟΧΙ=0 " choice
# Αν θέλεις να εμφανιστεί το περιεγχόμενο του αρχείου, κάλεσε τη συνάρτηση display_file, αλλιώς σταμάτα
if [ $choice = "1" ]; then
    display_file
else 
    exit
    
fi




