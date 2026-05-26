import QtQuick 2.9
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

GroupBox {
    property string boxTitle: "Offsets"

    property bool showRotation: true
    property string labelX: "X(左右)"
    property string labelY: "Y(上下)"
    property string labelZ: "Z(前後)"

    property double offsetYaw: 0.0
    property double offsetPitch: 0.0
    property double offsetRoll: 0.0

    property double offsetX: 0.0
    property double offsetY: 0.0
    property double offsetZ: 0.0

    property double offsetRotationStep: 5.0
    property double offsetTranslationStep: 1.0

    property var setTranslationOffset: function(x, y, z) {}
    property var setRotationOffset: function(yaw, pitch, roll) {}
    property var updateValues: function() {}

    function updateGUI() {
        yawInputField.text = offsetYaw.toFixed(1) + "°"
        pitchInputField.text = offsetPitch.toFixed(1) + "°"
        rollInputField.text = offsetRoll.toFixed(1) + "°"
        xInputField.text = offsetX.toFixed(1)
        yInputField.text = offsetY.toFixed(1)
        zInputField.text = offsetZ.toFixed(1)
    }

    Layout.fillWidth: true

    label: MyText {
        leftPadding: 10
        text: parent.boxTitle
        bottomPadding: -10
    }

    background: Rectangle {
        color: "transparent"
        border.color: "#ffffff"
        radius: 8
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            color: "#ffffff"
            height: 1
            Layout.fillWidth: true
            Layout.bottomMargin: 5
        }

        // Rotation row — hidden when showRotation is false
        GridLayout {
            visible: showRotation
            columns: 12
            Layout.fillWidth: true

            MyText {
                text: "Yaw:"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                Layout.rightMargin: 12
            }
            MyPushButton2 {
                id: yawMinusButton
                Layout.preferredWidth: 40
                text: "-"
                onClicked: {
                    var value = offsetYaw - offsetRotationStep
                    if (value < -180.0) value += 360.0
                    setRotationOffset(value, offsetPitch, offsetRoll)
                }
            }
            MyTextField {
                id: yawInputField
                text: "0.0°"
                Layout.preferredWidth: 140
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                horizontalAlignment: Text.AlignHCenter
                function onInputEvent(input) {
                    var val = parseFloat(input)
                    if (!isNaN(val)) {
                        if (val < -180.0) val = -180.0
                        else if (val > 180.0) val = 180.0
                        setRotationOffset(val.toFixed(1), offsetPitch, offsetRoll)
                    }
                }
            }
            MyPushButton2 {
                id: yawPlusButton
                Layout.preferredWidth: 40
                text: "+"
                onClicked: {
                    var value = offsetYaw + offsetRotationStep
                    if (value > 180.0) value -= 360.0
                    setRotationOffset(value, offsetPitch, offsetRoll)
                }
            }

            MyText {
                text: "Pitch:"
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: 80
                Layout.leftMargin: 12
                Layout.rightMargin: 12
            }
            MyPushButton2 {
                id: pitchMinusButton
                Layout.preferredWidth: 40
                text: "-"
                onClicked: {
                    var value = offsetPitch - offsetRotationStep
                    if (value < -180.0) value += 360.0
                    setRotationOffset(offsetYaw, value, offsetRoll)
                }
            }
            MyTextField {
                id: pitchInputField
                text: "0.0°"
                Layout.preferredWidth: 140
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                horizontalAlignment: Text.AlignHCenter
                function onInputEvent(input) {
                    var val = parseFloat(input)
                    if (!isNaN(val)) {
                        if (val < -180.0) val = -180.0
                        else if (val > 180.0) val = 180.0
                        setRotationOffset(offsetYaw, val.toFixed(1), offsetRoll)
                    }
                }
            }
            MyPushButton2 {
                id: pitchPlusButton
                Layout.preferredWidth: 40
                text: "+"
                onClicked: {
                    var value = offsetPitch + offsetRotationStep
                    if (value > 180.0) value -= 360.0
                    setRotationOffset(offsetYaw, value, offsetRoll)
                }
            }

            MyText {
                text: "Roll:"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                Layout.leftMargin: 12
                Layout.rightMargin: 12
            }
            MyPushButton2 {
                id: rollMinusButton
                Layout.preferredWidth: 40
                text: "-"
                onClicked: {
                    var value = offsetRoll - offsetRotationStep
                    if (value < -180.0) value += 360.0
                    setRotationOffset(offsetYaw, offsetPitch, value)
                }
            }
            MyTextField {
                id: rollInputField
                text: "0.0°"
                Layout.preferredWidth: 140
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                horizontalAlignment: Text.AlignHCenter
                function onInputEvent(input) {
                    var val = parseFloat(input)
                    if (!isNaN(val)) {
                        if (val < -180.0) val = -180.0
                        else if (val > 180.0) val = 180.0
                        setRotationOffset(offsetYaw, offsetPitch, val.toFixed(1))
                    }
                }
            }
            MyPushButton2 {
                id: rollPlusButton
                Layout.preferredWidth: 40
                text: "+"
                onClicked: {
                    var value = offsetRoll + offsetRotationStep
                    if (value > 180.0) value -= 360.0
                    setRotationOffset(offsetYaw, offsetPitch, value)
                }
            }
        }

        // Translation row — always visible, labels configurable
        GridLayout {
            columns: 12
            Layout.fillWidth: true

            MyText {
                text: labelX + ":"
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: 80
                Layout.rightMargin: 12
            }
            MyPushButton2 {
                id: xMinusButton
                Layout.preferredWidth: 40
                text: "-"
                onClicked: setTranslationOffset(offsetX - offsetTranslationStep, offsetY, offsetZ)
            }
            MyTextField {
                id: xInputField
                text: "0.0"
                Layout.preferredWidth: 140
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                horizontalAlignment: Text.AlignHCenter
                function onInputEvent(input) {
                    var val = parseFloat(input)
                    if (!isNaN(val)) setTranslationOffset(val.toFixed(1), offsetY, offsetZ)
                }
            }
            MyPushButton2 {
                id: xPlusButton
                Layout.preferredWidth: 40
                text: "+"
                onClicked: setTranslationOffset(offsetX + offsetTranslationStep, offsetY, offsetZ)
            }

            MyText {
                text: labelY + ":"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                Layout.leftMargin: 12
                Layout.rightMargin: 12
            }
            MyPushButton2 {
                id: yMinusButton
                Layout.preferredWidth: 40
                text: "-"
                onClicked: setTranslationOffset(offsetX, offsetY - offsetTranslationStep, offsetZ)
            }
            MyTextField {
                id: yInputField
                text: "0.0"
                Layout.preferredWidth: 140
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                horizontalAlignment: Text.AlignHCenter
                function onInputEvent(input) {
                    var val = parseFloat(input)
                    if (!isNaN(val)) setTranslationOffset(offsetX, val.toFixed(1), offsetZ)
                }
            }
            MyPushButton2 {
                id: yPlusButton
                Layout.preferredWidth: 40
                text: "+"
                onClicked: setTranslationOffset(offsetX, offsetY + offsetTranslationStep, offsetZ)
            }

            MyText {
                text: labelZ + ":"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                Layout.leftMargin: 12
                Layout.rightMargin: 12
            }
            MyPushButton2 {
                id: zMinusButton
                Layout.preferredWidth: 40
                text: "-"
                onClicked: setTranslationOffset(offsetX, offsetY, offsetZ - offsetTranslationStep)
            }
            MyTextField {
                id: zInputField
                text: "0.0"
                Layout.preferredWidth: 140
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                horizontalAlignment: Text.AlignHCenter
                function onInputEvent(input) {
                    var val = parseFloat(input)
                    if (!isNaN(val)) setTranslationOffset(offsetX, offsetY, val.toFixed(1))
                }
            }
            MyPushButton2 {
                id: zPlusButton
                Layout.preferredWidth: 40
                text: "+"
                onClicked: setTranslationOffset(offsetX, offsetY, offsetZ + offsetTranslationStep)
            }
        }
    }
}
