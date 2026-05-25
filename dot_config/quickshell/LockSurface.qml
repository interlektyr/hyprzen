import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
//import QtMultimedia

Rectangle {
	id: root
	required property LockContext context
	readonly property ColorGroup colors: Window.active ? palette.active : palette.inactive

  color: colors.window
  //color "black"

  //MediaPlayer {
  //  id: lockPlayer
  //  source: "assets/video/1655543174-1655543174.mp4"
  //  videoOutput: videoOutput_element
  //  loops: MediaPlayer.Infinite
  //  autoPlay: false
  //  //playing: false
  //  audioOutput: { volume: 0.0 }
  //}
 
  //VideoOutput {
  //  id: videoOutput_element
  //  anchors.fill: parent 
  //  fillMode:VideoOutput.PreserveAspectCrop

    Image {
      source: "assets/wallpapers/4.jpg"
      anchors.fill: parent 
      fillMode:Image.PreserveAspectCrop
      //z: -1
      //visible: lockPlayer.playbackState !== MediaPlayer.PlayingState
      visible: true
    }
  //}

	Button {
		text: "Its not working, let me out"
		onClicked: context.unlocked();
	}

	//Label {
	//	id: clock
	//	property var date: new Date()

	//	anchors {
	//		horizontalCenter: parent.horizontalCenter
	//		top: parent.top
	//		topMargin: 100
	//	}

		// The native font renderer tends to look nicer at large sizes.
	//	renderType: Text.NativeRendering
	//	font.pointSize: 80

		// updates the clock every second
	//	Timer {
	//		running: true
	//		repeat: true
	//		interval: 1000

	//		onTriggered: clock.date = new Date();
	//	}

		// updated when the date changes
	//	text: {
		//	const hours = this.date.getHours().toString().padStart(2, '0');
		//	const minutes = this.date.getMinutes().toString().padStart(2, '0');
		//	return `${hours}:${minutes}`;
	//	}
	//}

	ColumnLayout {
		// Uncommenting this will make the password entry invisible except on the active monitor.
		// visible: Window.active

		anchors {
			horizontalCenter: parent.horizontalCenter
      top: parent.verticalCenter
      //topMargin: -100
		}

		RowLayout {
      //TextField {
        //
        //HÄR FÖRESLÅS ATT ETT ITEM-OBJEKT SKAPAS OCH ÖPPNAS MED EN {-KLAMMER, OCH SKA SEDAN HA NÅGRA KODER FÖR DEFINITION AV POSITION
     Item {
      Layout.fillWidth: true 
      Layout.preferredHeight: 50
      Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        
        //
      TextInput {
        id: passwordBox
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
				enabled: !root.context.unlockInProgress
				echoMode: TextInput.Password
        inputMethodHints: Qt.ImhSensitiveData
        passwordCharacter: "*"
        
        //här ligger cursorDelegate från början om du ej använder Row-elementet nedan och heter då cursorDelegate: Rectangle
        //nedan kallas den bara Rectangle

				// Update the text in the context when the text in the box changes.
				onTextChanged: root.context.currentText = this.text;

				// Try to unlock when enter is pressed.
				onAccepted: root.context.tryUnlock();

				// Update the text in the box to match the text in the context.
				// This makes sure multiple monitors have the same text.
				Connections {
					target: root.context

					function onCurrentTextChanged() {
						passwordBox.text = root.context.currentText;
					}
				}
      }

      // element för att skapa animation i input per tecken, ta bort om du ej önskar detta men ändra enligt 
      // kommentarer ovan 
      Row {
        id: visualRow
        anchors.centerIn: parent 
        spacing: 4 

        Repeater {
          model: passwordBox.text.length 

          Text {
            text: passwordBox.passwordCharacter
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
     }//HÄR FÖRESLÅS ATT DET INFOGADE ITEM-OBJEKTET SKA SLUTAS MED EN }-KLAMMER
		}

		//Label {
		//	visible: root.context.showFailure
		//	text: "Incorrect password"
		//}
  }

  Rectangle {
    id: nopeOverlay
    anchors.fill: parent 
    color: "#CC000000"
    z: 100
    visible: root.context.showFailure && nopeTimer.running 

    MouseArea { anchors.fill: parent }

    Text {
      text: "NOPE"
      color: "#F57F82"
      font.family: "Work Sans"
      font.pixelSize: parent.width * 0.25
      //font.bold: true
      font.weight: Font.ExtraBold
      font.letterSpacing: -8
      anchors.centerIn: parent 

      OpacityAnimator on opacity {
        from: 0; to: 1; duration: 150 
        running: nopeOverlay.visible
      }
    }

    Timer {
      id:nopeTimer
      interval: 2000
      repeat: false 
    }

    Connections {
      target: root.context 
      function onShowFailureChanged() {
        if (root.context.showFailure) {
          nopeTimer.restart();
        }
      }     
    }
  }
}
