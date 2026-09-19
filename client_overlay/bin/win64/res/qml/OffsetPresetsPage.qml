import QtQuick 2.9
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import matzman666.inputemulator 1.0

MyStackViewPage {
    id: offsetPresetsPage
    headerText: "Offset Presets"

    MyDialogOkPopup {
        id: messageDialog
        function showMessage(title, text) {
            dialogTitle = title
            dialogText = text
            open()
        }
    }

    MyDialogOkCancelPopup {
        id: deleteConfirmDialog
        property int presetIndex: -1
        dialogTitle: "Delete Preset"
        dialogText: "Do you really want to delete this preset?"
        onClosed: {
            if (okClicked) {
                DeviceManipulationTabController.deleteOffsetPreset(presetIndex)
            }
        }
    }

    MyDialogOkCancelPopup {
        id: savePresetDialog
        dialogTitle: "Save Preset"
        dialogWidth: 600
        dialogHeight: 300
        dialogContentItem: ColumnLayout {
            RowLayout {
                Layout.topMargin: 16
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                MyText {
                    text: "Name: "
                }
                MyTextField {
                    id: savePresetNameField
                    color: "#cccccc"
                    text: ""
                    Layout.fillWidth: true
                    font.pointSize: 20
                    function onInputEvent(input) {
                        text = input
                    }
                }
            }
        }
        onClosed: {
            if (okClicked) {
                if (savePresetNameField.text === "") {
                    messageDialog.showMessage("Save Preset", "ERROR: Empty preset name.")
                } else {
                    DeviceManipulationTabController.saveOffsetPreset(savePresetNameField.text)
                }
            }
        }
    }

    content: ColumnLayout {
        spacing: 18

        MyText {
            text: "Save the current Driver Offsets (X/Y/Z and enabled state) for all connected\ntrackers as a named preset. Applying a preset re-freezes each tracker's\nHMD-relative offset using the stored values and the current HMD direction."
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            spacing: 18

            MyText {
                text: "Preset:"
            }

            MyComboBox {
                id: presetComboBox
                Layout.fillWidth: true
                model: [""]
                onCurrentIndexChanged: {
                    var hasSelection = currentIndex > 0
                    applyPresetButton.enabled = hasSelection
                    deletePresetButton.enabled = hasSelection
                }
            }

            MyPushButton {
                id: applyPresetButton
                enabled: false
                Layout.preferredWidth: 200
                text: "Apply"
                onClicked: {
                    if (presetComboBox.currentIndex > 0) {
                        DeviceManipulationTabController.applyOffsetPreset(presetComboBox.currentIndex - 1)
                        messageDialog.showMessage("Apply Preset", "Preset applied.")
                    }
                }
            }
        }

        RowLayout {
            spacing: 18
            Item { Layout.fillWidth: true }

            MyPushButton {
                id: deletePresetButton
                enabled: false
                Layout.preferredWidth: 200
                text: "Delete Preset"
                onClicked: {
                    if (presetComboBox.currentIndex > 0) {
                        deleteConfirmDialog.presetIndex = presetComboBox.currentIndex - 1
                        deleteConfirmDialog.open()
                    }
                }
            }

            MyPushButton {
                id: saveCurrentButton
                Layout.preferredWidth: 200
                text: "Save Current"
                onClicked: {
                    savePresetNameField.text = ""
                    savePresetDialog.open()
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Connections {
            target: DeviceManipulationTabController
            onOffsetPresetsChanged: {
                reloadPresets()
            }
        }

        Component.onCompleted: {
            reloadPresets()
        }
    }

    function reloadPresets() {
        var presets = [""]
        var count = DeviceManipulationTabController.getOffsetPresetCount()
        for (var i = 0; i < count; i++) {
            presets.push(DeviceManipulationTabController.getOffsetPresetName(i))
        }
        presetComboBox.model = presets
        presetComboBox.currentIndex = 0
    }
}
