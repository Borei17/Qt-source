Enables the user to navigate pages by swiping sideways. More...

Import Statement:	import QtQuick.Controls 2.5
Since:	Qt 5.7
Inherits:	
Container

List of all members, including inherited members
Properties
horizontal : bool
interactive : bool
orientation : enumeration
vertical : bool
Attached Properties
index : int
isCurrentItem : bool
isNextItem : bool
isPreviousItem : bool
view : SwipeView
Detailed Description
SwipeView provides a swipe-based navigation model.



SwipeView is populated with a set of pages. One page is visible at a time. The user can navigate between the pages by swiping sideways. Notice that SwipeView itself is entirely non-visual. It is recommended to combine it with PageIndicator, to give the user a visual clue that there are multiple pages.


  SwipeView {
      id: view

      currentIndex: 1
      anchors.fill: parent

      Item {
          id: firstPage
      }
      Item {
          id: secondPage
      }
      Item {
          id: thirdPage
      }
  }

  PageIndicator {
      id: indicator

      count: view.count
      currentIndex: view.currentIndex

      anchors.bottom: view.bottom
      anchors.horizontalCenter: parent.horizontalCenter
  }

As shown above, SwipeView is typically populated with a static set of pages that are defined inline as children of the view. It is also possible to add, insert, move, and remove pages dynamically at run time.

It is generally not advisable to add excessive amounts of pages to a SwipeView. However, when the amount of pages grows larger, or individual pages are relatively complex, it may be desirable to free up resources by unloading pages that are outside the immediate reach of the user. The following example presents how to use Loader to keep a maximum of three pages simultaneously instantiated.


  SwipeView {
      Repeater {
          model: 6
          Loader {
              active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
              sourceComponent: Text {
                  text: index
                  Component.onCompleted: console.log("created:", index)
                  Component.onDestruction: console.log("destroyed:", index)
              }
          }
      }
  }

Note: SwipeView takes over the geometry management of items added to the view. Using anchors on the items is not supported, and any width or height assignment will be overridden by the view. Notice that this only applies to the root of the item. Specifying width and height, or using anchors for its children works as expected.

See also TabBar, PageIndicator, Customizing SwipeView, Navigation Controls, Container Controls, and Focus Management in Qt Quick Controls 2.

# Property Documentation
1. [read-only]horizontal : bool

This property holds whether the swipe view is horizontal.

This property was introduced in QtQuick.Controls 2.3 (Qt 5.10).

See also orientation.


1. **`interactive : bool`**
   - 此属性描述用户是否可以滑动`SwipeView`。
   - 默认值是true。
1. orientation : enumeration

This property holds the orientation.

Possible values:

Constant	Description
Qt.Horizontal	Horizontal (default)
Qt.Vertical	Vertical
This property was introduced in QtQuick.Controls 2.2 (Qt 5.9).

See also horizontal and vertical.


4. [read-only]vertical : bool

This property holds whether the swipe view is vertical.

This property was introduced in QtQuick.Controls 2.3 (Qt 5.10).

See also orientation.


Attached Property Documentation
[read-only]SwipeView.index : int

This attached property holds the index of each child item in the SwipeView.

It is attached to each child item of the SwipeView.


[read-only]SwipeView.isCurrentItem : bool

This attached property is true if this child is the current item.

It is attached to each child item of the SwipeView.


[read-only]SwipeView.isNextItem : bool

This attached property is true if this child is the next item.

It is attached to each child item of the SwipeView.

This property was introduced in QtQuick.Controls 2.1 (Qt 5.8).


[read-only]SwipeView.isPreviousItem : bool

This attached property is true if this child is the previous item.

It is attached to each child item of the SwipeView.

This property was introduced in QtQuick.Controls 2.1 (Qt 5.8).


[read-only]SwipeView.view : SwipeView

This attached property holds the view that manages this child item.

It is attached to each child item of the SwipeView.


© 2019 The Qt Company Ltd. Documentation contributions included herein are the copyrights of their respective owners.
The documentation provided herein is licensed under the terms of the GNU Free Documentation License version 1.3 as published by the Free Software Foundation.
Qt and respective logos are trademarks of The Qt Company Ltd. in Finland and/or other countries worldwide. All other trademarks are property of their respective owners.