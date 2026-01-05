delete:
	rm sqlite/test-db.db && ./sqlite/test-db.sh && ./sqlite/test-data-3.sh
test-data:
	sqlite3 ./sqlite/test-db.db < ./sqlite/new-test-data.sql
new-db-with-test-data:
	sqlite/db.sh && make test-data