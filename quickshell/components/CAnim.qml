import QtQuick
import Caelestia.Config

ColorAnimation {
    duration: Math.max(60, Math.round(Tokens.anim.durations.expressiveDefaultEffects * 0.75))
    easing: Tokens.anim.expressiveDefaultEffects
}
