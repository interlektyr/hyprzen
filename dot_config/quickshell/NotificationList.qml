pragma Singleton
import QtQuick
import Quickshell

Singleton {
  id: root
  //property ListModel history: ListModel {}
  readonly property alias history: notificationModel

  ListModel {
    id: notificationModel
  }

  function add(n) {
    notificationModel.append({
      "summary": n.summary,
      "body": n.body
    })
  }
}
