import psycopg2
import csv

# Connect to Postgres
conn = psycopg2.connect(
    host="localhost",
    database="tasty",
    user="app",
    password="password"
)

# Open the CSV file and create a cursor
csv_file = open('data.csv')
csv_reader = csv.DictReader(csv_file)

# Get the column names from the first row of the CSV file
column_names = csv_reader.fieldnames

# Skip the first row (header)
next(csv_reader)

# Iterate over each row and insert it into the database
for row in csv_reader:
    values = [row[column_name] for column_name in column_names]
    cur = conn.cursor()
    cur.execute("INSERT INTO transactions VALUES ({})".format(','.join(['%s']*len(column_names))), values)
    conn.commit()
    cur.close()

# Close the CSV file and the database connection
csv_file.close()
conn.close()
