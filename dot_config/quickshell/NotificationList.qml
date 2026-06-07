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
    writeNote(notificationModel)
    writeNote(rightNow)
  }

  function add(n) {
    //notificationModel.insert(0, {
    notificationModel.append({
      "summary": n.summary,
      "body": n.body,
      "newnote": true
    })
    rightNow.append({
      "summary": n.summary,
      "body": n.body,
      "newnote": true
    })
  }
 
}
