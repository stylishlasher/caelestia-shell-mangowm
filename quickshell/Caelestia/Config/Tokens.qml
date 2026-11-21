pragma Singleton
import QtQuick
import Quickshell
import "../../singletons" as S

Singleton {
    id: root
    property string screen: ""

    property var anim: ({
        durations: ({
            small: 90, normal: 160, large: 240, extraLarge: 360,
            expressiveFastSpatial: 140, expressiveDefaultSpatial: 200, expressiveSlowSpatial: 260,
            expressiveFastEffects: 80, expressiveDefaultEffects: 110, expressiveSlowEffects: 150
        }),
        curves: ({
            emphasized: [0.05,0,2/15,0.06,1/6,0.4,5/24,0.82,0.25,1,1,1],
            emphasizedAccel: [0.3,0,0.8,0.15,1,1],
            emphasizedDecel: [0.05,0.7,0.1,1,1,1],
            standard: [0.2,0,0,1,1,1],
            standardAccel: [0.3,0,1,1,1,1],
            standardDecel: [0,0,0,1,1,1],
            expressiveFastSpatial: [0.42,1.67,0.21,0.9,1,1],
            expressiveDefaultSpatial: [0.38,1.21,0.22,1,1,1],
            expressiveSlowSpatial: [0.39,1.29,0.35,0.98,1,1],
            expressiveFastEffects: [0.31,0.94,0.34,1,1,1],
            expressiveDefaultEffects: [0.34,0.8,0.34,1,1,1],
            expressiveSlowEffects: [0.34,0.88,0.34,1,1,1]
        }),
        expressiveFastSpatial: [0.42,1.67,0.21,0.9,1,1],
        expressiveDefaultSpatial: [0.38,1.21,0.22,1,1,1],
        expressiveSlowSpatial: [0.39,1.29,0.35,0.98,1,1],
        expressiveFastEffects: [0.31,0.94,0.34,1,1,1],
        expressiveDefaultEffects: [0.34,0.8,0.34,1,1,1],
        expressiveSlowEffects: [0.34,0.88,0.34,1,1,1],
        standard: [0.2,0,0,1,1,1], standardAccel: [0.3,0,1,1,1,1], standardDecel: [0,0,0,1,1,1],
        emphasized: [0.05,0,2/15,0.06,1/6,0.4,5/24,0.82,0.25,1,1,1], emphasizedAccel: [0.3,0,0.8,0.15,1,1], emphasizedDecel: [0.05,0.7,0.1,1,1,1]
    })

        function _mkBuilder(base) {
        function sync(b){ b.pointSize=b._f.pointSize; b.family=b._f.family; b.weight=b._f.weight; b.variableAxes=b._f.variableAxes||({}); b.letterSpacing=b._f.letterSpacing||0; return b; }
        const b = {
            _f: Qt.font(base || { family: S.Theme.font || "Rubik", pointSize: 12 }),
            _vaxes: (base && base.variableAxes) ? base.variableAxes : ({}),
            scale: function(m){ const f=Qt.font(this._f); f.pointSize = Math.max(1, Math.round((f.pointSize||12)*m)); this._f=f; return sync(this); },
            size: function(pt){ const f=Qt.font(this._f); f.pointSize=pt; this._f=f; return sync(this); },
            weight: function(w){ const f=Qt.font(this._f); f.weight=w; this._f=f; return sync(this); },
            width: function(w){ const f=Qt.font(this._f); try{ f.stretch=w; }catch(e){} this._f=f; return sync(this); },
            letterSpacing: function(v){ const f=Qt.font(this._f); f.letterSpacing=v; this._f=f; return sync(this); },
            vaxes: function(v){ this._vaxes=v||{}; return sync(this); },
            fill: function(v){ this._fill=v; return sync(this); },
            grade: function(v){ this._grade=v; return sync(this); },
            family: function(v){ const f=Qt.font(this._f); f.family=v; this._f=f; return sync(this); },
            build: function(){ const f=Qt.font(this._f); try{ if(this._vaxes) f.variableAxes=this._vaxes; }catch(e){} return f; }
        };
        sync(b);
        b.toString = function(){ return "[FontBuilder]"; };
        return b;
    }
    function _fontObj(family, pt, w) { return Qt.font({ family: family, pointSize: pt, weight: w || Font.Normal }); }

    property var font: ({
        family: ({ sans: S.Theme.font || "Rubik", mono: S.Theme.mono || "JetBrains Mono NF", material: "Material Symbols Rounded", clock: S.Theme.font || "Rubik", workspaces: S.Theme.mono || "JetBrains Mono NF" }),
        pointSize: ({ extraSmall: 10, small: 11, smaller: 12, normal: 13, medium: 13, larger: 15, large: 18, extraLarge: 28 }),
        size: ({ scale: 1 }),
        body: ({
            small: _fontObj(S.Theme.font || "Rubik", 11),
            medium: _fontObj(S.Theme.font || "Rubik", 13),
            normal: _fontObj(S.Theme.font || "Rubik", 13),
            large: _fontObj(S.Theme.font || "Rubik", 15),
            builders: ({
                small: _mkBuilder({ family: S.Theme.font || "Rubik", pointSize: 11 }),
                medium: _mkBuilder({ family: S.Theme.font || "Rubik", pointSize: 13 }),
                large: _mkBuilder({ family: S.Theme.font || "Rubik", pointSize: 15 }),
                normal: _mkBuilder({ family: S.Theme.font || "Rubik", pointSize: 13 })
            })
        }),
        label: ({
            small: _fontObj(S.Theme.font || "Rubik", 11),
            medium: _fontObj(S.Theme.font || "Rubik", 12),
            large: _fontObj(S.Theme.font || "Rubik", 13),
            builders: ({
                small: _mkBuilder({ family: S.Theme.font || "Rubik", pointSize: 11 }),
                medium: _mkBuilder({ family: S.Theme.font || "Rubik", pointSize: 12 }),
                large: _mkBuilder({ family: S.Theme.font || "Rubik", pointSize: 13 })
            })
        }),
        title: ({
            small: _fontObj(S.Theme.font || "Rubik", 14),
            medium: _fontObj(S.Theme.font || "Rubik", 16, Font.Medium),
            large: _fontObj(S.Theme.font || "Rubik", 20),
            builders: ({
                small: _mkBuilder({ family: S.Theme.font || "Rubik", pointSize: 14 }),
                medium: _mkBuilder({ family: S.Theme.font || "Rubik", pointSize: 16, weight: Font.Medium }),
                large: _mkBuilder({ family: S.Theme.font || "Rubik", pointSize: 20 })
            })
        }),
        icon: ({
            small: _fontObj("Material Symbols Rounded", 16),
            medium: _fontObj("Material Symbols Rounded", 20),
            large: _fontObj("Material Symbols Rounded", 24),
            extraLarge: _fontObj("Material Symbols Rounded", 32),
            size: function(pt){ var b=_mkBuilder({ family: "Material Symbols Rounded", pointSize: pt || 16 }); return b; },
            builders: ({
                small: _mkBuilder({ family: "Material Symbols Rounded", pointSize: 16 }),
                medium: _mkBuilder({ family: "Material Symbols Rounded", pointSize: 20 }),
                large: _mkBuilder({ family: "Material Symbols Rounded", pointSize: 24 }),
                extraLarge: _mkBuilder({ family: "Material Symbols Rounded", pointSize: 32 })
            })
        })
    })

    property var padding: ({ extraSmall: 4, smaller: 7, small: 8, medium: 12, normal: 12, larger: 16, large: 20, extraLarge: 28 })
    property var spacing: ({ extraSmall: 4, small: 8, smaller: 8, medium: 12, normal: 12, larger: 16, large: 20, extraLarge: 28 })
    property var rounding: ({ extraSmall: 8, small: 12, medium: 17, normal: 17, large: 25, full: 1000 })
    property var transparency: ({ enabled: true, base: 0.78, layers: 0.45 })

    property var sizes: ({
        bar: ({ width: 48, innerWidth: 40, popoutWidth: 340, trayMenuWidth: 300, batteryWidth: 250, networkWidth: 320, audioWidth: 320, kbLayoutWidth: 320, workspacesLabelWidth: 0 }),
        dashboard: ({ width: 760, height: 420, tabIndicatorSpacing: 5, userWidth: 220, weatherWidth: 220, dateTimeWidth: 120, mediaWidth: 220, mediaTabWidth: 700, mediaTabHeight: 360, mediaSectionWidth: 320, perfPlaceholderWidth: 400, resourceProgressThickness: 8, mediaProgressThickness: 8, mediaProgressSweep: 220, logoSize: 48, uptimeSize: 42 }),
        launcher: ({ width: 640, itemHeight: 57, itemWidth: 600, wallpaperWidth: 280, wallpaperHeight: 200 }),
        notifs: ({ width: 430, image: 42, badge: 20 }),
        osd: ({ width: 44, height: 44, sliderWidth: 34, sliderHeight: 140, sizes: ({ sliderWidth: 34, sliderHeight: 140 }) }),
        session: ({ width: 520, height: 120, button: 80 }),
        sidebar: ({ width: 430 }),
        utilities: ({ width: 430, toastWidth: 430 }),
        lock: ({ centerWidth: 600, heightMult: 0.7, ratio: 16/9, showWeatherDetailsHeight: 550, showForecastHeight: 975 }),
        nexus: ({ width: 900, heightMult: 0.7, ratio: 16/9, minWidth: 800, minHeight: 500, maxNavWidth: 300, maxContentWidth: 800 }),
        winfo: ({ heightMult: 0.7, detailsWidth: 500 })
    })
    property real scale: 1
    property var shadow: ({ opacity: 0.7, blur: 0.4 })
    property var border: ({ rounding: 20, thickness: 1, smoothing: 0 })
}
