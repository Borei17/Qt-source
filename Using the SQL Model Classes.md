- 除了`QSqlQuery`之外，Qt还提供了三个用于访问数据库的高级类。这些类是`QSqlQueryModel`、`QSqlTableModel`和`QSqlRelationalTableModel`。
  - `QSqlQueryModel`      基于任意SQL查询的只读模型。
  - `QSqlTableModel`	在单个表上工作的读写模型。
  - `QSqlRelationalTableModel`	一个支持外键的QSqlTableModel子类。
- 这些类派生自`QAbstractTableModel`(它又继承自`QAbstractItemModel`)，使在项目视图类(如QListView和QTableView)中表示数据库中的数据变得很容易。在表视图中显示数据一节中对此进行了详细解释。
- 使用这些类的另一个好处是，它可以使您的代码更容易适应其他数据源。例如，如果您使用`QSqlTableModel`，然后决定使用XML文件来存储数据，而不是数据库，那么本质上就是用另一个数据模型替换一个数据模型。
# The SQL Query Model
- QSqlQueryModel提供了一个基于SQL查询的只读模型。
```c++
	QSqlQueryModel model;
	model.setQuery("SELECT * FROM employee");

	for (int i = 0; i < model.rowCount(); ++i) {

		int id = model.record(i).value("id").toInt();
		QString name = model.record(i).value("name").toString();

		qDebug() << id << name;
	}
```
- 使用QSqlQueryModel::setQuery()设置查询后，您可以使用QSqlQueryModel::record(int)访问单个记录。您还可以使用QSqlQueryModel::data()和从QAbstractItemModel继承的任何其他函数。
- 还有一个setQuery()重载，它接受QSqlQuery对象并对其结果集进行操作。这使您能够使用QSqlQuery的任何特性来设置查询(例如，准备好的查询)。
# The SQL Table Model
- QSqlTableModel提供了一个读写模型，该模型一次只能在一个SQL表上工作。
```c++
	QSqlTableModel model;
	model.setTable("employee");
	model.setFilter("salary > 50000");
	model.setSort(2, Qt::DescendingOrder);
	model.select();

	for (int i = 0; i < model.rowCount(); ++i) {
		QString name = model.record(i).value("name").toString();
		int salary = model.record(i).value("salary").toInt();
		qDebug() << name << salary;
	}
```
- QSqlTableModel是QSqlQuery的高级替代方案，用于导航和修改单个SQL表。它通常会导致更少的代码，并且不需要SQL语法知识。
- 使用QSqlTableModel::record()检索表中的一行，使用QSqlTableModel::setRecord()修改行。例如，以下代码将使每个员工的工资增加10%:
```c++
	for (int i = 0; i < model.rowCount(); ++i) {
		QSqlRecord record = model.record(i);
		double salary = record.value("salary").toInt();
		salary *= 1.1;
		record.setValue("salary", salary);
		model.setRecord(i, record);
	}
	model.submitAll();
```
- 也可以使用继承自QAbstractItemModel的QSqlTableModel::data()和QSqlTableModel::setData()来访问数据。例如，下面是如何使用setData()更新记录:
```c++
	model.setData(model.index(row, column), 75000);
	model.submitAll();
```
- 下面是如何插入一行并填充它:
```c++
	model.insertRows(row, 1);
	model.setData(model.index(row, 0), 1013);
	model.setData(model.index(row, 1), "Peter Gordon");
	model.setData(model.index(row, 2), 68500);
	model.submitAll();
```
- 下面是如何删除五个连续的行:
```c++
    model.removeRows(row, 5);
   	model.submitAll();
```
- QSqlTableModel::removeRows()的第一个参数是要删除的第一行的索引。
- 当您完成更改一条记录时，您应该始终调用QSqlTableModel::submitAll()来确保更改已写入数据库。
- 何时以及是否实际需要调用submitAll()取决于表的编辑策略。
  - 默认策略是QSqlTableModel::OnRowChange，它指定当用户选择不同的行时，将挂起的更改应用到数据库。
  - QSqlTableModel::OnManualSubmit(在调用submitAll()之前，所有的更改都缓存在模型中)
  - QSqlTableModel::OnFieldChange(没有更改被缓存)。
  - 当QSqlTableModel与视图一起使用时，这些参数非常有用。
- QSqlTableModel::OnFieldChange似乎提供了你永远不需要显式调用submitAll()的承诺。不过，这里有两个陷阱:
  - 如果没有任何缓存，性能可能会显著下降。
  - 如果您修改了一个主键，那么在您尝试填充该记录时，该记录可能会从您的手指间溜走。
# The SQL Relational Table Model
QSqlRelationalTableModel extends QSqlTableModel to provide support for foreign keys. A foreign key is a 1-to-1 mapping between a field in one table and the primary key field of another table. For example, if a book table has a field called authorid that refers to the author table's id field, we say that authorid is a foreign key.

	
The screenshot on the left shows a plain QSqlTableModel in a QTableView. Foreign keys (city and country) aren't resolved to human-readable values. The screenshot on the right shows a QSqlRelationalTableModel, with foreign keys resolved into human-readable text strings.

The following code snippet shows how the QSqlRelationalTableModel was set up:
- QSqlRelationalTableModel扩展了QSqlTableModel，为外键提供支持。外键是一个表中的字段与另一个表的主键字段之间的一对一映射。例如，如果一个图书表有一个名为authorid的字段，它引用作者表的id字段，我们就说authorid是一个外键。
- 左边的截图显示了QTableView中的一个普通QSqlTableModel。外键(城市和国家)没有被解析为人类可读的值。右边的截图显示了一个QSqlRelationalTableModel，其中外键被解析为人类可读的文本字符串。
- 下面的代码片段显示了QSqlRelationalTableModel是如何设置的:
```c++
	model->setTable("employee");

	model->setRelation(2, QSqlRelation("city", "id", "name"));
	model->setRelation(3, QSqlRelation("country", "id", "name"));
```
See the QSqlRelationalTableModel documentation for details.


# Presenting Data in a Table View
- QSqlQueryModel、QSqlTableModel和QSqlRelationalTableModel类可以用作Qt视图类(如QListView、QTableView和QTreeView)的数据源。实际上，到目前为止，
## A table view displaying a QSqlTableModel
- 下面的示例创建一个基于SQL数据模型的视图:
```c++
	QTableView *view = new QTableView;
	view->setModel(model);
	view->show();
```
- 如果模型是一个读写模型(例如，QSqlTableModel)，视图允许用户编辑字段。你可以通过调用来禁用它``view->setEditTriggers(QAbstractItemView::NoEditTriggers);``

- 您可以使用相同的模型作为多个视图的数据源。如果用户通过其中一个视图编辑模型，其他视图将立即反映更改。表格模型示例显示了它是如何工作的。
- 视图类在顶部显示一个标头来标记列。要更改标题文本，请在模型上调用setHeaderData()。标头的标签默认为表的字段名。例如:
```c++
	model->setHeaderData(0, Qt::Horizontal, QObject::tr("ID"));
	model->setHeaderData(1, Qt::Horizontal, QObject::tr("Name"));
	model->setHeaderData(2, Qt::Horizontal, QObject::tr("City"));
	model->setHeaderData(3, Qt::Horizontal, QObject::tr("Country"));
```
- QTableView在左侧也有一个垂直标题，用数字标识行。如果您使用`QSqlTableModel::insertRows()`以编程方式插入行，那么新行将被标记为星号(*)，直到它们使用submitAll()提交，或者在用户移动到另一个记录时自动提交(假设编辑策略是QSqlTableModel::OnRowChange)。
## Inserting a row in a model
- 同样，如果您使用removeRows()删除行，这些行将被标记为感叹号(!)，直到提交更改
- 视图中的项使用委托呈现。默认的委托QItemDelegate处理最常见的数据类型(int、QString、QImage等)。当用户开始编辑视图中的项时，委托还负责提供编辑器小部件(例如，组合框)。你可以通过子类化`QAbstractItemDelegate`或`QItemDelegate`来创建你自己的委托。有关更多信息，请参阅模型/视图编程。
- QSqlTableModel经过优化，可以一次操作一个表。如果需要操作任意结果集的读写模型，则可以继承`QSqlQueryModel`并重新实现`flags()`和`setData()`，使其可读可写。以下两个函数使查询模型的字段1和字段2可编辑:
```c++
	Qt::ItemFlags EditableSqlModel::flags(const QModelIndex &index) const
	{
		Qt::ItemFlags flags = QSqlQueryModel::flags(index);
		if (index.column() == 1 || index.column() == 2)
			flags |= Qt::ItemIsEditable;
		return flags;
	}

	bool EditableSqlModel::setData(const QModelIndex &index, const QVariant &value, int /* role */)
	{
		if (index.column() < 1 || index.column() > 2)
			return false;

		QModelIndex primaryKeyIndex = QSqlQueryModel::index(index.row(), 0);
		int id = data(primaryKeyIndex).toInt();

		clear();

		bool ok;
		if (index.column() == 1) {
			ok = setFirstName(id, value.toString());
		} else {
			ok = setLastName(id, value.toString());
		}
		refresh();
		return ok;
	}
```
- setFirstName()帮助函数的定义如下:
```c++
	bool EditableSqlModel::setFirstName(int personId, const QString &firstName)
	{
		QSqlQuery query;
		query.prepare("update person set firstname = ? where id = ?");
		query.addBindValue(firstName);
		query.addBindValue(personId);
		return query.exec();
	}
```
- setLastName()函数类似。查看查询模型示例以获得完整的源代码。
- 子类化模型可以以多种方式自定义它:你可以为项目提供工具提示，改变背景颜色，提供计算值，为查看和编辑提供不同的值，特别处理空值，等等。请参阅模型/视图编程以及QAbstractItemView参考文档了解详细信息。
- 如果您所需要的只是将外键解析为对人类更友好的字符串，那么您可以使用QSqlRelationalTableModel。为了获得最佳效果，您还应该使用QSqlRelationalDelegate，这是一种提供用于编辑外键的组合框编辑器的委托。
## Editing a foreign key in a relational table
- 关系表模型示例说明了如何结合使用QSqlRelationalTableModel和QSqlRelationalDelegate来提供具有外键支持的表。



# Creating Data-Aware Forms
- 使用上面描述的SQL模型，数据库的内容可以呈现给其他模型/视图组件。对于某些应用程序，使用标准的项目视图(如QTableView)表示该数据就足够了。然而，基于记录的应用程序的用户通常需要基于表单的用户界面，在该界面中，数据库表中特定行或列的数据用于填充表单上的编辑器小部件。
- 这样的数据感知表单可以用QDataWidgetMapper类创建，这是一个通用的模型/视图组件，用于将数据从模型映射到用户界面中的特定小部件。
- QDataWidgetMapper操作特定的数据库表，将表中的项逐行或逐列映射。因此，将QDataWidgetMapper与SQL模型一起使用就像将它与任何其他表模型一起使用一样简单。
- 书中的例子展示了如何通过使用QDataWidgetMapper和一组简单的输入小部件来方便地访问信息。

# QSqlQueryModel详解
1. 功能概述
- QSqlQueryModel是QSqlTableModel的父类。QSqlQueryModel封装了执行SELECT语句从数据库查询数据的功能，但是QSqlQueryModel只能作为只读数据源使用，不可以编辑数据。
2. 常用API
   1. void clear()  //清除数据模型，释放所有获得的数据
   2. QSqlQuery query()  //返回当前关联的QSqlQuery()对象
   3. void setQuery()  //设置一个QSqlQuery对象，获取数据
   4. QSqlRecord record() //返回一个空记录，包含当前查询的字段信息
   5. QSqlRecord record(int row) //返回行号为row的记录
   6. QSqlQueryModel作为数据模型从数据库里查询数据，只需要使用setQuery()函数设置一个select查询语句即可。
3. QSqlQuery
- QSqlQuery是能执行任意SQL语句的类，如select、insert、update、delete等。能和QSqlQueryModel一起联合使用。

# QSqlTableModel详解
1. QSqlTableModel
- 用来显示数据库中数据表的数据，实现对数据的编辑、插入、删除等操作。实现数据的排序和过滤
2. 常用API
   1. void setTable(const QString &tableName)  //设置数据表名称
   2. void setFilter(const QString &filter)  //设置记录过滤条件
   3. void setSort(int column,Qt::SortOrder order)  //设置排序字段和排序规则，需调用select()才生效
   4. bool setHeaderData(int , Qt::Orientation , const QVariant &)  //设置表头
   5. int fieldIndex(QString &fieldName)  //根据字段名称返回其在模型中的字段序号，若字段不存在返回-1
   6. void select()  //查询数据表数据，并使用设置的排序和过滤规则
   7. void clear()  //清除数据模型，释放所有获取的数据
   8. QSqlRecord record()  //返回一条空记录，只有字段名，可用来获取字段信息
   9. bool insertRecord(int row,QSqlRecord &values)  //在行号row之前插入一条记录
   10. bool insertRows(int row,int count)  //在行号row之前插入count空行
   11. bool removeRows(int row,int count)  //从行号row开始，删除count行。
   12. bool submit()  //提交当前行的修改到数据库
   13. bool submitAll()  //提交所有未更新的修改到数据库
   14. QSqlTableModel::setEditStrategy()函数用于设置编辑策略
       1.  QSqlTableModel::OnFieldChange   //字段值变化时立即更新到数据库
       2.  QSqlTableModel::OnRowChange    //当前行变换时更新到数据库
       3.  QSqlTableModel::OnManualSubmit    //所有修改暂时缓存，手动调用submitAll()保存所有修改，或调用revertAll()取消所有未保存修改