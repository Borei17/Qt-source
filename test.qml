import QtQuick 2.12
import QtQuick.Controls 2.5
 
Rectangle {
    height: 800
    width: 600

    ListView {
        width: 160
        height: 240

        model: Qt.fontFamilies()

        delegate: ItemDelegate {
            text: modelData
            width: parent.width
            onClicked: console.log("clicked:", modelData)
        }

        ScrollIndicator.vertical: ScrollIndicator { }
    }
}