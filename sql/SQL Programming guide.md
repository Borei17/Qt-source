# Using
- #include <QtSql>
- QT += sql

# Topics:
1. Database Classes
2. Connecting to Databases
3. SQL Database Drivers
4. Executing SQL Statements
5. Data Types for Qt-supported Database Systems
6. Using the SQL Model Classes
7. Presenting Data in a Table View
8. Creating Data-Aware Forms

# 1. Database Classes
- SQL classes 分为三层：
1. Driver Layer
   - `QSqlDriver`, `QSqlDriverCreator`, `QSqlDriverCreatorBase`, `QSqlDriverPlugin`, and `QSqlResult`.
   - This layer provides `the low-level bridge between the specific databases and the SQL API layer`. 
   - See `SQL Database Drivers` for more information.
  
2. SQL API Layer
   - These classes provide access to databases. 
     - `Connections` are made using the `QSqlDatabase` class. 
     - `Database interaction` is achieved by using the `QSqlQuery` class. 
     - `QSqlError`, `QSqlField`, `QSqlIndex`, and `QSqlRecord`.

3. User Interface Layer
   - `QSqlQueryModel`, `QSqlTableModel`, and `QSqlRelationalTableModel`. 
   - These classes link the data from a database to data-aware widgets. 
   - These classes are designed to work with Qt's model/view framework.
   - **Note:** a QCoreApplication object must be instantiated before using any of these classes.

# 2. Connecting to Databases
- Note the difference between creating a connection and opening it. Creating a connection involves creating an instance of class `QSqlDatabase`. The connection is not usable until it is opened. 
- The following snippet shows how to create `a default connection` and then open it:
```c++
	//creates the connection object
	QSqlDatabase db = QSqlDatabase::addDatabase("QMYSQL");	//"QMYSQL"specifies the type of database driver to use
	//initialize some connection information
	db.setHostName("bigblue");
	db.setDatabaseName("flightdb");
	db.setUserName("acarlson");
	db.setPassword("1uTbSbAs");
	//opens it for use
	bool ok = db.open();	
```
- pass the second argument to addDatabase(), which is the connection name. 
- For example, here we establish two MySQL database connections named "first" and "second":
```c++
	QSqlDatabase firstDB = QSqlDatabase::addDatabase("QMYSQL", "first");
	QSqlDatabase secondDB = QSqlDatabase::addDatabase("QMYSQL", "second");
```
- After these connections have been initialized, `open()` for each one to establish the live connections. 
- If the `open()` fails, it returns false. In that case, call `QSqlDatabase::lastError()` to get error information.

- Once a connection is established, we can call the static function QSqlDatabase::database() from anywhere with a connection name to get a pointer to that database connection. 
- If we don't pass a connection name, it will return the default connection. For example:
```c++
      QSqlDatabase defaultDB = QSqlDatabase::database();
      QSqlDatabase firstDB = QSqlDatabase::database("first");
      QSqlDatabase secondDB = QSqlDatabase::database("second");
```
- To remove a database connection,
  - first close the database using `QSqlDatabase::close()`
  - then remove it using the static method `QSqlDatabase::removeDatabase()`

# 3. SQL Database Drivers
- The table below lists the drivers included with Qt:
  - `QDB2`	IBM DB2 (version 7.1 and above)
  - `QIBASE`	Borland InterBase
  - `QMYSQL`	MySQL
  - `QOCI`	Oracle Call Interface Driver
  - `QODBC`	Open Database Connectivity (ODBC) - Microsoft SQL Server and other ODBC-compliant databases
  - `QPSQL`	PostgreSQL (versions 7.3 and above)
  - `QSQLITE2`	SQLite version 2
  - `QSQLITE`	SQLite version 3
  - `QTDS`	Sybase Adaptive Server

# 4. Executing SQL Statements
1. **Executing a Query**
- To execute an SQL statement, simply create a QSqlQuery object and call QSqlQuery::exec() like this:
```c++
      QSqlQuery query;
      query.exec("SELECT name, salary FROM employee WHERE salary > 50000");
```
- The QSqlQuery constructor accepts an optional QSqlDatabase object that specifies which database connection to use. 
- In the example above, we don't specify any connection, so the default connection is used.
- If an error occurs, exec() returns false. The error is then available as QSqlQuery::lastError().

2. **Navigating the Result Set**
- QSqlQuery provides access to the result set one record at a time. 
- After the call to exec(), QSqlQuery's internal pointer is located one position before the first record. 
- We must call QSqlQuery::next() once to advance to the first record, then next() again repeatedly to access the other records, until it returns false.
```c++
	while (query.next()) {
		QString name = query.value(0).toString();
		int salary = query.value(1).toInt();
		qDebug() << name << salary;
	}
```
- `QSqlQuery::value()` returns the value of a field in the current record. Fields are specified as zero-based indexes. 
- You can navigate within the dataset using `QSqlQuery::next()`, `QSqlQuery::previous()`, `QSqlQuery::first()`, `QSqlQuery::last()`, and `QSqlQuery::seek()`. The current row index is returned by `QSqlQuery::at()`, and the total number of rows in the result set is available as `QSqlQuery::size()` for databases that support it.
- To determine whether a database driver supports a given feature, use `QSqlDriver::hasFeature()`. In the following example, we call `QSqlQuery::size()` to determine the size of a result set of the underlying database supports that feature; otherwise, we navigate to the last record and use the query's position to tell us how many records there are.
```c++
	QSqlQuery query;
	int numRows;
	query.exec("SELECT name, salary FROM employee WHERE salary > 50000");

	QSqlDatabase defaultDB = QSqlDatabase::database();
	if (defaultDB.driver()->hasFeature(QSqlDriver::QuerySize)) {
		numRows = query.size();
	} else {
		// this can be very slow
		query.last();
		numRows = query.at() + 1;
	}
```
- If you navigate within a result set, and use next() and seek() only for` browsing forward`, you can call `QSqlQuery::setForwardOnly(true)` before calling exec(). This is an easy optimization that will speed up the query significantly when operating on large result sets.
3. **Inserting, Updating, and Deleting Records**
- INSERT:
	```c++
		QSqlQuery query;
		query.exec("INSERT INTO employee (id, name, salary) "
					"VALUES (1001, 'Thad Beaumont', 65000)");
	```
	- If you want to `insert many records at the same time`, it is often more efficient to separate the query from the actual values being inserted. This can be done using placeholders. Qt supports two placeholder syntaxes: named binding and positional binding.
	- Here's an example of named binding:
	```c++
			QSqlQuery query;
			query.prepare("INSERT INTO employee (id, name, salary) "
						"VALUES (:id, :name, :salary)");
			query.bindValue(":id", 1001);
			query.bindValue(":name", "Thad Beaumont");
			query.bindValue(":salary", 65000);
			query.exec();
	```
	- Here's an example of positional binding:
	```c++
			QSqlQuery query;
			query.prepare("INSERT INTO employee (id, name, salary) "
						"VALUES (?, ?, ?)");
			query.addBindValue(1001);
			query.addBindValue("Thad Beaumont");
			query.addBindValue(65000);
			query.exec();
	```
	- Both syntaxes work with all database drivers provided by Qt. 
	- When inserting multiple records, you only need to call `QSqlQuery::prepare()` once. Then you call `bindValue()` or `addBindValue()` followed by` exec()` as many times as necessary.
- Updating a record is similar to inserting it into a table:
	```c++
		QSqlQuery query;
		query.exec("UPDATE employee SET salary = 70000 WHERE id = 1003");
	```
	You can also use named or positional binding to associate parameters to actual values.

- DELETE statement:
	```c++
		QSqlQuery query;
		query.exec("DELETE FROM employee WHERE id = 1007");
	```
4. **Transactions**(事务)
- If the underlying database engine supports transactions, `QSqlDriver::hasFeature(QSqlDriver::Transactions)` will return true.
- You can use `QSqlDatabase::transaction()` to initiate a transaction, followed by the SQL commands you want to execute within the context of the transaction, and then either `QSqlDatabase::commit()`提交 or `QSqlDatabase::rollback()`回滚. 
- When using transactions you must `start the transaction before you create your query`.
- Example:
```c++
	QSqlDatabase::database().transaction();
	QSqlQuery query;
	query.exec("SELECT id FROM employee WHERE name = 'Torild Halvorsen'");
	if (query.next()) {
		int employeeId = query.value(0).toInt();
		query.exec("INSERT INTO project (id, name, ownerid) "
					"VALUES (201, 'Manhattan Project', "
					+ QString::number(employeeId) + ')');
	}
	QSqlDatabase::database().commit();
```
- Transactions can be used to ensure that a complex operation is atomic (for example, looking up a foreign key and creating a record), or to provide a means of canceling a complex change in the middle.
