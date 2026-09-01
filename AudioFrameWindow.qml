import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {

    id: root

    required property var targetScreen

    // Create the configuration locally.
    Config {
        id: config
    }

    screen: targetScreen

    color: "transparent"

    exclusiveZone: 0
    aboveWindows: true
    
     // Make the entire AudioFrame click-through.
    mask: Region {}


    // ============================================================
    // POSITION
    // ============================================================

    anchors.top:
        config.position === "top"

    anchors.bottom:
        config.position === "bottom"


    // ============================================================
    // WINDOW SIZE
    // ============================================================

    implicitWidth:
        config.visualizerWidth +
        config.margin * 2

    implicitHeight:
        config.visualizerHeight +
        config.margin * 2


    // ============================================================
    // AUDIO FRAME
    // ============================================================

    AudioFrame {

        id: visualizer

        config: config

        width:
            config.visualizerWidth

        height:
            config.visualizerHeight


        // --------------------------------------------------------
        // Horizontal positioning
        // --------------------------------------------------------

        anchors.horizontalCenter:
            config.alignment === "center"
                ? parent.horizontalCenter
                : undefined

        anchors.left:
            config.alignment === "start"
                ? parent.left
                : undefined

        anchors.right:
            config.alignment === "end"
                ? parent.right
                : undefined


        // --------------------------------------------------------
        // Vertical positioning
        // --------------------------------------------------------

        anchors.top:
            config.position === "top"
                ? parent.top
                : undefined

        anchors.bottom:
            config.position === "bottom"
                ? parent.bottom
                : undefined


        anchors.margins:
            config.margin
    }
}
