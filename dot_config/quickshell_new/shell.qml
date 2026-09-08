import Quickshell
import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

//ZenShell 2.0

ShellRoot {
  id: root 

  //Lockscreen
  GlobalShortcut {
    name: "lockTheScreen"
    description: "Toggles Where Is My LockScreen"
    onPressed: { 
      launchLockScreen.startDetached();
    }
  }

  Process {
    id: launchLockScreen
    running: false
    command: ["quickshell", "-p", Quickshell.env("HOME") + "/.config/quickshell/WIMLockScreen.qml"]
  }

  //StatusWidget
  GlobalShortcut {
    name: "status_connections"
    onPressed: {
      if (ZenServices.toggleStatusWidget == false || ZenServices.typeOfStat !== "connections") {
        ZenServices.typeOfStat = "connections";
        ZenServices.toggleStatusWidget = true;
      } else {
        ZenServices.toggleStatusWidget = false;
      }
    }
  }

  GlobalShortcut {
    name: "status_battery"
    onPressed: {
      if (ZenServices.toggleStatusWidget == false || ZenServices.typeOfStat !== "battery") {
        ZenServices.typeOfStat = "battery";
        ZenServices.toggleStatusWidget = true;
      } else {
        ZenServices.toggleStatusWidget = false;
      }
    }
  }

  GlobalShortcut {
    name: "status_volume"
    onPressed: {
      if (ZenServices.toggleStatusWidget == false || ZenServices.typeOfStat !== "volume") {
        ZenServices.typeOfStat = "volume";
        ZenServices.toggleStatusWidget = true;
      } else {
        ZenServices.toggleStatusWidget = false;
      }
    }
  }

  GlobalShortcut {
    name: "status_volume_change"
    onPressed: {
      ZenServices.typeOfStat = "volume_change";
      ZenServices.toggleStatusWidget = true;
    } 
  }

  //AppCommander
  GlobalShortcut {
    name: "appcommander_hud"
    onPressed: {
      ZenServices.toggleAppCommander = true;
    }
  }

  Polkit {}

  ZenStatus {
    visible: ZenServices.toggleStatusWidget
  }
}
