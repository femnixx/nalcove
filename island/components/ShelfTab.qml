import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../services" as Services


Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    property bool dragOver: false

    // Reference to shelf service
    readonly property var shelf: Services.Shelf

    // Per-item hover state (in delegate)
    // Current directory display name
    readonly property string currentDirName: shelf.currentDir === shelf.shelfRoot ? "Shelf" : shelf.currentDir.split("/").pop()

    Column {
        anchors.fill: parent
        spacing: 0

        // ---- Header with breadcrumb and places ----
        Card {
            Layout.fillWidth: true
            hoverEnabled: false
            radius: 0
            border.width: 0
            color: "transparent"

            Column {
                anchors.fill: parent
                anchors.margins: Theme.s3
                spacing: Theme.s2

                // Breadcrumb
                Row {
                    spacing: Theme.s1
                    height: Theme.controlH

                    Repeater {
                        model: shelf.breadcrumb
                        delegate: Row {
                            spacing: Theme.s1
                            visible: index < shelf.breadcrumb.length

                            Pill {
                                text: modelData.name
                                accent: index === shelf.breadcrumb.length - 1
                                height: Theme.controlH
                                enabled: index < shelf.breadcrumb.length - 1
                                onClicked: shelf.navigateTo(modelData.path)
                            }

                            Icon {
                                name: "chevron-right"
                                size: Theme.iconSm
                                color: Theme.dim
                                anchors.verticalCenter: parent.verticalCenter
                                visible: index < shelf.breadcrumb.length - 1
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                // Places chips
                Row {
                    spacing: Theme.s1
                    height: Theme.controlH

                    Repeater {
                        model: shelf.places
                        delegate: Pill {
                            text: modelData.name
                            icon: modelData.icon
                            height: Theme.controlH
                            accent: shelf.currentDir.startsWith(modelData.path) && modelData.path !== shelf.shelfRoot
                            onClicked: shelf.navigateTo(modelData.path)
                            // Drag-and-drop onto place chip
                            Drag.active: Drag.active && Drag.mimeData.hasUrls
                            Drag.onEntered: { /* visual feedback */ }
                            Drag.onDropped: {
                                if (Drag.mimeData.hasUrls) {
                                    shelf.addUrls(Drag.mimeData.urls)
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.cardBorder }

        // ---- Content area ----
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Drop zone overlay
            Rectangle {
                anchors.fill: parent
                color: root.dragOver ? Theme.accentSoft : "transparent"
                border.color: root.dragOver ? Theme.accent : "transparent"
                border.width: root.dragOver ? 2 : 0
                radius: Theme.rLg
                visible: root.dragOver || shelf.folderModel.count === 0
                Behavior on color { ColorAnimation { duration: Theme.dFast } }
                Behavior on border.color { ColorAnimation { duration: Theme.dFast } }
                Behavior on border.width { NumberAnimation { duration: Theme.dFast } }

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.s3

                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: root.dragOver ? "folder-up" : "folder-download"
                        size: 48
                        color: root.dragOver ? Theme.accent : Theme.dim
                        Behavior on color { ColorAnimation { duration: Theme.dFast } }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.dragOver ? "Drop files or folders here" : "Drag & drop files here to add"
                        color: root.dragOver ? Theme.accent : Theme.dim
                        font.pixelSize: Theme.tBody
                        font.family: Theme.fontFamily
                        Behavior on color { ColorAnimation { duration: Theme.dFast } }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: !root.dragOver && shelf.folderModel.count > 0
                        text: shelf.folderModel.count + " item(s)"
                        color: Theme.faint
                        font.pixelSize: Theme.tSmall
                        font.family: Theme.fontFamily
                    }
                }

                DropArea {
                    anchors.fill: parent
                    onEntered: root.dragOver = true
                    onExited: root.dragOver = false
                    onDropped: {
                        if (drop.hasUrls) {
                            shelf.addUrls(drop.urls)
                        }
                        root.dragOver = false
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: shelf.openInFileManager()
                }
            }

            // Grid view of files/folders
            GridView {
                id: grid
                anchors.fill: parent
                anchors.margins: Theme.s3
                cellWidth: 112
                cellHeight: 120
                clip: true
                model: shelf.folderModel
                visible: shelf.folderModel.count > 0

                delegate: Card {
                    id: itemCard
                    width: grid.cellWidth - 8
                    height: grid.cellHeight - 8
                    hoverEnabled: true
                    radius: Theme.rMd
                    property bool hovered: itemCard.hovered || ma.containsMouse
                    property bool isDir: model.isDir

                    Column {
                        anchors.fill: parent
                        anchors.margins: Theme.s2
                        spacing: Theme.s2

                        // Thumbnail / icon
                        Rectangle {
                            width: parent.width
                            height: 72
                            radius: Theme.rSm
                            color: Theme.cardHi
                            border.color: Theme.cardBorder
                            border.width: 1
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: model.isDir ? "" : "file://" + model.fileURL
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                cache: false
                                sourceSize: Qt.size(144, 144)
                                visible: !model.isDir && model.fileURL
                            }

                            Icon {
                                anchors.centerIn: parent
                                name: model.isDir ? "folder" : "file"
                                size: 32
                                color: model.isDir ? Theme.accent : Theme.dim
                                visible: model.isDir || !model.fileURL
                            }
                        }

                        // Name
                        Text {
                            width: parent.width
                            text: model.fileName
                            color: Theme.fg
                            font.pixelSize: Theme.tSmall
                            font.family: Theme.fontFamily
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // Hover actions
                        Row {
                            width: parent.width
                            spacing: Theme.s1
                            visible: itemCard.hovered

                            Pill {
                                Layout.fillWidth: true
                                text: "Open"
                                icon: "folder-open"
                                height: 28
                                onClicked: shelf.openPath(model.isDir ? "file://" + model.fileURL : "file://" + model.fileURL)
                            }

                            Pill {
                                Layout.fillWidth: true
                                text: "Copy"
                                icon: "copy"
                                height: 28
                                onClicked: shelf.copyPath(model.fileURL)
                            }

                            Pill {
                                Layout.fillWidth: true
                                text: "Trash"
                                icon: "trash"
                                danger: true
                                height: 28
                                onClicked: shelf.trashPath(model.fileURL)
                            }
                        }
                    }

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (model.isDir) {
                                shelf.navigateTo(model.fileURL.replace("file://", ""))
                            } else {
                                shelf.openPath("file://" + model.fileURL)
                            }
                        }
                        // Drag out support
                        Drag.active: Drag.active
                        Drag.mimeData: { "text/uri-list": "file://" + model.fileURL }
                        Drag.supportedActions: Qt.CopyAction
                        Drag.onDragStarted: { /* visual feedback */ }
                    }
                }
            }

            // Empty state (when no items and not dragging)
            EmptyState {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: shelf.folderModel.count === 0 && !root.dragOver
                icon: "folder"
                text: "Drop files or folders here"
            }
        }

        // ---- Footer actions ----
        Card {
            Layout.fillWidth: true
            hoverEnabled: false
            radius: 0
            border.width: 0
            color: "transparent"

            Row {
                anchors.fill: parent
                anchors.margins: Theme.s3
                spacing: Theme.s2

                Item { Layout.fillWidth: true }

                Pill {
                    text: "Clear All"
                    danger: true
                    height: Theme.controlH
                    visible: shelf.folderModel.count > 0 && shelf.currentDir.startsWith(shelf.shelfRoot)
                    onClicked: confirmClear()
                }

                Pill {
                    text: "Open in Files"
                    icon: "folder"
                    height: Theme.controlH
                    onClicked: shelf.openInFileManager()
                }
            }
        }
    }

    function confirmClear() {
        // Simple confirmation: change button text temporarily
        // In a real app, you'd use a proper dialog
        console.log("Clear all requested for " + shelf.currentDir)
        // For now, just do it - the UI can add a confirmation dialog later
        shelf.clearDir()
    }
}