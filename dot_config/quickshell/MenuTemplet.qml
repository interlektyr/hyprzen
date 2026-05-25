import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

    property var deskList: desktopEntries.applications

    Window {
        id: launcherWindow
        width: 400
        height: 500
        visible: true 
        color: "#1e1e2e"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15

            // --- Sökfält ---
            TextField {
             id: searchInput
             Layout.fillWidth: true
             focus: true
             placeholderText: "Sök..."
    
             // Använd explicit funktionssyntax för att undvika parser-fel
             onTextChanged: {
               appModel.filter(text);
               listView.currentIndex = 0;
            }
    
            Keys.onPressed: (event) => {
              if (event.key === Qt.Key_Down) {
               if (listView.count > 0) {
                 listView.currentIndex = (listView.currentIndex + 1) % listView.count;
                 console.log("trycker neråt: " + listView.currentIndex);
              }
              event.accepted = true;
              } 
            else if (event.key === Qt.Key_Up) {
              if (listView.count > 0) {
                listView.currentIndex = (listView.currentIndex - 1 + listView.count) % listView.count;
                console.log("trycker uppåt: " + listView.currentIndex);
              }
              event.accepted = true;
            } 
            else if (event.key === Qt.Key_Return) {
            launchSelected();
            event.accepted = true;
            }
    }
}
            // --- Listan ---
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: appModel.filteredData
                clip: true
                currentIndex: 0 
                
                // Gör scrollningen mjuk
                highlightMoveDuration: 200
                highlightFollowsCurrentItem: true 
                
                delegate: Item {
                    id: itemDelegate
                    width: listView.width
                    height: 35

                    readonly property bool isSelected: ListView.isCurrentItem

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        spacing: 12

                        // Fast bredd på pil-containern gör att listan blir rak!
                        Text {
                            width: 20 
                            text: ">"
                            color: "#fab387"
                            font.bold: true
                            //visible: itemDelegate.isSelected
                            opacity: itemDelegate.isSelected
                            //Använd opacity istället för visible för att behålla platsen
                            //opacity: ListView.isCurrentItem ? 1.0 : 0.0
                            //verticalAlignment: Text.AlignVCenter
                            //height: parent.height
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.name
                            color: itemDelegate.isSelected ? "#f5c2e7" : "#cdd6f4"
                            font.pixelSize: 16
                            verticalAlignment: Text.AlignVCenter
                            height: parent.height
                        }
                    }
                }
            }
        }
    }

    // --- Samma logik som tidigare ---
    QtObject {
        id: appModel
        //property var allApps: [
        //    { name: "Firefox", exec: "firefox", terminal: false },
        //    { name: "Vim", exec: "vim", terminal: true },
        //    { name: "HTOP", exec: "htop", terminal: true },
        //    { name: "GIMP", exec: "gimp", terminal: false }
        //]
        property var allApps: deskList 
        property var filteredData: allApps

        function filter(query) {
            if (query === "") {
                filteredData = allApps;
            } else {
                filteredData = allApps.filter(app => 
                    app.name.toLowerCase().includes(query.toLowerCase())
                );
            }
        }
    }

    function launchSelected() {
        if (listView.count === 0) return;
        var app = listView.model[listView.currentIndex];
        var command = app.terminal ? "kitty " + app.exec : app.exec;
        
        console.log("Kör: " + command);
        Quickshell.execute(["sh", "-c", command]);
        Quickshell.quit();
    }
}
