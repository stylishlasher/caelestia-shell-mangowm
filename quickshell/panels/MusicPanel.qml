import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../singletons"
import "../components"

DropPanel {
    id: root

    panelName: "music"
    preferredWidth: 680
    preferredHeight: 640

    property var lyrics: []
    property bool lyricsSynced: false
    property bool lyricsLoading: false
    property string lyricsStatus: ""
    property string loadedKey: ""

    readonly property var player: Media.player
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property string songKey: Media.title + "|" + Media.artist + "|" + Media.album

    readonly property int activeLine: {
        Media.tick;
        if (!root.lyricsSynced || root.lyrics.length === 0 || !Media.player)
            return -1;
        const position = Media.position();
        let index = -1;
        for (let i = 0; i < root.lyrics.length; i++) {
            if (root.lyrics[i].time <= position)
                index = i;
            else
                break;
        }
        return index;
    }

    function percent(value) {
        return Math.round(Math.max(0, Math.min(1, Number(value) || 0)) * 100) + "%";
    }

    function parseLrc(text) {
        const result = [];
        const rows = String(text || "").split("\n");
        for (let i = 0; i < rows.length; i++) {
            const line = rows[i].trim();
            if (line.length === 0)
                continue;
            const match = line.match(/^\[(\d+):(\d+(?:[.:]\d+)?)\](.*)$/);
            if (!match)
                continue;
            const minutes = parseInt(match[1]);
            const seconds = parseFloat(String(match[2]).replace(":", "."));
            const body = match[3].trim();
            if (!body)
                continue;
            result.push({ time: minutes * 60 + seconds, text: body });
        }
        result.sort((a, b) => a.time - b.time);
        return result;
    }

    function parsePlain(text) {
        const result = [];
        const rows = String(text || "").split("\n");
        for (let i = 0; i < rows.length; i++) {
            result.push({ time: -1, text: rows[i].trim() });
        }
        return result;
    }

    function requestLyrics() {
        if (!Media.hasPlayer || Media.title.length === 0) {
            root.lyrics = [];
            root.lyricsSynced = false;
            root.lyricsStatus = "";
            root.loadedKey = "";
            return;
        }
        if (root.songKey === root.loadedKey && root.lyrics.length > 0)
            return;

        root.loadedKey = root.songKey;
        root.lyricsLoading = true;
        root.lyricsStatus = "";
        root.lyrics = [];
        root.lyricsSynced = false;

        searchProcess.running = false;
        searchProcess.command = [
            "curl", "-fsS", "--max-time", "10", "--get",
            "--data-urlencode", "track_name=" + Media.title,
            "--data-urlencode", "artist_name=" + Media.artist,
            "--data-urlencode", "album_name=" + Media.album,
            "https://lrclib.net/api/search"
        ];
        searchProcess.running = true;
    }

    Connections {
        target: Media
        function onTitleChanged() { lyricTimer.restart(); }
        function onArtistChanged() { lyricTimer.restart(); }
        function onAlbumChanged() { lyricTimer.restart(); }
    }

    Timer {
        id: lyricTimer
        interval: 700
        onTriggered: root.requestLyrics()
    }

    Process {
        id: searchProcess
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.lyricsLoading = false;
                try {
                    const parsed = JSON.parse(text);
                    if (!parsed || parsed.length === 0) {
                        root.lyricsStatus = "Текст не найден";
                        return;
                    }

                    let chosen = null;
                    for (let i = 0; i < parsed.length; i++) {
                        if (parsed[i] && parsed[i].syncedLyrics) {
                            chosen = parsed[i];
                            break;
                        }
                    }
                    if (!chosen) {
                        for (let i = 0; i < parsed.length; i++) {
                            if (parsed[i] && parsed[i].plainLyrics) {
                                chosen = parsed[i];
                                break;
                            }
                        }
                    }
                    if (!chosen) {
                        root.lyricsStatus = "Текст не найден";
                        return;
                    }

                    if (chosen.syncedLyrics) {
                        root.lyrics = root.parseLrc(chosen.syncedLyrics);
                        root.lyricsSynced = root.lyrics.length > 0;
                    }
                    if (root.lyrics.length === 0 && chosen.plainLyrics) {
                        root.lyrics = root.parsePlain(chosen.plainLyrics);
                        root.lyricsSynced = false;
                    }
                    if (root.lyrics.length === 0)
                        root.lyricsStatus = "Текст не найден";
                } catch (e) {
                    root.lyricsStatus = "Не удалось загрузить текст";
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.lyricsLoading = false;
                root.lyricsStatus = "Текст не найден";
            }
        }
    }

    onSongKeyChanged: lyricTimer.restart()

    onOpenedChanged: {
        if (opened)
            lyricTimer.restart();
    }

    onActiveLineChanged: {
        if (root.activeLine >= 0)
            lyricsList.positionViewAtIndex(root.activeLine, ListView.Center);
    }

    Column {
        anchors.fill: parent
        spacing: 14

        // Header -------------------------------------------------------------
        Row {
            width: parent.width
            spacing: 10

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                glyph: "\uf001"
                size: 16
                color: Theme.accent
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Музыка"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: Theme.fontLarge
                font.weight: Font.DemiBold
            }

            Item { width: 1; height: 1 }

            Chip {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.player !== null
                label: root.player ? (root.player.identity || "Плеер") : ""
                glyph: "\uf04b"
                active: Media.playing
                onClicked: Media.toggle()
            }

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                glyph: "\uf00d"
                iconSize: 13
                tint: Theme.subtext
                onClicked: Ui.close()
            }
        }

        // Now playing -------------------------------------------------------
        Row {
            width: parent.width
            spacing: 18
            height: 180

            Rectangle {
                width: 180
                height: 180
                radius: Theme.radius
                color: Utils.alpha(Theme.text, 0.05)
                clip: true

                Image {
                    id: artImage
                    anchors.fill: parent
                    source: Media.artUrl
                    sourceSize.width: 360
                    sourceSize.height: 360
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready && Media.artUrl.length > 0
                }

                Icon {
                    anchors.centerIn: parent
                    visible: artImage.status !== Image.Ready || Media.artUrl.length === 0
                    glyph: "\uf001"
                    size: 44
                    color: Utils.alpha(Theme.subtext, 0.6)
                }
            }

            Column {
                width: parent.width - 198
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    width: parent.width
                    text: Media.title.length > 0 ? Media.title : "Ничего не играет"
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: Media.artist.length > 0 ? Media.artist : "Запустите плеер"
                    color: Theme.accent
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    visible: Media.album.length > 0
                    text: Media.album
                    color: Theme.subtext
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                    elide: Text.ElideRight
                }

                Item { width: 1; height: 4 }

                StyledSlider {
                    width: parent.width
                    value: Media.length > 0 ? Media.position() / Media.length : 0
                    from: 0
                    to: 1
                    available: Media.hasPlayer && Media.player && Media.player.canSeek
                    onMoved: value => Media.seekTo(value * Media.length)
                }

                Row {
                    width: parent.width

                    Text {
                        text: Media.formatTime(Media.position())
                        color: Theme.subtext
                        font.family: Theme.mono
                        font.pixelSize: Theme.fontTiny
                    }

                    Item { width: 1; height: 1 }

                    Text {
                        text: Media.formatTime(Media.length)
                        color: Theme.subtext
                        font.family: Theme.mono
                        font.pixelSize: Theme.fontTiny
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6

                    IconButton {
                        glyph: "\uf048"
                        iconSize: 17
                        padding: 8
                        available: Media.hasPlayer
                        onClicked: Media.previous()
                    }

                    Rectangle {
                        width: 46
                        height: 46
                        radius: 23
                        color: playMouse.containsMouse
                            ? Utils.alpha(Theme.accent, 0.3) : Utils.alpha(Theme.accent, 0.18)

                        Icon {
                            anchors.centerIn: parent
                            glyph: Media.playing ? "\uf04c" : "\uf04b"
                            size: 18
                            color: Theme.accent
                        }

                        MouseArea {
                            id: playMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: Media.hasPlayer
                            onClicked: Media.toggle()
                        }
                    }

                    IconButton {
                        glyph: "\uf051"
                        iconSize: 17
                        padding: 8
                        available: Media.hasPlayer
                        onClicked: Media.next()
                    }
                }
            }
        }

        // Volume ------------------------------------------------------------
        Row {
            width: parent.width
            spacing: 10

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                glyph: "\uf028"
                size: 13
                color: Theme.subtext
            }

            StyledSlider {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 70
                value: root.sink && root.sink.audio ? root.sink.audio.volume : 0
                onMoved: value => {
                    if (root.sink && root.sink.audio) {
                        root.sink.audio.volume = value;
                        if (value > 0.001)
                            root.sink.audio.muted = false;
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 34
                horizontalAlignment: Text.AlignRight
                text: root.sink && root.sink.audio ? root.percent(root.sink.audio.volume) : "—"
                color: Theme.subtext
                font.family: Theme.font
                font.pixelSize: Theme.fontTiny
            }
        }

        // Lyrics ------------------------------------------------------------
        Rectangle {
            width: parent.width
            height: parent.height - 44 - 180 - 28 - 34 - 14 * 4
            radius: Theme.radiusSmall
            color: Utils.alpha(Theme.text, 0.035)
            clip: true

            Text {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 12
                text: root.lyricsLoading
                    ? "Загрузка текста…"
                    : (root.lyricsStatus.length > 0 ? root.lyricsStatus
                        : (Media.hasPlayer ? "" : "Текст появится вместе с треком"))
                color: Theme.subtext
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
                visible: text.length > 0
            }

            ListView {
                id: lyricsList
                anchors.fill: parent
                anchors.margins: 12
                clip: true
                model: root.lyrics
                spacing: 4
                boundsBehavior: Flickable.StopAtBounds
                visible: root.lyrics.length > 0

                delegate: Text {
                    id: lyricLine
                    required property var modelData
                    required property int index

                    width: lyricsList.width
                    text: lyricLine.modelData.text.length > 0 ? lyricLine.modelData.text : " "
                    color: root.activeLine === lyricLine.index
                        ? Theme.accent
                        : (root.lyricsSynced ? Theme.subtext : Theme.text)
                    opacity: root.lyricsSynced && root.activeLine !== lyricLine.index ? 0.62 : 1
                    font.family: Theme.font
                    font.pixelSize: root.activeLine === lyricLine.index ? 15 : Theme.fontSize
                    font.weight: root.activeLine === lyricLine.index ? Font.DemiBold : Font.Normal
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap

                    Behavior on color {
                        ColorAnimation { duration: Theme.durationFast }
                    }
                }
            }

            Text {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 10
                visible: root.lyrics.length > 0 && root.lyricsSynced
                text: "lrclib.net"
                color: Theme.subtext
                font.family: Theme.font
                font.pixelSize: 9
                opacity: 0.5
            }
        }
    }
}
