import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Polkit
import "../theme"

PanelWindow {
    id: root
    visible: false
    color: "transparent"
    screen: Quickshell.screens[0]

    WlrLayershell.namespace: "polkit-dialog"

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    PolkitAgent { id: agent }

    // Extract binary name from message, e.g. `/usr/bin/true` → `true`
    readonly property string appName: {
        var msg = agent.flow?.message ?? ""
        var match = msg.match(/`([^`]+)`/)
        if (match) {
            var parts = match[1].split("/")
            return parts[parts.length - 1]
        }
        // fallback: last segment of actionId
        var idParts = (agent.flow?.actionId ?? "").split(".")
        return idParts[idParts.length - 1]
    }

    Connections {
        target: agent
        function onAuthenticationRequestStarted() {
            root.visible = true
            passField.text = ""
            passField.forceActiveFocus()
        }
        function onFlowChanged() {
            if (!agent.flow) {
                root.visible = false
                passField.text = ""
            }
        }
    }

    Connections {
        target: agent.flow
        function onAuthenticationFailed() {
            shakeAnim.start()
            passField.text = ""
            passField.forceActiveFocus()
        }
        function onIsResponseRequiredChanged() {
            if (agent.flow?.isResponseRequired)
                passField.forceActiveFocus()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 380
        height: cardCol.implicitHeight + 48
        radius: 8
        color: "red"
        border.width: 4
        border.color: passField.activeFocus && !shakeAnim.running
            ? "green"
            : "pink"

        Behavior on border.color { ColorAnimation { duration: 150 } }

        SequentialAnimation {
            id: shakeAnim
            NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; from: 0;   to: 10;  duration: 50; easing.type: Easing.OutQuad }
            NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; from: 10;  to: -10; duration: 50; easing.type: Easing.OutQuad }
            NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; from: -10; to: 10;  duration: 50; easing.type: Easing.OutQuad }
            NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; from: 10;  to: 0;   duration: 50; easing.type: Easing.OutQuad }
        }

        Column {
            id: cardCol
            anchors.centerIn: parent
            width: parent.width - 48
            spacing: 0

            // ── Header ──────────────────────────────────────────
            Row {
                width: parent.width
                spacing: 12

                Rectangle {
                    width: 40; height: 40; radius: 8
                    anchors.top: parent.top
                    color: "yellow"
                    Text {
                        anchors.centerIn: parent
                        text: "󰯄"
                        font.pixelSize: 20
                        font.family: "JetBrainsMono Nerd Font"
                        color: "pink"
                    }
                }

                Column {
                    width: parent.width - 52
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    // Primary — what the user needs to know
                    Text {
                        width: parent.width
                        text: "Password required"
                        color: "white"
                        font.pixelSize: 16
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    // Secondary — which app, human readable
                    Text {
                        width: parent.width
                        text: root.appName + " is requesting elevated privileges"
                        color: "white"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                        elide: Text.ElideRight
                    }
                }
            }

            Item { width: parent.width; height: 14 }

            // ── Divider ─────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 2
                radius: 1
                color: "pink"
                opacity: 0.6
            }

            Item { width: parent.width; height: 14 }

            // ── Supplementary message ───────────────────────────
            Text {
                visible: (agent.flow?.supplementaryMessage ?? "") !== ""
                width: parent.width
                text: agent.flow?.supplementaryMessage ?? ""
                color: (agent.flow?.supplementaryIsError ?? false)
                    ? "red" : "white"
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
                wrapMode: Text.WordWrap
                bottomPadding: visible ? 10 : 0
            }

            // ── Password field ──────────────────────────────────
            Rectangle {
                width: parent.width
                height: 38
                radius: 8
                color: "green"
                border.width: passField.activeFocus && !shakeAnim.running ? 2 : 0
                border.color: "red"

                Behavior on border.color { ColorAnimation { duration: 150 } }

                TextInput {
                    id: passField
                    anchors {
                        left: parent.left; leftMargin: 14
                        right: parent.right; rightMargin: 14
                        verticalCenter: parent.verticalCenter
                    }
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: (agent.flow?.responseVisible ?? false)
                        ? TextInput.Normal : TextInput.Password
                    color: "white"
                    font.pixelSize: 13
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    focus: true

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: agent.flow?.inputPrompt ?? "Password"
                        color: "white"
                        font: parent.font
                        visible: parent.text.length === 0
                    }

                    onAccepted: {
                        if (agent.flow?.isResponseRequired) {
                            agent.flow.submit(passField.text)
                            passField.text = ""
                        }
                    }

                    Keys.onEscapePressed: agent.flow?.cancelAuthenticationRequest()
                }

                MouseArea {
                    anchors.fill: parent
                    z: -1
                    onClicked: passField.forceActiveFocus()
                }
            }

            Item { width: parent.width; height: 14 }

            // ── Buttons ─────────────────────────────────────────
            Row {
                width: parent.width
                spacing: 12

                Rectangle {
                    id: cancelBtn
                    width: (parent.width / 2) - 6
                    height: 38
                    radius: 8
                    color: cancelMa.containsMouse
                        ? "white"
                        : "red"
                    border.width: 1
                    border.color: "black"

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: "esc"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            color: "white"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Cancel"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            color: "white"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: cancelMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: agent.flow?.cancelAuthenticationRequest()
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Rectangle {
                    id: authBtn
                    width: (parent.width / 2) - 6
                    height: 38
                    radius: 8
                    color: authMa.containsMouse
                        ? Qt.lighter("red", 1.15)
                        : "green"

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: ""
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            color: "black"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Authenticate"
                            font.family: "JetBrainsMono Nerd Font"
                            font.bold: true
                            font.pixelSize: 13
                            color: "white"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: authMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (agent.flow?.isResponseRequired) {
                                agent.flow.submit(passField.text)
                                passField.text = ""
                            }
                        }
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }
    }
}
