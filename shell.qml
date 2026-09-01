import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {

    Variants {

        model: Quickshell.screens

        AudioFrameWindow {

            required property var modelData

            targetScreen: modelData
        }
    }
}
