- import QtQuick 2.13
# Detailed Description
The Scale type provides a way to scale an Item through a scale-type transform.

It allows different scaling values for the x and y axes, and allows the scale to be relative to an arbitrary point. This gives more control over item scaling than the scale property.

The following example scales the X axis of the Rectangle, relative to its interior point (25, 25):


  Rectangle {
      width: 100; height: 100
      color: "blue"
      transform: Scale { origin.x: 25; origin.y: 25; xScale: 3}
  }

See also Rotation and Translate.

Property Documentation
origin group

origin.x : real

origin.y : real

This property holds the point that the item is scaled from (that is, the point that stays fixed relative to the parent as the rest of the item grows).

The default value of the origin is (0, 0).


xScale : real

The scaling factor for the X axis.

The default value is 1.0.


yScale : real

The scaling factor for the Y axis.

The default value is 1.0.


© 2019 The Qt Company Ltd. Documentation contributions included herein are the copyrights of their respective owners.
The documentation provided herein is licensed under the terms of the GNU Free Documentation License version 1.3 as published by the Free Software Foundation.
Qt and respective logos are trademarks of The Qt Company Ltd. in Finland and/or other countries worldwide. All other trademarks are property of their respective owners.

focus : bool

This property holds whether the item has focus within the enclosing FocusScope. If true, this item will gain active focus when the enclosing FocusScope gains active focus.

In the following example, input will be given active focus when scope gains active focus:
此属性保存该项目是否侧重于封闭的重点。如果为true，则当附带聚焦ope获得主动焦点时，此项目将获得主动焦点。

在以下示例中，当范围收益激活焦点时，将给出输入的激活焦点：

  import QtQuick 2.0

  Rectangle {
      width: 100; height: 100

      FocusScope {
          id: scope

          TextInput {
              id: input
              focus: true
          }
      }
  }

For the purposes of this property, the scene as a whole is assumed to act like a focus scope. On a practical level, that means the following QML will give active focus to input on startup.
出于此属性的目的，假设整个场景像焦点范围一样。在实际级别，这意味着以下QML将在启动时提供活动焦点。


  Rectangle {
      width: 100; height: 100

      TextInput {
            id: input
            focus: true
      }
  }


  The Shortcut type provides a way of handling keyboard shortcuts. The shortcut can be set to one of the standard keyboard shortcuts, or it can be described with a string containing a sequence of up to four key presses that are needed to activate the shortcut.


  Item {
      id: view

      property int currentIndex

      Shortcut {
          sequence: StandardKey.NextChild
          onActivated: view.currentIndex++
      }
  }

It is also possible to set multiple shortcut sequences, so that the shortcut can be activated via several different sequences of key presses.


This property holds multiple key sequences for the shortcut. The key sequences can be set to one of the standard keyboard shortcuts, or they can be described with strings containing sequences of up to four key presses that are needed to activate the shortcut.



