简单地说，应用程序需要形成数据并显示数据。Qt Quick有模型、视图和委托的概念来显示数据。它们将可视数据模块化，以便让开发人员或设计人员能够控制数据的不同方面。开发人员可以用网格视图交换列表视图，只需对数据进行少许更改。类似地，将数据的实例封装在委托中允许开发人员指定如何表示或处理数据。
Model - contains the data and its structure. There are several QML types for creating models.
View - a container that displays the data. The view might display the data in a list or a grid.
Delegate - dictates how the data should appear in the view. The delegate takes each data in the model and encapsulates it. The data is accessible through the delegate. The delegate can also write data back into editable models (e.g. in a TextField's onAccepted Handler).
要可视化数据，请将视图的model属性绑定到模型上，将delegate属性绑定到组件或其他兼容类型上。
# 使用视图显示数据
Views are containers for collections of items. They are feature-rich and can be customizable to meet style or behavior requirements.

A set of standard views are provided in the basic set of Qt Quick graphical types:

ListView - arranges items in a horizontal or vertical list
GridView - arranges items in a grid within the available space
PathView - arranges items on a path
These types have properties and behaviors exclusive to each type. Visit their respective documentation for more information.

## Decorating Views
Views allow visual customization through decoration properties such as the header, footer, and section properties. By binding an object, usually another visual object, to these properties, the views are decoratable. A footer may include a Rectangle type showcasing borders or a header that displays a logo on top of the list.

Suppose that a specific club wants to decorate its members list with its brand colors. A member list is in a model and the delegate will display the model's content.
视图允许通过装饰属性(如页眉、页脚和section属性)进行可视化定制。通过将一个对象(通常是另一个可视对象)绑定到这些属性上，视图是可装饰的。页脚可以包括显示边框的矩形类型或在列表顶部显示徽标的页眉。
假设一个特定的俱乐部想用它的品牌颜色来装饰它的成员列表。成员列表在模型中，委托将显示模型的内容。


  ListModel {
      id: nameModel
      ListElement { name: "Alice" }
      ListElement { name: "Bob" }
      ListElement { name: "Jane" }
      ListElement { name: "Harry" }
      ListElement { name: "Wendy" }
  }
  Component {
      id: nameDelegate
      Text {
          text: name;
          font.pixelSize: 24
      }
  }

The club may decorate the members list by binding visual objects to the header and footer properties. The visual object may be defined inline, in another file, or in a Component type.


  ListView {
      anchors.fill: parent
      clip: true
      model: nameModel
      delegate: nameDelegate
      header: bannercomponent
      footer: Rectangle {
          width: parent.width; height: 30;
          gradient: clubcolors
      }
      highlight: Rectangle {
          width: parent.width
          color: "lightgray"
      }
  }

  Component {     //instantiated when header is processed
      id: bannercomponent
      Rectangle {
          id: banner
          width: parent.width; height: 50
          gradient: clubcolors
          border {color: "#9EDDF2"; width: 2}
          Text {
              anchors.centerIn: parent
              text: "Club Members"
              font.pixelSize: 32
          }
      }
  }
  Gradient {
      id: clubcolors
      GradientStop { position: 0.0; color: "#8EE2FE"}
      GradientStop { position: 0.66; color: "#7ED2EE"}
  }



## Mouse and Touch Handling
- 视图处理内容的拖拽和轻弹，但是它们不处理与单个委托的触摸交互。为了让委托对触摸输入做出反应，例如设置currentIndex，委托必须提供一个带有适当触摸处理逻辑的鼠标区域。
- 注意，如果highlightRangeMode被设置为striclyenforcerange，则currentIndex将会受到拖动/滑动视图的影响，因为视图将总是确保currentIndex在指定的高亮范围内。

## ListView Sections
- ListView的内容可以分组为部分，相关的列表项根据其部分被标记。此外，可以用委托来装饰节。
- 列表可能包含一个列表，该列表表明人员的姓名和该人员所属的团队。

  ListModel {
      id: nameModel
      ListElement { name: "Alice"; team: "Crypto" }
      ListElement { name: "Bob"; team: "Crypto" }
      ListElement { name: "Jane"; team: "QA" }
      ListElement { name: "Victor"; team: "QA" }
      ListElement { name: "Wendy"; team: "Graphics" }
  }
  Component {
      id: nameDelegate
      Text {
          text: name;
          font.pixelSize: 24
          anchors.left: parent.left
          anchors.leftMargin: 2
      }
  }

- ListView类型具有section附加属性，可以将相邻类型和相关类型组合成一个section。
  - section.property确定使用哪个列表类型属性作为节
  - section.criteria可以指定如何显示section名
    - ViewSection.FullString(默认) -全名
    - ViewSection.FirstCharacter -首字符
  - section.delegate类似于视图的delegate属性

  ListView {
      anchors.fill: parent
      model: nameModel
      delegate: nameDelegate
      focus: true
      highlight: Rectangle {
          color: "lightblue"
          width: parent.width
      }
      section {
          property: "team"
          criteria: ViewSection.FullString
          delegate: Rectangle {
              color: "#b0dfb0"
              width: parent.width
              height: childrenRect.height + 4
              Text { anchors.horizontalCenter: parent.horizontalCenter
                  font.pixelSize: 16
                  font.bold: true
                  text: section
              }
          }
      }
  }



## View Delegates
- 视图需要一个委托来直观地表示列表中的项。
- 视图将根据委托定义的模板显示每个项目列表。
- 模型中的项可以通过index属性和项的属性访问。

  Component {
      id: petdelegate
      Text {
          id: label
          font.pixelSize: 24
          text: if (index == 0)
              label.text = type + " (default)"
          else
              text: type
      }
  }



## Accessing Views and Models from Delegates
The list view to which the delegate is bound is accessible from the delegate through the ListView.view property. Likewise, the GridView GridView.view is available to delegates. The corresponding model and its properties, therefore, are available through ListView.view.model. In addition, any defined signals or methods in the model are also accessible.

This mechanism is useful when you want to use the same delegate for a number of views, for example, but you want decorations or other features to be different for each view, and you would like these different settings to be properties of each of the views. Similarly, it might be of interest to access or show some properties of the model.

In the following example, the delegate shows the property language of the model, and the color of one of the fields depends on the property fruit_color of the view.

delegate绑定的listview可通过ListView.View属性从委托访问绑定。同样，GridView GridView.view可用于委托。因此，可以通过ListView.view.model获得相应的model及其属性。此外，模型中定义的任何信号或方法都是可以访问的。
例如，当您希望对多个视图使用相同的委托，但又希望每个视图的装饰或其他特性不同，并且希望这些不同的设置成为每个视图的属性时，这种机制就很有用。类似地，访问或显示模型的一些属性也可能很有趣。
在下面的示例中，`delegate`显示了`model`的屬性`language`，`color`的屬性依赖于`view.fruit_color`。

  Rectangle {
       width: 200; height: 200

      ListModel {
          id: fruitModel
          property string language: "en"
          ListElement {
              name: "Apple"
              cost: 2.45
          }
          ListElement {
              name: "Orange"
              cost: 3.25
          }
          ListElement {
              name: "Banana"
              cost: 1.95
          }
      }

      Component {
          id: fruitDelegate
          Row {
                  id: fruit
                  Text { text: " Fruit: " + name; color: fruit.ListView.view.fruit_color }
                  Text { text: " Cost: $" + cost }
                  Text { text: " Language: " + fruit.ListView.view.model.language }
          }
      }

      ListView {
          property color fruit_color: "green"
          model: fruitModel
          delegate: fruitDelegate
          anchors.fill: parent
      }
  }

## Models
数据通过指定的数据角色提供给delegate，delegate可以绑定到这些角色。下面是一个ListModel，它有两个角色，type和age，以及一个ListView，它有一个delegate，绑定到这些角色来显示它们的值:

  import QtQuick 2.0

  Item {
      width: 200; height: 250

      ListModel {
          id: myModel
          ListElement { type: "Dog"; age: 8 }
          ListElement { type: "Cat"; age: 5 }
      }

      Component {
          id: myDelegate
          Text { text: type + ", " + age }
      }

      ListView {
          anchors.fill: parent
          model: myModel
          delegate: myDelegate
      }
  }

- 如果`model's properties`和`delegate's properties`之间有命名冲突，则可以使用限定模型名称来访问角色。例如，如果Text具有type或age属性，上面示例中的文本将显示这些属性值，而不是model项中的type和age值。在这种情况下，可以`model.type`和`model.age`，以确保委托显示来自model项的属性值。
- delegate还可以使用一个特殊的index角色，该角色包含model中项的索引。如果项从model中移除，该索引设置为-1。如果绑定到index角色，请确保逻辑考虑了index为-1的可能性，即该项不再有效。(通常项目将很快被销毁，但它可能在一些视图通过delayRemove附加属性延迟委托销毁。)
- 没有命名角色的模型(例如下面显示的ListModel)将通过modelData角色提供数据。modelData角色还为只有一个角色的模型提供。在这种情况下，modelData角色包含与指定角色相同的数据。
- QML在内置的QML类型集合中提供了几种类型的数据模型。此外，可以用Qt c++创建模型，然后让QQmlEngine可以使用QML组件。有关创建这些模型的信息，请访问 Using C++ Models with Qt Quick Views和creating QML types的文章。
- 使用Repeater可以实现model中items的定位。
# List Model
ListModel是QML中一种简单的类型层次结构。可用的角色由ListElement属性指定。

  ListModel {
      id: fruitModel

      ListElement {
          name: "Apple"
          cost: 2.45
      }
      ListElement {
          name: "Orange"
          cost: 3.25
      }
      ListElement {
          name: "Banana"
          cost: 1.95
      }
  }

上面的模型有两个角色，名称和成本。这些可以通过ListView委托绑定，例如:

  ListView {
      anchors.fill: parent
      model: fruitModel
      delegate: Row {
          Text { text: "Fruit: " + name }
          Text { text: "Cost: $" + cost }
      }
  }

ListModel提供了通过JavaScript直接操作ListModel的方法。在这种情况下，插入的第一项确定了任何使用模型的视图可用的角色。例如，如果一个空的ListModel是通过JavaScript创建并填充的，那么第一个插入所提供的角色将会在视图中显示:

  ListModel { id: fruitModel }
      ...
  MouseArea {
      anchors.fill: parent
      onClicked: fruitModel.append({"cost": 5.95, "name":"Pizza"})
  }
单击鼠标区域时，fruitModel将有两个角色，cost和name。即使添加了后续角色，使用模型的视图也只会处理前两个角色。要重置模型中可用的角色，调用ListModel::clear()。
## XML Model
XmlListModel allows construction of a model from an XML data source. The roles are specified via the XmlRole type. The type needs to be imported.


  import QtQuick.XmlListModel 2.0

The following model has three roles, title, link and description:


  XmlListModel {
       id: feedModel
       source: "http://rss.news.yahoo.com/rss/oceania"
       query: "/rss/channel/item"
       XmlRole { name: "title"; query: "title/string()" }
       XmlRole { name: "link"; query: "link/string()" }
       XmlRole { name: "description"; query: "description/string()" }
  }

The query property specifies that the XmlListModel generates a model item for each <item> in the XML document.

The RSS News demo shows how XmlListModel can be used to display an RSS feed.

# Object Model
- ObjectModel包含在视图中使用的可视项。当在视图中使用ObjectModel时，视图不需要委托，因为ObjectModel已经包含可视委托(项)。
- 下面的例子在一个列表视图中放置了三个彩色矩形。

  import QtQuick 2.0
  import QtQml.Models 2.1

  Rectangle {
      ObjectModel {
          id: itemModel
          Rectangle { height: 30; width: 80; color: "red" }
          Rectangle { height: 30; width: 80; color: "green" }
          Rectangle { height: 30; width: 80; color: "blue" }
      }

      ListView {
          anchors.fill: parent
          model: itemModel
      }
  }

## Integers as Models
整数可以用作包含一定数量类型的模型。在这种情况下，模型没有任何数据角色。
下面的例子创建了一个包含5个元素的ListView:


  Item {
      width: 200; height: 250

      Component {
          id: itemDelegate
          Text { text: "I am item number: " + index }
      }

      ListView {
          anchors.fill: parent
          model: 5
          delegate: itemDelegate
      }

  }

Note: The limit on the number of items in an integer model is 100,000,000.

## Object Instances as Models
对象实例可用于指定具有单一对象类型的模型。对象的属性作为角色提供。
下面的示例创建一个带有一个项目的列表，显示myText文本的颜色。请注意使用完整的model.color以避免与delegate中Text的颜色属性发生冲突。

  Rectangle {
      width: 200; height: 250

      Text {
          id: myText
          text: "Hello"
          color: "#dd44ee"
      }

      Component {
          id: myDelegate
          Text { text: model.color }
      }

      ListView {
          anchors.fill: parent
          anchors.topMargin: 30
          model: myText
          delegate: myDelegate
      }
  }

## C++ Data Models
可以用c++定义模型，然后使其可供QML使用。这种机制对于向QML公开现有的c++数据模型或复杂的数据集非常有用。

# Repeaters


Repeaters create items from a template for use with positioners, using data from a model. Combining repeaters and positioners is an easy way to lay out lots of items. A Repeater item is placed inside a positioner, and generates items that the enclosing positioner arranges.

Each Repeater creates a number of items by combining each element of data from a model, specified using the model property, with the template item, defined as a child item within the Repeater. The total number of items is determined by the amount of data in the model.

The following example shows a repeater used with a Grid item to arrange a set of Rectangle items. The Repeater item creates a series of 24 rectangles for the Grid item to position in a 5 by 5 arrangement.


  import QtQuick 2.0

  Rectangle {
      width: 400; height: 400; color: "black"

      Grid {
          x: 5; y: 5
          rows: 5; columns: 5; spacing: 10

          Repeater { model: 24
                     Rectangle { width: 70; height: 70
                                 color: "lightgreen"

                                 Text { text: index
                                        font.pointSize: 30
                                        anchors.centerIn: parent } }
          }
      }
  }

The number of items created by a Repeater is held by its count property. It is not possible to set this property to determine the number of items to be created. Instead, as in the above example, we use an integer as the model.

For more details, see the QML Data Models document.

If the model is a string list, the delegate is also exposed to a read-only modelData property that holds the string. For example:


  Column {
      Repeater {
          model: ["apples", "oranges", "pears"]
          Text { text: "Data: " + modelData }
      }
  }



It is also possible to use a delegate as the template for the items created by a Repeater. This is specified using the delegate property.

# Changing Model Data
要更改模型数据，您可以将更新后的值分配给模型属性。QML ListModel默认情况下是可编辑的，而c++模型必须实现setData()才能成为可编辑的。Integer和JavaScript数组模型是只读的。
假设实现setData方法的基于QAbstractItemModel的c++模型注册为名为EditableModel的QML类型。数据可以这样写到模型中:

  ListView {
      anchors.fill: parent
      model: EditableModel {}
      delegate: TextEdit {
          width: ListView.view.width
          height: 30
          text: model.edit
          Keys.onReturnPressed: model.edit = text
      }
  }

Note: The edit role is equal to Qt::EditRole. See roleNames() for the built-in role names. However, real life models would usually register custom roles.

For more information, visit the Using C++ Models with Qt Quick Views article.

# Using Transitions
Transitions can be used to animate items that are added to, moved within, or removed from a positioner.

Transitions for adding items apply to items that are created as part of a positioner, as well as those that are reparented to become children of a positioner.

Transitions for removing items apply to items within a positioner that are deleted, as well as those that are removed from a positioner and given new parents in a document.

Note: Changing the opacity of items to zero will not cause them to disappear from the positioner. They can be removed and re-added by changing the visible property.

