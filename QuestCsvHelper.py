import csv
import sys
import getopt
import pyperclip


fn = "Quests.csv"

def main(argv):
    column = None
    searchterm = None
    outputformat = None
    try:
        opts, args = getopt.getopt(argv,"ho:c:s:",["column=","search=","output="])
    except getopt.GetoptError:
        print_help()
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print_help()
            sys.exit()
        elif opt in ("-c", "--column"):
            column = int(arg)
        elif opt in ("-s", "--search"):
            searchterm = arg
        elif opt in ("-o", "--output"):
            outputformat = arg
        
    if searchterm is None:
        print_help("Searchterm is missing")
        sys.exit()
    
    searchQuests(searchterm, column, outputformat)

def searchQuests(searchterm, column=None, outputformat=None):
    output = ""
    with open(fn) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=",")
        for row in csv_reader:
            tmp = ""
            if column is not None:
                tmp = row[column]
            else:
                tmp = ",".join(row)
            if searchterm in tmp:
                output_row = print_row(row, outputformat) + "\n"
                output += output_row
                if __name__ == "__main__": print(output_row)
    pyperclip.copy(output)
    return output

def print_row(row, outputformat=None):
    s = ""
    if outputformat == "lua":
        s = '[{}] = {},'.format(row[0],row[1])
    else:
        s = ",".join(row)
    return s

def print_help(optional):
    if optional:
        print(optional)
    print('QuestCsvHelper.py -c <column_number> -s <searchterm>, -o lua')

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print_help()
    else:
        main(sys.argv[1:])