# Data Provided In A Custom C++ Model
- 可以用c++定义模型，然后使其可供QML使用。这对于向QML公开现有的c++数据模型或复杂的数据集非常有用。
- c++模型类可以定义为
  - 1. QStringList
  - 2. QVariantList
  - 3. QObjectList
  - 4. QAbstractItemModel
  - 前三个用于公开更简单的数据集，而QAbstractItemModel为更复杂的模型提供了更灵活的解决方案。
## 1. QStringList-based Model
模型可以是一个简单的QStringList，它通过modelData角色提供列表的内容。
下面是一个ListView，它的委托使用modelData角色引用它的模型项的值:

  ListView {
      width: 100; height: 100

      model: myModel
      delegate: Rectangle {
          height: 25
          width: 100
          Text { text: modelData }
      }
  }
一个Qt应用程序可以加载这个QML文档，并将myModel的值设置为QStringList:
      QStringList dataList;
      dataList.append("Item 1");
      dataList.append("Item 2");
      dataList.append("Item 3");
      dataList.append("Item 4");

      QQuickView view;
      QQmlContext *ctxt = view.rootContext();
      ctxt->setContextProperty("myModel", QVariant::fromValue(dataList));
- 完整的源代码可以在Qt安装目录下的examples/quick/models/stringlistmodel中找到。
- 注意:视图无法知道QStringList的内容发生了变化。如果QStringList发生了变化，那么有必要再次调用QQmlContext::setContextProperty()来重置模型。

## 2. QVariantList-based Model
- 模型可以是一个QVariantList，它通过modelData角色提供列表的内容。
- 该API的工作原理与QStringList类似，如前一节所示。
- 注意:视图无法知道QVariantList的内容已经更改。如果QVariantList更改，则有必要重置模型。

## 3. QObjectList-based Model
QObject*值列表也可以用作模型。 QList<QObject*> 提供列表中对象的属性作为角色。
下面的应用程序创建了一个带有Q_PROPERTY值的DataObject类，当 QList<DataObject*> 暴露于QML将作为命名角色访问:
  class DataObject : public QObject
  {
      Q_OBJECT

      Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
      Q_PROPERTY(QString color READ color WRITE setColor NOTIFY colorChanged)
      ...
  };

  int main(int argc, char ** argv)
  {
      QGuiApplication app(argc, argv);

      QList<QObject*> dataList;
      dataList.append(new DataObject("Item 1", "red"));
      dataList.append(new DataObject("Item 2", "green"));
      dataList.append(new DataObject("Item 3", "blue"));
      dataList.append(new DataObject("Item 4", "yellow"));

      QQuickView view;
      view.setResizeMode(QQuickView::SizeRootObjectToView);
      QQmlContext *ctxt = view.rootContext();
      ctxt->setContextProperty("myModel", QVariant::fromValue(dataList));
      ...

The QObject* is available as the modelData property. As a convenience, the properties of the object are also made available directly in the delegate's context. Here, view.qml references the DataModel properties in the ListView delegate:

QObject*作为modelData属性可用。为了方便起见，对象的属性也可以直接在委托的上下文中使用。在这里view.qml在ListView委托中引用DataModel属性:
  ListView {
      width: 100; height: 100

      model: myModel
      delegate: Rectangle {
          height: 25
          width: 100
          color: model.modelData.color
          Text { text: name }
      }
  }
- 注意颜色属性与限定符的使用。对象的属性不会复制到模型对象中，因为它们很容易通过modelData对象获得。
- 完整的源代码可以在Qt安装目录下的examples/quick/models/objectlistmodel中找到。
- 注意:视图无法知道QList的内容发生了变化。如果QList改变，有必要通过再次调用QQmlContext::setContextProperty()来重置模型。

## QAbstractItemModel Subclass
- 可以通过`子类化QAbstractItemModel`来定义模型。如果您有其他方法无法支持的更复杂的模型，那么这是最好的方法。`当模型数据发生更改时，QAbstractItemModel还可以自动通知QML视图。`
- QAbstractItemModel子类的角色可以通过重载QAbstractItemModel::rolnames()公开给QML。

- 下面是一个具有名为AnimalModel的QAbstractListModel子类的应用程序，该类公开了类型和大小角色。它重新实现了QAbstractItemModel::rolnames()来公开角色名，这样它们就可以通过QML访问:
```c++
    class Animal
    {
    public:
        Animal(const QString &type, const QString &size);
        ...
    };

    class AnimalModel : public QAbstractListModel
    {
        Q_OBJECT
    public:
        enum AnimalRoles {
            TypeRole = Qt::UserRole + 1,
            SizeRole
        };

        AnimalModel(QObject *parent = 0);
        ...
    };

    QHash<int, QByteArray> AnimalModel::roleNames() const {
        QHash<int, QByteArray> roles;
        roles[TypeRole] = "type";
        roles[SizeRole] = "size";
        return roles;
    }

    int main(int argc, char ** argv)
    {
        QGuiApplication app(argc, argv);

        AnimalModel model;
        model.addAnimal(Animal("Wolf", "Medium"));
        model.addAnimal(Animal("Polar bear", "Large"));
        model.addAnimal(Animal("Quoll", "Small"));

        QQuickView view;
        view.setResizeMode(QQuickView::SizeRootObjectToView);
        QQmlContext *ctxt = view.rootContext();
        ctxt->setContextProperty("myModel", &model);
        ...
    }
```
This model is displayed by a ListView delegate that accesses the type and size roles:
```javascript
  ListView {
      width: 200; height: 250

      model: myModel
      delegate: Text { text: "Animal: " + type + ", " + size }
  }
```
- 当模型发生变化时，QML视图会自动更新。记住，模型必须遵循模型更改的标准规则，并通过使用QAbstractItemModel::datachchanged()、QAbstractItemModel::beginInsertRows()等方法在模型发生更改时通知视图。更多信息请参见模型子类化参考。
- 完整的源代码可以在Qt安装目录下的examples/quick/models/abstractitemmodel中找到。
- QAbstractItemModel提供了一个表的层次结构，但是目前由QML提供的视图只能显示列表数据。为了显示层次化模型的子列表，使用DelegateModel QML类型，它提供了以下属性和函数用于QAbstractItemModel类型的列表模型:
  - hasModelChildren 属性确定节点是否具有子节点。
  - DelegateModel::rootIndex 允许指定根节点
  - DelegateModel::modelIndex() 返回可以分配给DelegateModel::rootIndex的QModelIndex
  - DelegateModel::parentModelIndex() 返回可以分配给DelegateModel::rootIndex的QModelIndex
## SQL Models
- Qt提供了支持SQL数据模型的c++类。这些类在底层SQL数据上透明地工作，减少了运行SQL查询中如创建、插入或更新等基本SQL操作的需要。有关这些类的更多细节，请参见使用SQL模型类。
- 虽然c++类提供了操作SQL数据的完整特性集，但它们不提供对QML的数据访问。因此，必须将c++自定义数据模型实现为这些类之一的子类，并将其作为类型或上下文属性公开给QML。
### Read-only Data Model
- 自定义模型必须重新实现以下方法来启用对来自QML的数据的只读访问:

- rolnames()向QML前端公开角色名。例如，下面返回所选表的字段名作为角色名:
```c++
    QHash<int, QByteArray> SqlQueryModel::roleNames() const
    {
        QHash<int, QByteArray> roles;
        // record() returns an empty QSqlRecord
        for (int i = 0; i < this->record().count(); i ++) {
            roles.insert(Qt::UserRole + i + 1, record().fieldName(i).toUtf8());
        }
        return roles;
    }
```
- data()向QML前端公开SQL数据。例如，下面返回给定模型索引的数据:
```c++
    QVariant SqlQueryModel::data(const QModelIndex &index, int role) const
    {
        QVariant value;

        if (index.isValid()) {
            if (role < Qt::UserRole) {
                value = QSqlQueryModel::data(index, role);
            } else {
                int columnIdx = role - Qt::UserRole - 1;
                QModelIndex modelIndex = this->index(index.row(), columnIdx);
                value = QSqlQueryModel::data(modelIndex, Qt::DisplayRole);
            }
        }
        return value;
    }
```
- QSqlQueryModel类足以实现表示SQL数据库中的数据的自定义只读模型。聊天教程示例通过实现一个自定义模型来从SQLite数据库获取联系人详细信息，很好地演示了这一点。
### Editable Data Model
- QSqlTableModel实现了如下所述的setData()。
- 根据模型所使用的EditStrategy，更改要么排队等待稍后提交，要么立即提交。
- 还可以通过调用QSqlTableModel::insertRecord()将新数据插入到模型中。在以下示例代码片段中，QSqlRecord被填充为图书详细信息，并追加到模型:
```c++
    ...
    QSqlRecord newRecord = record();
    newRecord.setValue("author", "John Grisham");
    newRecord.setValue("booktitle", "The Litigators");
    insertRecord(rowCount(), newRecord);
    ...
```

## Exposing C++ Data Models to QML
- 上面的例子使用了QQmlContext::setContextProperty()在QML组件中直接设置模型值。另一种方法是将c++模型类注册为QML类型(可以直接从c++入口点注册，也可以在QML c++插件的初始化函数中注册，如下所示)。这将允许模型类作为QML中的类型直接创建:
```c++
    //C++	
    class MyModelPlugin : public QQmlExtensionPlugin
    {
        Q_OBJECT
        Q_PLUGIN_METADATA(IID "org.qt-project.QmlExtension.MyModel" FILE "mymodel.json")
    public:
        void registerTypes(const char *uri)
        {
            qmlRegisterType<MyModel>(uri, 1, 0,
                    "MyModel");
        }
    }
```
```javascript
    //QML	
    MyModel {
        id: myModel
        ListElement { someProperty: "some value" }
    }
    ListView {
        width: 200; height: 250
        model: myModel
        delegate: Text { text: someProperty }
    }
```
See Writing QML Extensions with C++ for details on writing QML C++ plugins.

## Changing Model Data
- 除了rolename()和data()之外，可编辑的模型还必须重新实现setData方法，以保存对现有模型数据的更改。以下版本的方法检查给定的模型索引是否有效，角色是否等于Qt::EditRole:
```c++
    bool EditableModel::setData(const QModelIndex &index, const QVariant &value, int role)
    {
        if (index.isValid() && role == Qt::EditRole) {
            // Set data in model here. It can also be a good idea to check whether
            // the new value actually differs from the current value
            if (m_entries[index.row()] != value.toString()) {
                m_entries[index.row()] = value.toString();
                emit dataChanged(index, index, { Qt::EditRole, Qt::DisplayRole });
                return true;
            }
        }
        return false;
    }
```
- 注意:保存更改后发出datachchanged()信号是很重要的。
- 与QListView或QTableView等c++项视图不同，setData()方法必须在适当的时候从QML委托中显式调用。这可以通过简单地为相应的模型属性分配一个新值来实现。
```javascript
    ListView {
        anchors.fill: parent
        model: EditableModel {}
        delegate: TextField {
            width: ListView.view.width
            text: model.edit
            onAccepted: model.edit = text
        }
    }
```
注意:edit角色等于Qt::EditRole。内置角色名请参阅rolnames()。然而，现实生活中的模型通常会注册自定义角色。