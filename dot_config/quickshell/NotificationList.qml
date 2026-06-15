pragma Singleton
import QtQuick
import Quickshell

Singleton {
  id: root
  //property ListModel history: ListModel {}
  readonly property alias history: notificationModel
  readonly property alias now: rightNow

  ListModel {
    id: notificationModel
  }

  ListModel {
    id: rightNow
  }

  function writeNote(tmodel) {
    tmodel.append({
      "summary": n.summary,
      "body": n.body,
      "newnote": true
    })
  }

  function addold(n) {
    writeNote(history)
    writeNote(now)
  }

  function add(n) {
    let texts = [];

    for (let i = 0; i < n.actions.length; i++) {
      // tidigare version så var push endast n.actions[i].text
      texts.push("[" + i + "] " + n.actions[i].text + "<br>");
    }

    notificationModel.insert(0, {
    //notificationModel.append({
      "summary": n.summary,
      "body": n.body,
      "urgency": n.urgency,
      //i tidigare version var det texts.join(";")
      "actionTextStr": texts.join(" ")
    })

    rightNow.insert(0, {
    //rightNow.append({
      "summary": n.summary,
      "body": n.body,
      "urgency": n.urgency,
      "actionTextStr": texts.join(" ")
    })
  }
 
}
