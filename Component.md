
Qt 5.13
Qt QML
QML Types
Component QML Type
Qt 5.13.0 Reference Documentation
Contents
Properties
Attached Signals
Methods
Detailed Description
Creation Context
Component QML Type
Encapsulates a QML component definition. More...

Import Statement:	import QtQml 2.13
Instantiates:	QQmlComponent
List of all members, including inherited members
Properties
progress : real
status : enumeration
url : url
Attached Signals
completed()
destruction()
Methods
object createObject(parent, object properties)
string errorString()
object incubateObject(parent, object properties, enumeration mode)
Detailed Description
Components are reusable, encapsulated QML types with well-defined interfaces.

Components are often defined by component files - that is, .qml files. The Component type essentially allows QML components to be defined inline, within a QML document, rather than as a separate QML file. This may be useful for reusing a small component within a QML file, or for defining a component that logically belongs with other QML components within a file.

For example, here is a component that is used by multiple Loader objects. It contains a single item, a Rectangle:


  import QtQuick 2.0

  Item {
      width: 100; height: 100

      Component {
          id: redSquare

          Rectangle {
              color: "red"
              width: 10
              height: 10
          }
      }

      Loader { sourceComponent: redSquare }
      Loader { sourceComponent: redSquare; x: 20 }
  }

Notice that while a Rectangle by itself would be automatically rendered and displayed, this is not the case for the above rectangle because it is defined inside a Component. The component encapsulates the QML types within, as if they were defined in a separate QML file, and is not loaded until requested (in this case, by the two Loader objects). Because Component is not derived from Item, you cannot anchor anything to it.

Defining a Component is similar to defining a QML document. A QML document has a single top-level item that defines the behavior and properties of that component, and cannot define properties or behavior outside of that top-level item. In the same way, a Component definition contains a single top level item (which in the above example is a Rectangle) and cannot define any data outside of this item, with the exception of an id (which in the above example is redSquare).

The Component type is commonly used to provide graphical components for views. For example, the ListView::delegate property requires a Component to specify how each list item is to be displayed.

Component objects can also be created dynamically using Qt.createComponent().

Creation Context
The creation context of a Component corresponds to the context where the Component was declared. This context is used as the parent context (creating a context hierarchy) when the component is instantiated by an object such as a ListView or a Loader.

In the following example, comp1 is created within the root context of MyItem.qml, and any objects instantiated from this component will have access to the ids and properties within that context, such as internalSettings.color. When comp1 is used as a ListView delegate in another context (as in main.qml below), it will continue to have access to the properties of its creation context (which would otherwise be private to external users).

MyItem.qml	

  Item {
      property Component mycomponent: comp1

      QtObject {
          id: internalSettings
          property color color: "green"
      }

      Component {
          id: comp1
          Rectangle { color: internalSettings.color; width: 400; height: 50 }
      }
  }

main.qml	

  ListView {
      width: 400; height: 400
      model: 5
      delegate: myItem.mycomponent    //will create green Rectangles

      MyItem { id: myItem }
  }

It is important that the lifetime of the creation context outlive any created objects. See Maintaining Dynamically Created Objects for more details.

Property Documentation
progress : real

The progress of loading the component, from 0.0 (nothing loaded) to 1.0 (finished).


status : enumeration

This property holds the status of component loading. The status can be one of the following:

Component.Null - no data is available for the component
Component.Ready - the component has been loaded, and can be used to create instances.
Component.Loading - the component is currently being loaded
Component.Error - an error occurred while loading the component. Calling errorString() will provide a human-readable description of any errors.

url : url

The component URL. This is the URL that was used to construct the component.


# Attached Signal Documentation
1. **`completed()`**
- Emitted after the object has been instantiated.//在对象初始化之后会发送completed信号 
- This can be used to execute script code at startup, once the full QML environment has been established.
- The corresponding handler is onCompleted. It can be declared on any object. The order of running the onCompleted handlers is undefined.


  Rectangle {
      Component.onCompleted: console.log("Completed Running!")
      Rectangle {
          Component.onCompleted: console.log("Nested Completed Running!")
      }
  }


destruction()

Emitted as the object begins destruction. This can be used to undo work done in response to the completed() signal, or other imperative code in your application.

The corresponding handler is onDestruction. It can be declared on any object. The order of running the onDestruction handlers is undefined.


  Rectangle {
      Component.onDestruction: console.log("Destruction Beginning!")
      Rectangle {
          Component.onDestruction: console.log("Nested Destruction Beginning!")
      }
  }

See also Qt QML.


Method Documentation
object createObject(parent, object properties)

Creates and returns an object instance of this component that will have the given parent and properties. The properties argument is optional. Returns null if object creation fails.

The object will be created in the same context as the one in which the component was created. This function will always return null when called on components which were not created in QML.

If you wish to create an object without setting a parent, specify null for the parent value. Note that if the returned object is to be displayed, you must provide a valid parent value or set the returned object's parent property, otherwise the object will not be visible.

If a parent is not provided to createObject(), a reference to the returned object must be held so that it is not destroyed by the garbage collector. This is true regardless of whether Item::parent is set afterwards, because setting the Item parent does not change object ownership. Only the graphical parent is changed.

As of QtQuick 1.1, this method accepts an optional properties argument that specifies a map of initial property values for the created object. These values are applied before the object creation is finalized. This is more efficient than setting property values after object creation, particularly where large sets of property values are defined, and also allows property bindings to be set up (using Qt.binding) before the object is created.

The properties argument is specified as a map of property-value items. For example, the code below creates an object with initial x and y values of 100 and 100, respectively:


  var component = Qt.createComponent("Button.qml");
  if (component.status == Component.Ready)
      component.createObject(parent, {"x": 100, "y": 100});

Dynamically created instances can be deleted with the destroy() method. See Dynamic QML Object Creation from JavaScript for more information.

See also incubateObject().


string errorString()

Returns a human-readable description of any error.

The string includes the file, location, and description of each error. If multiple errors are present, they are separated by a newline character.

If no errors are present, an empty string is returned.


object incubateObject(parent, object properties, enumeration mode)

Creates an incubator for an instance of this component. Incubators allow new component instances to be instantiated asynchronously and do not cause freezes in the UI.

The parent argument specifies the parent the created instance will have. Omitting the parameter or passing null will create an object with no parent. In this case, a reference to the created object must be held so that it is not destroyed by the garbage collector.

The properties argument is specified as a map of property-value items which will be set on the created object during its construction. mode may be Qt.Synchronous or Qt.Asynchronous, and controls whether the instance is created synchronously or asynchronously. The default is asynchronous. In some circumstances, even if Qt.Synchronous is specified, the incubator may create the object asynchronously. This happens if the component calling incubateObject() is itself being created asynchronously.

All three arguments are optional.

If successful, the method returns an incubator, otherwise null. The incubator has the following properties:

status The status of the incubator. Valid values are Component.Ready, Component.Loading and Component.Error.
object The created object instance. Will only be available once the incubator is in the Ready status.
onStatusChanged Specifies a callback function to be invoked when the status changes. The status is passed as a parameter to the callback.
forceCompletion() Call to complete incubation synchronously.
The following example demonstrates how to use an incubator:


  var component = Qt.createComponent("Button.qml");

  var incubator = component.incubateObject(parent, { x: 10, y: 10 });
  if (incubator.status != Component.Ready) {
      incubator.onStatusChanged = function(status) {
          if (status == Component.Ready) {
              print ("Object", incubator.object, "is now ready!");
          }
      }
  } else {
      print ("Object", incubator.object, "is ready immediately!");
  }

Dynamically created instances can be deleted with the destroy() method. See Dynamic QML Object Creation from JavaScript for more information.

See also createObject().