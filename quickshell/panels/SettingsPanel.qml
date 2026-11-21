import QtQuick
import Quickshell
import "../singletons"
import "../components"

DropPanel {
    id: root

    panelName: "settings"
    preferredWidth: 840
    preferredHeight: 650

    property int tab: 0
    property bool addingApp: false
    property string appQuery: ""

    readonly property var categories: [
        { name: "Оформление", glyph: "\uf03d8" },
        { name: "Панель", glyph: "\uf062a" },
        { name: "Док", glyph: "\uf02fd" },
        { name: "Виджеты", glyph: "\uf009a" },
        { name: "Погода", glyph: "\uf0590" },
        { name: "Система", glyph: "\uf0493" }
    ]

    readonly property var accentChoices: [
        "#cba6f7", "#89b4fa", "#a6e3a1", "#f9e2af",
        "#fab387", "#f38ba8", "#94e2d5", "#b4befe"
    ]

    readonly property var schemeChoices: [
        { id: "scheme-tonal-spot", label: "Tonal Spot" },
        { id: "scheme-vibrant", label: "Vibrant" },
        { id: "scheme-expressive", label: "Expressive" },
        { id: "scheme-fidelity", label: "Fidelity" },
        { id: "scheme-neutral", label: "Neutral" }
    ]

    readonly property var availableApps: {
        const source = DesktopEntries.applications.values || [];
        const pinned = Settings.data.pinnedApps || [];
        const text = root.appQuery.trim().toLowerCase();
        const result = [];
        for (let i = 0; i < source.length; i++) {
            const app = source[i];
            if (!app || app.noDisplay)
                continue;
            if (app.id === undefined || pinned.indexOf(app.id) !== -1)
                continue;
            if (text.length > 0 && String(app.name || "").toLowerCase().indexOf(text) === -1)
                continue;
            result.push(app);
        }
        result.sort((a, b) => String(a.name || "").localeCompare(String(b.name || "")));
        return result.slice(0, 80);
    }

    function addPinned(id) {
        const list = (Settings.data.pinnedApps || []).slice();
        if (list.indexOf(id) === -1)
            list.push(id);
        Settings.data.pinnedApps = list;
    }

    function removePinned(index) {
        const list = (Settings.data.pinnedApps || []).slice();
        list.splice(index, 1);
        Settings.data.pinnedApps = list;
    }

    function percent(value) {
        return Math.round(Number(value) * 100) + "%";
    }

    function accentRow() {
        return root.accentChoices;
    }

    Row {
        anchors.fill: parent
        spacing: 18

        // Sidebar ---------------------------------------------------------
        Column {
            width: 172
            spacing: 4

            Text {
                text: "Настройки"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: Theme.fontLarge
                font.weight: Font.DemiBold
                bottomPadding: 12
            }

            Repeater {
                model: root.categories

                Rectangle {
                    id: categoryItem
                    required property var modelData
                    required property int index

                    width: parent.width
                    height: 36
                    radius: Theme.radiusSmall
                    color: root.tab === categoryItem.index
                        ? Utils.alpha(Theme.accent, 0.2)
                        : (categoryMouse.containsMouse ? Theme.hover : "transparent")

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 9

                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            glyph: categoryItem.modelData.glyph
                            size: 13
                            color: root.tab === categoryItem.index ? Theme.accent : Theme.subtext
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: categoryItem.modelData.name
                            color: root.tab === categoryItem.index ? Theme.accent : Theme.text
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize
                            font.weight: root.tab === categoryItem.index ? Font.DemiBold : Font.Normal
                        }
                    }

                    MouseArea {
                        id: categoryMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.tab = categoryItem.index
                    }
                }
            }

            Item { width: 1; height: 8 }

            Text {
                width: parent.width
                text: "Super+H — открыть эти настройки"
                color: Theme.subtext
                font.family: Theme.font
                font.pixelSize: Theme.fontTiny
                wrapMode: Text.WordWrap
                opacity: 0.7
            }
        }

        // Pages -----------------------------------------------------------
        Item {
            id: pages
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width - 190
            clip: true

            // Appearance --------------------------------------------------
            Flickable {
                anchors.fill: parent
                visible: root.tab === 0
                clip: true
                contentHeight: appearance.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: appearance
                    width: parent.width - 8
                    spacing: 2

                    SectionHeader { label: "Тема" }

                    SettingRow {
                        title: "Режим"
                        description: "Светлая или тёмная палитра"
                        Chip {
                            label: "Тёмная"
                            active: Settings.data.themeMode !== "light"
                            onClicked: {
                                Settings.data.themeMode = "dark";
                                Utils.run("stylish-shell wallpaper-refresh");
                            }
                        }
                        Chip {
                            label: "Светлая"
                            active: Settings.data.themeMode === "light"
                            onClicked: {
                                Settings.data.themeMode = "light";
                                Utils.run("stylish-shell wallpaper-refresh");
                            }
                        }
                    }

                    SettingRow {
                        title: "Matugen"
                        description: "Строить палитру из текущих обоев"
                        ToggleSwitch {
                            checked: Settings.data.useMatugen
                            onToggled: value => {
                                Settings.data.useMatugen = value;
                                if (value)
                                    Utils.run("stylish-shell wallpaper-refresh");
                            }
                        }
                    }

                    SettingRow {
                        title: "Акцент"
                        description: "Ручной цвет, если Matugen выключен"

                        Repeater {
                            model: root.accentChoices

                            Rectangle {
                                id: swatch
                                required property var modelData
                                width: 22
                                height: 22
                                radius: 11
                                color: swatch.modelData
                                border.width: Settings.data.accent === swatch.modelData && !Settings.data.useMatugen ? 2 : 1
                                border.color: Settings.data.accent === swatch.modelData
                                    ? Theme.text : Utils.alpha(Theme.text, 0.25)

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Settings.data.accent = swatch.modelData;
                                        Settings.data.useMatugen = false;
                                    }
                                }
                            }
                        }
                    }

                    SectionHeader { label: "Схема Matugen" }

                    Row {
                        spacing: 6
                        Repeater {
                            model: root.schemeChoices
                            Chip {
                                required property var modelData
                                label: modelData.label
                                active: Settings.data.matugenScheme === modelData.id
                                onClicked: {
                                    Settings.data.matugenScheme = modelData.id;
                                    Utils.run("stylish-shell wallpaper-refresh");
                                }
                            }
                        }
                    }

                    Text {
                        width: parent.width
                        text: "Схема применяется при смене обоев (Super+W) или кнопкой ниже."
                        color: Theme.subtext
                        font.family: Theme.font
                        font.pixelSize: Theme.fontTiny
                        wrapMode: Text.WordWrap
                        topPadding: 4
                        bottomPadding: 8
                    }

                    SectionHeader { label: "Геометрия" }

                    SettingRow {
                        title: "Скругления"
                        description: "Радиус панелей и карточек"
                        Row {
                            spacing: 8
                            StyledSlider {
                                width: 160
                                from: 6
                                to: 30
                                value: Settings.data.cornerRadius
                                onMoved: v => Settings.data.cornerRadius = Math.round(v)
                            }
                            Text {
                                width: 36
                                text: Math.round(Settings.data.cornerRadius)
                                color: Theme.subtext
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSmall
                            }
                        }
                    }

                    SettingRow {
                        title: "Прозрачность панели"
                        description: "Фон верхней панели"
                        Row {
                            spacing: 8
                            StyledSlider {
                                width: 160
                                from: 0.3
                                to: 1
                                value: Settings.data.barOpacity
                                onMoved: v => Settings.data.barOpacity = v
                            }
                            Text {
                                width: 36
                                text: root.percent(Settings.data.barOpacity)
                                color: Theme.subtext
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSmall
                            }
                        }
                    }

                    SettingRow {
                        title: "Прозрачность панелей"
                        description: "Фон виджетов и меню"
                        Row {
                            spacing: 8
                            StyledSlider {
                                width: 160
                                from: 0.5
                                to: 1
                                value: Settings.data.panelOpacity
                                onMoved: v => Settings.data.panelOpacity = v
                            }
                            Text {
                                width: 36
                                text: root.percent(Settings.data.panelOpacity)
                                color: Theme.subtext
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSmall
                            }
                        }
                    }

                    Item { width: 1; height: 12 }
                }
            }

            // Bar ----------------------------------------------------------
            Flickable {
                anchors.fill: parent
                visible: root.tab === 1
                clip: true
                contentHeight: barPage.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: barPage
                    width: parent.width - 8
                    spacing: 2

                    SectionHeader { label: "Расположение" }

                    SettingRow {
                        title: "Показывать панель"
                        description: "Верхняя панель оболочки"
                        ToggleSwitch {
                            checked: Settings.data.barEnabled
                            onToggled: value => Settings.data.barEnabled = value
                        }
                    }

                    SettingRow {
                        title: "Позиция"
                        description: "Сверху или снизу экрана"
                        Chip {
                            label: "Сверху"
                            active: Settings.data.barPosition === "top"
                            onClicked: Settings.data.barPosition = "top"
                        }
                        Chip {
                            label: "Снизу"
                            active: Settings.data.barPosition === "bottom"
                            onClicked: Settings.data.barPosition = "bottom"
                        }
                    }

                    SettingRow {
                        title: "Высота"
                        description: "Толщина панели"
                        Row {
                            spacing: 8
                            StyledSlider {
                                width: 160
                                from: 30
                                to: 56
                                value: Settings.data.barHeight
                                onMoved: v => Settings.data.barHeight = Math.round(v)
                            }
                            Text {
                                width: 36
                                text: Math.round(Settings.data.barHeight) + " px"
                                color: Theme.subtext
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSmall
                            }
                        }
                    }

                    SectionHeader { label: "Рабочие столы" }

                    SettingRow {
                        title: "Количество тегов"
                        description: "Должно совпадать с tag_num в конфиге Mango"
                        Chip {
                            label: "5"
                            active: Settings.data.tagCount === 5
                            onClicked: Settings.data.tagCount = 5
                        }
                        Chip {
                            label: "7"
                            active: Settings.data.tagCount === 7
                            onClicked: Settings.data.tagCount = 7
                        }
                        Chip {
                            label: "10"
                            active: Settings.data.tagCount === 10
                            onClicked: Settings.data.tagCount = 10
                        }
                    }

                    Item { width: 1; height: 12 }
                }
            }

            // Dock ---------------------------------------------------------
            Flickable {
                anchors.fill: parent
                visible: root.tab === 2
                clip: true
                contentHeight: dockPage.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: dockPage
                    width: parent.width - 8
                    spacing: 2

                    SectionHeader { label: "Поведение" }

                    SettingRow {
                        title: "Показывать док"
                        description: "Панель с закреплёнными приложениями"
                        ToggleSwitch {
                            checked: Settings.data.dockEnabled
                            onToggled: value => Settings.data.dockEnabled = value
                        }
                    }

                    SettingRow {
                        title: "Скрывать автоматически"
                        description: "Док появляется при наведении на нижний край"
                        ToggleSwitch {
                            checked: Settings.data.dockAutoHide
                            onToggled: value => Settings.data.dockAutoHide = value
                        }
                    }

                    SettingRow {
                        title: "Размер иконок"
                        description: "Сторона иконки приложения"
                        Row {
                            spacing: 8
                            StyledSlider {
                                width: 160
                                from: 30
                                to: 64
                                value: Settings.data.dockIconSize
                                onMoved: v => Settings.data.dockIconSize = Math.round(v)
                            }
                            Text {
                                width: 36
                                text: Math.round(Settings.data.dockIconSize) + " px"
                                color: Theme.subtext
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSmall
                            }
                        }
                    }

                    SectionHeader { label: "Закреплённые приложения" }

                    Column {
                        width: parent.width
                        spacing: 2

                        Repeater {
                            model: Settings.data.pinnedApps

                            Item {
                                id: pinnedRow
                                required property var modelData
                                required property int index

                                width: parent.width
                                height: 38

                                AppIcon {
                                    id: pinnedIcon
                                    anchors.left: parent.left
                                    anchors.leftMargin: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    iconName: {
                                        const entry = DesktopEntries.byId(pinnedRow.modelData);
                                        return entry ? entry.icon : pinnedRow.modelData;
                                    }
                                    size: 20
                                }

                                Text {
                                    anchors.left: pinnedIcon.right
                                    anchors.leftMargin: 10
                                    anchors.right: removeButton.left
                                    anchors.rightMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: {
                                        const entry = DesktopEntries.byId(pinnedRow.modelData);
                                        return entry ? entry.name : pinnedRow.modelData;
                                    }
                                    color: Theme.text
                                    font.family: Theme.font
                                    font.pixelSize: Theme.fontSmall
                                    elide: Text.ElideRight
                                }

                                IconButton {
                                    id: removeButton
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    glyph: "\uf0156"
                                    iconSize: 11
                                    padding: 6
                                    tint: Theme.subtext
                                    onClicked: root.removePinned(pinnedRow.index)
                                }
                            }
                        }
                    }

                    Row {
                        spacing: 8
                        topPadding: 6

                        Chip {
                            label: "Добавить приложение"
                            glyph: "\uf0415"
                            active: root.addingApp
                            onClicked: root.addingApp = !root.addingApp
                        }
                    }

                    Column {
                        width: parent.width
                        visible: root.addingApp
                        height: visible ? implicitHeight : 0
                        spacing: 6
                        topPadding: 8

                        Field {
                            width: parent.width
                            placeholder: "Найти приложение…"
                            onTextChanged: root.appQuery = text
                        }

                        ListView {
                            width: parent.width
                            height: 170
                            clip: true
                            model: root.availableApps
                            spacing: 2
                            boundsBehavior: Flickable.StopAtBounds

                            delegate: Item {
                                id: appChoice
                                required property var modelData
                                width: 300
                                height: 36

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 8
                                    color: choiceMouse.containsMouse ? Theme.hover : "transparent"
                                }

                                AppIcon {
                                    id: choiceIcon
                                    anchors.left: parent.left
                                    anchors.leftMargin: 6
                                    anchors.verticalCenter: parent.verticalCenter
                                    iconName: appChoice.modelData.icon
                                    size: 18
                                }

                                Text {
                                    anchors.left: choiceIcon.right
                                    anchors.leftMargin: 9
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: appChoice.modelData.name || appChoice.modelData.id
                                    color: Theme.text
                                    font.family: Theme.font
                                    font.pixelSize: Theme.fontSmall
                                    elide: Text.ElideRight
                                }

                                MouseArea {
                                    id: choiceMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.addPinned(appChoice.modelData.id);
                                        root.addingApp = false;
                                        root.appQuery = "";
                                    }
                                }
                            }
                        }
                    }

                    Item { width: 1; height: 12 }
                }
            }

            // Widgets ------------------------------------------------------
            Flickable {
                anchors.fill: parent
                visible: root.tab === 3
                clip: true
                contentHeight: widgetsPage.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: widgetsPage
                    width: parent.width - 8
                    spacing: 2

                    SectionHeader { label: "Виджеты рабочего стола" }

                    SettingRow {
                        title: "Часы и дата"
                        description: "Крупные часы на рабочем столе"
                        ToggleSwitch {
                            checked: Settings.data.showDesktopClock
                            onToggled: value => Settings.data.showDesktopClock = value
                        }
                    }
                    SettingRow {
                        title: "Погода"
                        description: "Текущая погода на рабочем столе"
                        ToggleSwitch {
                            checked: Settings.data.showDesktopWeather
                            onToggled: value => Settings.data.showDesktopWeather = value
                        }
                    }
                    SettingRow {
                        title: "Медиа-виджет"
                        description: "Обложка и управление плеером на рабочем столе"
                        ToggleSwitch {
                            checked: Settings.data.showDesktopMedia
                            onToggled: value => Settings.data.showDesktopMedia = value
                        }
                    }

                    SettingRow {
                        title: "Позиция виджетов"
                        description: "Угол рабочего стола"
                        Row {
                            spacing: 6
                            Repeater {
                                model: [
                                    { id: "top-left", label: "Слева сверху" },
                                    { id: "top-right", label: "Справа сверху" },
                                    { id: "bottom-left", label: "Слева снизу" },
                                    { id: "bottom-right", label: "Справа снизу" }
                                ]
                                Chip {
                                    required property var modelData
                                    label: modelData.label
                                    active: Settings.data.desktopWidgetPosition === modelData.id
                                    onClicked: Settings.data.desktopWidgetPosition = modelData.id
                                }
                            }
                        }
                    }

                    SectionHeader { label: "Элементы панели" }

                    SettingRow {
                        title: "Рабочие столы"
                        description: "Индикаторы тегов Mango"
                        ToggleSwitch {
                            checked: Settings.data.showTags
                            onToggled: value => Settings.data.showTags = value
                        }
                    }
                    SettingRow {
                        title: "Музыка"
                        description: "Текущий трек в центре панели"
                        ToggleSwitch {
                            checked: Settings.data.showMedia
                            onToggled: value => Settings.data.showMedia = value
                        }
                    }
                    SettingRow {
                        title: "Время"
                        description: "Часы в центре панели"
                        ToggleSwitch {
                            checked: Settings.data.showClock
                            onToggled: value => Settings.data.showClock = value
                        }
                    }
                    SettingRow {
                        title: "Язык"
                        description: "Текущая раскладка клавиатуры"
                        ToggleSwitch {
                            checked: Settings.data.showLanguage
                            onToggled: value => Settings.data.showLanguage = value
                        }
                    }
                    SettingRow {
                        title: "Сеть"
                        description: "Wi-Fi и проводное подключение"
                        ToggleSwitch {
                            checked: Settings.data.showNetwork
                            onToggled: value => Settings.data.showNetwork = value
                        }
                    }
                    SettingRow {
                        title: "Bluetooth"
                        description: "Индикатор адаптера"
                        ToggleSwitch {
                            checked: Settings.data.showBluetooth
                            onToggled: value => Settings.data.showBluetooth = value
                        }
                    }
                    SettingRow {
                        title: "Громкость"
                        description: "Иконка динамика"
                        ToggleSwitch {
                            checked: Settings.data.showVolume
                            onToggled: value => Settings.data.showVolume = value
                        }
                    }
                    SettingRow {
                        title: "Батарея"
                        description: "Заряд ноутбука"
                        ToggleSwitch {
                            checked: Settings.data.showBattery
                            onToggled: value => Settings.data.showBattery = value
                        }
                    }
                    SettingRow {
                        title: "Системный лоток"
                        description: "Иконки фоновых приложений"
                        ToggleSwitch {
                            checked: Settings.data.showTray
                            onToggled: value => Settings.data.showTray = value
                        }
                    }
                    SettingRow {
                        title: "Уведомления"
                        description: "Колокольчик и счётчик"
                        ToggleSwitch {
                            checked: Settings.data.showNotifications
                            onToggled: value => Settings.data.showNotifications = value
                        }
                    }
                    SettingRow {
                        title: "Питание"
                        description: "Кнопка панели управления"
                        ToggleSwitch {
                            checked: Settings.data.showPower
                            onToggled: value => Settings.data.showPower = value
                        }
                    }

                    SectionHeader { label: "Часы" }

                    SettingRow {
                        title: "Формат"
                        description: "12 или 24 часа"
                        Chip {
                            label: "24 ч"
                            active: Settings.data.use24h
                            onClicked: Settings.data.use24h = true
                        }
                        Chip {
                            label: "12 ч"
                            active: !Settings.data.use24h
                            onClicked: Settings.data.use24h = false
                        }
                    }
                    SettingRow {
                        title: "Секунды"
                        description: "Показывать секунды в часах"
                        ToggleSwitch {
                            checked: Settings.data.showSeconds
                            onToggled: value => Settings.data.showSeconds = value
                        }
                    }

                    SectionHeader { label: "Поведение" }

                    SettingRow {
                        title: "Не беспокоить"
                        description: "Не показывать всплывающие уведомления"
                        ToggleSwitch {
                            checked: Settings.data.notificationsDnd
                            onToggled: value => Settings.data.notificationsDnd = value
                        }
                    }
                    SettingRow {
                        title: "Экранные индикаторы"
                        description: "Всплывающий уровень громкости и яркости"
                        ToggleSwitch {
                            checked: Settings.data.osdEnabled
                            onToggled: value => Settings.data.osdEnabled = value
                        }
                    }

                    Item { width: 1; height: 12 }
                }
            }

            // Weather ------------------------------------------------------
            Flickable {
                anchors.fill: parent
                visible: root.tab === 4
                clip: true
                contentHeight: weatherPage.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: weatherPage
                    width: parent.width - 8
                    spacing: 2

                    SectionHeader { label: "Локация" }

                    SettingRow {
                        title: "Город"
                        description: "Название для Open-Meteo"
                        Field {
                            width: 240
                            text: Settings.data.weatherCity
                            placeholder: "Москва"
                            onAccepted: {
                                Settings.data.weatherCity = text;
                                Weather.refresh();
                            }
                        }
                    }

                    Row {
                        spacing: 8
                        Chip {
                            label: "Обновить сейчас"
                            glyph: "\uf0456"
                            onClicked: Weather.refresh()
                        }
                        Chip {
                            label: "Найти город"
                            glyph: "\uf0349"
                            available: !Weather.loading
                            onClicked: Weather.refresh()
                        }
                    }

                    SectionHeader { label: "Параметры" }

                    SettingRow {
                        title: "Интервал обновления"
                        description: "Как часто запрашивать прогноз"
                        Row {
                            spacing: 8
                            StyledSlider {
                                width: 160
                                from: 5
                                to: 60
                                value: Settings.data.weatherRefreshMinutes
                                onMoved: v => Settings.data.weatherRefreshMinutes = Math.round(v)
                            }
                            Text {
                                width: 52
                                text: Math.round(Settings.data.weatherRefreshMinutes) + " мин"
                                color: Theme.subtext
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSmall
                            }
                        }
                    }

                    SettingRow {
                        title: "Метрическая система"
                        description: "Цельсий и км/ч либо Фаренгейт и mph"
                        ToggleSwitch {
                            checked: Settings.data.weatherMetric
                            onToggled: value => Settings.data.weatherMetric = value
                        }
                    }

                    SectionHeader { label: "Состояние" }

                    Text {
                        width: parent.width
                        text: Weather.loading
                            ? "Загрузка…"
                            : (Weather.error.length > 0
                                ? Weather.error
                                : (Weather.hasData
                                    ? (Weather.place + ": " + Weather.temperatureText(Weather.temperature)
                                        + ", " + Utils.weatherText(Weather.weatherCode))
                                    : "Нет данных"))
                        color: Weather.error.length > 0 ? Theme.red : Theme.subtext
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSmall
                        wrapMode: Text.WordWrap
                        topPadding: 4
                    }

                    Item { width: 1; height: 12 }
                }
            }

            // System -------------------------------------------------------
            Flickable {
                anchors.fill: parent
                visible: root.tab === 5
                clip: true
                contentHeight: systemPage.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: systemPage
                    width: parent.width - 8
                    spacing: 2

                    SectionHeader { label: "Обои" }

                    SettingRow {
                        title: "Папка с обоями"
                        description: "Откуда виджет обоев берёт картинки"
                        Field {
                            width: 260
                            text: Settings.data.wallpaperDir
                            placeholder: "~/Pictures/Wallpapers"
                            onAccepted: Settings.data.wallpaperDir = text
                        }
                    }

                    Row {
                        spacing: 8
                        Chip {
                            label: "Выбрать обои"
                            glyph: "\uf02e9"
                            onClicked: Ui.open("wallpaper", root.screen ? root.screen.name : "")
                        }
                        Chip {
                            label: "Случайные обои"
                            glyph: "\uf0456"
                            onClicked: Utils.run("stylish-set-wallpaper --random")
                        }
                    }

                    SectionHeader { label: "Оболочка" }

                    SettingRow {
                        title: "Перезапустить"
                        description: "Перезагрузить QML без выхода из сессии"
                        Chip {
                            label: "Перезапустить"
                            glyph: "\uf0709"
                            onClicked: Utils.run("stylish-shell reload")
                        }
                    }

                    SettingRow {
                        title: "Папка настроек"
                        description: "settings.json и локальные данные"
                        Chip {
                            label: "Открыть"
                            glyph: "\uf024b"
                            onClicked: Utils.run("xdg-open \"$HOME/.config/stylish\"")
                        }
                    }

                    SettingRow {
                        title: "Терминал"
                        description: "Ghostty"
                        Text {
                            text: "Super+Enter"
                            color: Theme.subtext
                            font.family: Theme.mono
                            font.pixelSize: Theme.fontSmall
                        }
                    }

                    SettingRow {
                        title: "Композитор"
                        description: "MangoWM"
                        Text {
                            text: Mango.available ? "подключено" : "нет IPC"
                            color: Mango.available ? Theme.green : Theme.subtext
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSmall
                        }
                    }

                    SectionHeader { label: "Горячие клавиши" }

                    Text {
                        width: parent.width
                        text: "Super+D — лаунчер · Super+N — сеть и Bluetooth · Super+C — буфер обмена\n"
                            + "Super+V — громкость · Super+B — панель управления · Super+M — музыка\n"
                            + "Super+W — обои · Super+S — время и погода · Super+L — блокировка"
                        color: Theme.subtext
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSmall
                        lineHeight: 1.45
                        wrapMode: Text.WordWrap
                        topPadding: 4
                        bottomPadding: 8
                    }

                    Item { width: 1; height: 12 }
                }
            }
        }
    }
}
