import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

import Buttons 1.0
import Futr 1.0

Rectangle {
    id: root
    border.color: "#e0e0e0"
    radius: 5
    width: 400
    implicitHeight: content.implicitHeight + 20
    property var profileData: ({
        display_name: "",
        name: "",
        about: "",
        picture: "",
        banner: "",
        nip05: "",
        githubProof: "",
        twitterProof: "",
        telegramProof: ""
    })
    property var labelWidth: 100

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            Layout.rightMargin: 2
            Layout.topMargin: 2

            BackButton {
                id: backButton

                onClicked: {
                    editMyProfile.visible = false;
                    myProfile.visible = true;
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: "Edit Profile"
                font: Constants.largeFont
            }

            Item {
                Layout.fillWidth: true
            }

            CloseButton {
                id: closeButton
                target: root
            }
        }

        ColumnLayout {
            spacing: 10
            width: parent.width

            RowLayout {
                spacing: 5
                Label {
                    text: "Display Name:"
                    Layout.preferredWidth: labelWidth
                }
                TextField {
                    id: displayNameField
                    placeholderText: "Display Name"
                    Layout.fillWidth: true
                    text: profileData.display_name
                }
            }

            RowLayout {
                spacing: 5
                Label {
                    text: "Name:"
                    Layout.preferredWidth: labelWidth
                }
                TextField {
                    id: nameField
                    placeholderText: "Name"
                    Layout.fillWidth: true
                    text: profileData.name
                }
            }

            RowLayout {
                spacing: 5
                Label {
                    text: "About Me:"
                    Layout.preferredWidth: labelWidth
                }
                TextArea {
                    id: aboutMeField
                    placeholderText: "About Me"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    wrapMode: TextEdit.Wrap
                    text: profileData.about
                }
            }

            RowLayout {
                spacing: 5
                Label {
                    text: "Avatar URL:"
                    Layout.preferredWidth: labelWidth
                }
                TextField {
                    id: avatarUrlField
                    placeholderText: "Avatar URL"
                    Layout.fillWidth: true
                    text: profileData.picture
                }
            }

            RowLayout {
                spacing: 5
                Label {
                    text: "Banner URL:"
                    Layout.preferredWidth: labelWidth
                }
                TextField {
                    id: bannerUrlField
                    placeholderText: "Banner URL"
                    Layout.fillWidth: true
                    text: profileData.banner
                }
            }

            RowLayout {
                spacing: 5
                Label {
                    text: "NIP05 Address:"
                    Layout.preferredWidth: labelWidth
                }
                TextField {
                    id: nip05Field
                    placeholderText: "NIP05 Address"
                    Layout.fillWidth: true
                    text: profileData.nip05
                }
            }

            RowLayout {
                width: parent.width
                spacing: 5

                MouseArea {
                    id: toggleArea
                    width: parent.width
                    height: parent.height

                    onClicked: proofFields.visible = ! proofFields.visible
                }

                RowLayout {
                    spacing: 5
                    Layout.fillWidth: true

                    Rectangle {
                        height: 1
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "External Identities"
                        color: "darkgray"
                        padding: 10
                    }

                    Text {
                        id: arrowSymbol
                        text: proofFields.visible ? "\u25BC" : "\u25B6"
                        color: "darkgray"
                    }

                    Rectangle {
                        height: 1
                        Layout.fillWidth: true
                    }
                }

                RotationAnimation {
                    target: arrowSymbol
                    from: 0
                    to: 90
                    duration: 200
                    running: proofFields.visible
                }
            }

            ColumnLayout {
                id: proofFields
                visible: false

                RowLayout {
                    spacing: 5
                    Label {
                        text: "GitHub Proof:"
                        Layout.preferredWidth: labelWidth
                    }
                    TextField {
                        id: githubProofField
                        placeholderText: "GitHub Proof"
                        Layout.fillWidth: true
                        text: profileData.githubProof ?? ""
                    }
                }

                RowLayout {
                    spacing: 5
                    Label {
                        text: "Twitter Proof:"
                        Layout.preferredWidth: labelWidth
                    }
                    TextField {
                        id: twitterProofField
                        placeholderText: "Twitter Proof"
                        Layout.fillWidth: true
                        text: profileData.twitterProof ?? ""
                    }
                }

                RowLayout {
                    spacing: 5
                    Label {
                        text: "Telegram Proof:"
                        Layout.preferredWidth: labelWidth
                    }
                    TextField {
                        id: telegramProofField
                        placeholderText: "Telegram Proof"
                        Layout.fillWidth: true
                        text: profileData.telegramProof ?? ""
                    }
                }
            }
        }

        RowLayout {
            width: parent.width
            Layout.alignment: Qt.AlignRight

            Button {
                text: "Save"
                highlighted: true

                onClicked: {
                    // Handle save action here
                    console.log("Save profile clicked")
                }
            }
        }
    }
}
