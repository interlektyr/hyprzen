import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Polkit

Scope {
  id: widgetRoot
  
  signal closeTestRequested()

  Connections {
        target: agent
        function onAuthenticationRequestStarted() {
            mainPolkit.visible = true
            passField.text = ""
            passField.forceActiveFocus()
        }
        function onFlowChanged() {
            if (!agent.flow) {
                mainPolkit.visible = false
                passField.text = ""
            }
        }
  }

  Connections {
        target: agent.flow
        function onAuthenticationFailed() {
            //shakeAnim.start()
            passField.text = ""
            passField.forceActiveFocus()
        }
        function onIsResponseRequiredChanged() {
            if (agent.flow?.isResponseRequired)
                passField.forceActiveFocus()
        }
  }

  PanelWindow {
    id: mainPolkit
    implicitWidth: Screen.width 
    implicitHeight: Screen.height
    color: "transparent"
    visible: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "polkit-hud"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: -1

    TapHandler {
      onTapped:
      widgetRoot.closeTestRequested()
    }

    PolkitAgent { id: agent }

    Rectangle {
      id: mainRec 
      width: 800
      height: 250
      color: "black"
      anchors.centerIn: parent
      //anchors.horizontalCenter: parent.horizontalCenter
      //anchors.top: parent.top
      //anchors.topMargin: 10
      focus: true
      radius: 12
      transformOrigin: Item.Top
      opacity: visible ? 1 : 0
      scale: visible ? 1 : 0
      visible: false
      border.color: "pink"
      border.width: 3

      Behavior on opacity { NumberAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

      Keys.onEscapePressed: widgetRoot.closeTestRequested()

      Component.onCompleted: {
        mainRec.visible = true
      }
    
      Text {
        id: titleAC
        text: "authenticate"
        color: "white"
        font.pixelSize: 50
        font.family: "Work Sans"
        font.weight: Font.ExtraBold
        //font.letterSpacing: -5 
        anchors.top: parent.top
        anchors.right: parent.right 
        anchors.topMargin: -3 
        anchors.rightMargin: 12 
        //+ inputRec.border.width

        OpacityAnimator on opacity {
          from: 0; to: 1; duration: 150 
          running: true
        }
      }

      ColumnLayout {
        id: mainRow
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: parent.height * 0.4
        anchors.leftMargin: 20
        anchors.topMargin: titleAC.height + 5
        spacing: 5
        clip: true

        Text {
          id: title
          Layout.alignment: Qt.AlignVCenter
          Layout.fillWidth: true
          Layout.preferredHeight: 10
          text: "Password required"
          color: "pink"
          font.pixelSize: 16
          font.family: "DepartureMono Nerd Font Mono"
          //verticalAlignment: Text.AlignVCenter
          height: 10
        }

        RowLayout {

         Item {
           Layout.fillWidth: true
      //Layout.preferredWidth: mainRec.width - 20
      Layout.preferredHeight: 50
      Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        
        //
      TextInput {
        id: passField
        //anchors.centerIn: undefined 
 
        // För att ändra style på denna typ av object som TextField behöver du skapa ett
        // Rectangle-objekt i den som sedan
        //background: Rectangle {
        //  implicitWidth: 800
        //  implicitHeight: 100
          //border.color: "transparent"
        //  color: "transparent"
        //}
	
        padding: 10
        font.pointSize: 90
        font.family: "DepartureMono Nerd Font"
        //om du ej använder Row-elementet nedan ska du sätta white som color nedan, och ta bort cursorVisible: false
        color: "transparent"
        cursorDelegate: Item { width: 0 }
        cursorVisible: false
        horizontalAlignment: TextInput.AlignHCenter
        verticalAlignment: TextInput.AlignVCenter

				focus: true
				
				echoMode: TextInput.Password
        inputMethodHints: Qt.ImhSensitiveData
        passwordCharacter: "*"
        
        //här ligger cursorDelegate från början om du ej använder Row-elementet nedan och heter då cursorDelegate: Rectangle
        //nedan kallas den bara Rectangle

				// Update the text in the context when the text in the box changes.	

				// Try to unlock when enter is pressed.
				onAccepted: {
                        if (agent.flow?.isResponseRequired) {
                            agent.flow.submit(passField.text)
                            passField.text = ""
                        }
        }

        Keys.onEscapePressed: agent.flow?.cancelAuthenticationRequest()

				// Update the text in the box to match the text in the context.
				// This makes sure multiple monitors have the same text.
				      }

      // element för att skapa animation i input per tecken, ta bort om du ej önskar detta men ändra enligt 
      // kommentarer ovan 
      Row {
        id: visualRow
        //anchors.centerIn: parent
        anchors.centerIn: parent.left
        width: 400
        spacing: 4 

        Repeater {
          model: passField.text.length 

          Text {
            text: passField.passwordCharacter
            color: "white"
            font.pointSize: 96
            font.letterSpacing: 20/96*96
            font.family: "DepartureMono Nerd Font"
            anchors.verticalCenter: parent.verticalCenter
            
            //Component.onCompleted: fadeIn.start()
            //NumberAnimation on opacity {
            //  id: fadeIn 
            //  from: 0
            //  to: 1
            //  duration: 150
            //  easing.type: Easing.OutQuad
            //}
          }
        }
          Rectangle {
           width: 18/96*96
           height: 96
           color: "#F5D098"
           anchors.verticalCenter: parent.verticalCenter
           anchors.verticalCenterOffset: -2

           SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { from: 1; to: 0; duration: 600 }
            NumberAnimation { from: 0; to: 1; duration: 600 }
            }
          }
      }
			//Button {
			//	text: "Unlock"
			//	padding: 10

				// don't steal focus from the text box
			//	focusPolicy: Qt.NoFocus

			//	enabled: !root.context.unlockInProgress && root.context.currentText !== "";
			//	onClicked: root.context.tryUnlock();
      //}
      //
    }
  }
        
      }
    }
  }
}
