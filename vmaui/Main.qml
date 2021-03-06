/***************************************************************************
* Copyright (c) 2015 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
* Copyright (c) 2013 Abdurrahman AVCI <abdurrahmanavci@gmail.com
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
* OR OTHER DEALINGS IN THE SOFTWARE.
*
***************************************************************************/
import QtMultimedia 5.0
import QtQuick 2.2
import SddmComponents 2.0

Rectangle {
    id: container
    width: 1024
    height: 768

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        onLoginSucceeded: {
        }

        onLoginFailed: {
            txtMessage.text = textConstants.loginFailed
            listView.currentItem.password.text = ""
        }
    }

    function random_select(files) {
        if (typeof files == 'string') {
            return files
        } else if (typeof files != 'undefined') {
            return files[Math.floor(Math.random() * files.length)]
        } else {
            return ""
        }
    }

    /*
    Background {
        anchors.fill: parent
        source: random_select(config.background)
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            if (status == Image.Error && source != config.defaultBackground) {
                source = config.defaultBackground
            }
        }
    }
    */

    VideoOutput {
        source: media_player
        fillMode: VideoOutput.PreserveAspectCrop
    }

    MediaPlayer {
        source: random_select(config.video_files)
        id: media_player
        autoLoad: true
        autoPlay: true
        loops: -1
    }

    Audio {
        id: musicPlayer
        autoPlay: true
        autoLoad: true
        source: random_select(config.audio_files)
        loops: -1
    }

    Timer {
        id: timer
        property int counter: 0
        running: true
        repeat: true
        onTriggered: {
            if (counter == 0) {
                animator.duration = config.fadeout_duration * 1000
                dm_parts.opacity = 0
                stop()
            } else if (counter > 0) {
                --counter
            }
        }

        function update() {
            if (counter <= 0) {
                animator.duration = config.fadein_duration * 1000
                dm_parts.opacity = 1
            }
            counter = config.delay_time
            start()
        }
    }

    MouseArea {
        id: mouseArea1
        width: 100
        height: 100
        anchors.fill: parent
        onPositionChanged: timer.update()
        hoverEnabled: true

        Rectangle {
            id: dm_parts
            anchors.fill: parent
            color: "transparent"
            opacity: 1

            Behavior on opacity { OpacityAnimator { id: animator; duration: 2000 } }

            Component {
                id: userDelegate

                PictureBox {
                    anchors.verticalCenter: parent.verticalCenter
                    name: (model.realName === "") ? model.name : model.realName
                    icon: model.icon
                    showPassword: model.needsPassword

                    focus: (listView.currentIndex === index) ? true : false
                    state: (listView.currentIndex === index) ? "active" : ""

                    onLogin: sddm.login(model.name, password, sessionIndex);

                    Keys.onPressed: timer.update()
                    Keys.onReleased: timer.update()

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            listView.currentIndex = index;
                            listView.focus = true;
                        }
                    }
                }
            }

            Row {
                anchors.fill: parent

                Rectangle {
                    width: parent.width / 2; height: parent.height
                    color: "#00000000"

                    Clock {
                        id: clock
                        anchors.centerIn: parent
                        color: config.clock_color
                        timeFont.family: config.clock_font
                    }
                }

                Rectangle {
                    width: parent.width / 2; height: parent.height
                    color: "transparent"
                    clip: true

                    Item {
                        id: usersContainer
                        width: parent.width; height: 300
                        anchors.verticalCenter: parent.verticalCenter

                        ImageButton {
                            id: prevUser
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: 10
                            source: "angle-left.png"
                            onClicked: listView.decrementCurrentIndex()

                            KeyNavigation.backtab: btnShutdown; KeyNavigation.tab: listView
                        }

                        ListView {
                            id: listView
                            height: parent.height
                            anchors.left: prevUser.right; anchors.right: nextUser.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: 10

                            clip: true
                            focus: true

                            spacing: 5

                            model: userModel
                            delegate: userDelegate
                            orientation: ListView.Horizontal
                            currentIndex: userModel.lastIndex

                            KeyNavigation.backtab: prevUser; KeyNavigation.tab: nextUser
                        }

                        ImageButton {
                            id: nextUser
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: 10
                            source: "angle-right.png"
                            onClicked: listView.incrementCurrentIndex()
                            KeyNavigation.backtab: listView; KeyNavigation.tab: session
                        }
                    }

                    Text {
                        id: txtMessage
                        anchors.top: usersContainer.bottom;
                        anchors.margins: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: config.text_color
                        text: textConstants.promptSelectUser

                        font.pixelSize: 20
                    }
                }
            }

            Rectangle {
                id: actionBar
                anchors.top: parent.top;
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width; height: 40
                color: "transparent"

                Row {
                    anchors.left: parent.left
                    anchors.margins: 5
                    height: parent.height
                    spacing: 5

                    Text {
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter

                        text: textConstants.session
                        font.pixelSize: 16
                        color: config.text_color
                        verticalAlignment: Text.AlignVCenter
                    }

                    ComboBox {
                        id: session
                        width: 245
                        anchors.verticalCenter: parent.verticalCenter

                        arrowIcon: "angle-down.png"

                        model: sessionModel
                        index: sessionModel.lastIndex

                        KeyNavigation.backtab: nextUser; KeyNavigation.tab: layoutBox
                    }

                    Text {
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter

                        text: textConstants.layout
                        font.pixelSize: 16
                        color: config.text_color
                        verticalAlignment: Text.AlignVCenter
                    }

                    LayoutBox {
                        id: layoutBox
                        width: 90
                        anchors.verticalCenter: parent.verticalCenter

                        arrowIcon: "angle-down.png"

                        KeyNavigation.backtab: session; KeyNavigation.tab: btnShutdown
                    }
                }

                Row {
                    height: parent.height
                    anchors.right: parent.right
                    anchors.margins: 5
                    spacing: 5

                    ImageButton {
                        id: btnReboot
                        height: parent.height
                        source: "reboot.png"

                        visible: sddm.canReboot

                        onClicked: sddm.reboot()

                        KeyNavigation.backtab: layoutBox; KeyNavigation.tab: btnShutdown
                    }

                    ImageButton {
                        id: btnShutdown
                        height: parent.height
                        source: "shutdown.png"

                        visible: sddm.canPowerOff

                        onClicked: sddm.powerOff()

                        KeyNavigation.backtab: btnReboot; KeyNavigation.tab: prevUser
                    }
                }
            }
        }
    }
}
