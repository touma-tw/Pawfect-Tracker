import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import matzman666.inputemulator 1.0
import "."

MyStackViewPage {
    id: offsetQuickMenuPage
    headerText: "Offsets Quick Menu - DriverFromHMD Translation Offset"

    property var sortedIndices: []

    // Fixed body order. Hand controllers share the wrist slots (a user has either
    // controllers or wrist trackers), ankles share the knee slots.
    readonly property var roleOrder: ({
        "Camera": 1, "Waist": 2, "Chest": 3,
        "Left Foot": 4, "Right Foot": 5,
        "Left Wrist": 6, "Right Wrist": 7,
        "Left Knee": 8, "Left Ankle": 8,
        "Right Knee": 9, "Right Ankle": 9,
        "Left Elbow": 10, "Right Elbow": 11
    })

    function sortPriority(idx) {
        var cls = DeviceManipulationTabController.getDeviceClass(idx)
        if (cls === 1) return 0
        var role = DeviceManipulationTabController.getDeviceRole(idx)
        if (cls === 2 || role === "Handed") {
            var hand = DeviceManipulationTabController.getDeviceHandedness(idx)
            if (hand === 1) return 6
            if (hand === 2) return 7
            if (cls === 2) return 7.5
        }
        if (roleOrder.hasOwnProperty(role)) return roleOrder[role]
        return 100 // anything else, after all known roles
    }

    function buildSortedList() {
        var count = DeviceManipulationTabController.getDeviceCount()
        var all = []
        for (var i = 0; i < count; i++) {
            all.push({ idx: i, prio: sortPriority(i),
                       serial: DeviceManipulationTabController.getDeviceSerial(i) })
        }
        // Serial breaks ties so the order no longer depends on the per-session device IDs.
        all.sort(function(a, b) {
            if (a.prio !== b.prio) return a.prio - b.prio
            return a.serial < b.serial ? -1 : (a.serial > b.serial ? 1 : 0)
        })
        sortedIndices = all.map(function(e) { return e.idx })
    }

    function refresh() {
        var count = DeviceManipulationTabController.getDeviceCount()
        for (var i = 0; i < count; i++) {
            DeviceManipulationTabController.updateDeviceInfo(i)
        }
        buildSortedList()
    }

    Connections {
        target: DeviceManipulationTabController
        onDeviceCountChanged: offsetQuickMenuPage.refresh()
    }

    Component.onCompleted: refresh()

    // Layout (all literal pixels, no property indirection):
    //   name=140  gap=8  enable=80  gap=8
    //   btn=40  field=120  btn=40  gap=16  (×3 axes)
    //   Cumulative field starts: X=276  Y=492  Z=708
    //   Enable cell start: 148

    content: ScrollView {
        id: deviceListScroll
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Column {
            width: deviceListScroll.width
            spacing: 4

            // ── Header: absolute-x labels placed directly over the value fields ──
            Item {
                width: parent.width
                height: 36

                MyText {
                    x: 148; width: 80; height: 36
                    text: "Enable"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:   Text.AlignVCenter
                    font.pointSize: 16
                }
                MyText {
                    x: 276; width: 120; height: 36
                    text: "左右"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:   Text.AlignVCenter
                    font.pointSize: 18
                }
                MyText {
                    x: 492; width: 120; height: 36
                    text: "上下"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:   Text.AlignVCenter
                    font.pointSize: 18
                }
                MyText {
                    x: 708; width: 120; height: 36
                    text: "前後"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:   Text.AlignVCenter
                    font.pointSize: 18
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#cccccc" }

            // ── Device rows ──
            Repeater {
                model: sortedIndices

                delegate: Row {
                    id: row
                    width: parent.width
                    height: 54
                    spacing: 0

                    property int    deviceIdx: modelData
                    property double valX: 0.0
                    property double valY: 0.0
                    property double valZ: 0.0
                    property string label: ""

                    Component.onCompleted: refreshValues()

                    function refreshValues() {
                        var nx = DeviceManipulationTabController.getDriverTranslationOffset(deviceIdx, 0)
                        var ny = DeviceManipulationTabController.getDriverTranslationOffset(deviceIdx, 1)
                        var nz = DeviceManipulationTabController.getDriverTranslationOffset(deviceIdx, 2)
                        if (valX !== nx) { valX = nx; xField.text = nx.toFixed(1) }
                        if (valY !== ny) { valY = ny; yField.text = ny.toFixed(1) }
                        if (valZ !== nz) { valZ = nz; zField.text = nz.toFixed(1) }
                        var ne = DeviceManipulationTabController.deviceOffsetsEnabled(deviceIdx)
                        if (enableCheck.checked !== ne) enableCheck.checked = ne
                        label = deviceLabel()
                    }

                    function deviceLabel() {
                        var role = DeviceManipulationTabController.getDeviceRole(deviceIdx)
                        if (role !== "") return role
                        var cls = DeviceManipulationTabController.getDeviceClass(deviceIdx)
                        if (cls === 1) return "HMD"
                        if (cls === 2) {
                            var hand = DeviceManipulationTabController.getDeviceHandedness(deviceIdx)
                            if (hand === 1) return "Ctrl Left"
                            if (hand === 2) return "Ctrl Right"
                            return "Ctrl"
                        }
                        if (cls === 4) return "Base Stn"
                        return DeviceManipulationTabController.getDeviceSerial(deviceIdx).substring(0, 10)
                    }

                    Connections {
                        target: DeviceManipulationTabController
                        onDeviceInfoChanged: {
                            if (index === row.deviceIdx) row.refreshValues()
                        }
                    }

                    // x=0  w=140
                    MyText {
                        width: 140; height: 54
                        text: row.label
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    // x=140  w=8
                    Item { width: 8 }
                    // x=148  w=80  → enable cell (header "Enable" at x=148)
                    Item {
                        width: 80; height: 54
                        MyToggleButton {
                            id: enableCheck
                            anchors.centerIn: parent
                            text: ""
                            onClicked: DeviceManipulationTabController.enableDeviceOffsets(row.deviceIdx, checked)
                        }
                    }
                    // x=228  w=8
                    Item { width: 8 }
                    // x=236  w=40  (X minus)
                    MyPushButton2 {
                        width: 50; height: 54; text: "-"
                        onClicked: DeviceManipulationTabController.setDriverTranslationOffset(row.deviceIdx, row.valX - 1.0, row.valY, row.valZ)
                    }
                    // x=276  w=120  → X field (header "左右" at x=276)
                    MyTextField {
                        id: xField
                        width: 120; height: 54
                        horizontalAlignment: Text.AlignHCenter
                        text: "0.0"
                        function onInputEvent(input) {
                            var val = parseFloat(input)
                            if (!isNaN(val)) DeviceManipulationTabController.setDriverTranslationOffset(row.deviceIdx, val, row.valY, row.valZ)
                        }
                    }
                    // x=396  w=40  (X plus)
                    MyPushButton2 {
                        width: 50; height: 54; text: "+"
                        onClicked: DeviceManipulationTabController.setDriverTranslationOffset(row.deviceIdx, row.valX + 1.0, row.valY, row.valZ)
                    }
                    // x=436  w=16  (gap)
                    Item { width: 16 }
                    // x=452  w=40  (Y minus)
                    MyPushButton2 {
                        width: 50; height: 54; text: "-"
                        onClicked: DeviceManipulationTabController.setDriverTranslationOffset(row.deviceIdx, row.valX, row.valY - 1.0, row.valZ)
                    }
                    // x=492  w=120  → Y field (header "上下" at x=492)
                    MyTextField {
                        id: yField
                        width: 120; height: 54
                        horizontalAlignment: Text.AlignHCenter
                        text: "0.0"
                        function onInputEvent(input) {
                            var val = parseFloat(input)
                            if (!isNaN(val)) DeviceManipulationTabController.setDriverTranslationOffset(row.deviceIdx, row.valX, val, row.valZ)
                        }
                    }
                    // x=612  w=40  (Y plus)
                    MyPushButton2 {
                        width: 50; height: 54; text: "+"
                        onClicked: DeviceManipulationTabController.setDriverTranslationOffset(row.deviceIdx, row.valX, row.valY + 1.0, row.valZ)
                    }
                    // x=652  w=16  (gap)
                    Item { width: 16 }
                    // x=668  w=40  (Z minus)
                    MyPushButton2 {
                        width: 50; height: 54; text: "-"
                        onClicked: DeviceManipulationTabController.setDriverTranslationOffset(row.deviceIdx, row.valX, row.valY, row.valZ - 1.0)
                    }
                    // x=708  w=120  → Z field (header "前後" at x=708)
                    MyTextField {
                        id: zField
                        width: 120; height: 54
                        horizontalAlignment: Text.AlignHCenter
                        text: "0.0"
                        function onInputEvent(input) {
                            var val = parseFloat(input)
                            if (!isNaN(val)) DeviceManipulationTabController.setDriverTranslationOffset(row.deviceIdx, row.valX, row.valY, val)
                        }
                    }
                    // x=828  w=40  (Z plus)
                    MyPushButton2 {
                        width: 50; height: 54; text: "+"
                        onClicked: DeviceManipulationTabController.setDriverTranslationOffset(row.deviceIdx, row.valX, row.valY, row.valZ + 1.0)
                    }
                }
            }
        }
    }
}
