pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Item {

    id: root


    // ============================================================
    // CONFIG
    // ============================================================

    required property QtObject config

    property color color: config.visualizerColor

    property int barCount: config.barCount

    property real maximumHeight: config.maximumHeight

    property real minimumHeight: config.minimumHeight

    property real sensitivity: config.sensitivity

    property real smoothing: config.smoothing

    property real decay: config.decay

    property real ridgeSharpness: config.ridgeSharpness

    property real bassBoost: config.bassBoost

    property real midBoost: config.midBoost

    property real highBoost: config.highBoost

    property real waveSmooth: config.waveSmooth

    property real beatSensitivity: config.beatSensitivity

    property real beatDecay: config.beatDecay

    property real frequencyCurve: config.frequencyCurve

    property real centerBassWeight: config.centerBassWeight

    property real centerBassEnergy: config.centerBassEnergy

    property real edgeHighWeight: config.edgeHighWeight

    property real bassTransientWeight: config.bassTransientWeight

    property real midTransientWeight: config.midTransientWeight

    property real highTransientWeight: config.highTransientWeight

    property real transientThreshold: config.transientThreshold

    property real transientMultiplier: config.transientMultiplier

    property real beatPulseStrength: config.beatPulseStrength

    property bool active: true


    // ============================================================
    // AUDIO STATE
    // ============================================================

    property var spectrum: []

    property var rendered: []

    property real bassEnergy: 0

    property real midEnergy: 0

    property real highEnergy: 0

    property real previousBass: 0

    property real previousMid: 0

    property real previousHigh: 0

    property real beatPulse: 0


    // ============================================================
    // CAVA
    // ============================================================

    Process {

        id: cava

        command: [
            "cava",
            "-p",
            Quickshell.shellDir + "/cava.conf"
        ]

        running: root.active

        stdout: SplitParser {

            splitMarker: "\n"

            onRead: data => {
                root.processCavaFrame(data)
            }
        }

        stderr: SplitParser {

            splitMarker: "\n"

            onRead: data => {
                console.log("CAVA:", data)
            }
        }

        onExited: {

            if (root.active)
                restartTimer.restart()
        }
    }


    Timer {

        id: restartTimer

        interval: 1000

        onTriggered: {

            if (root.active)
                cava.running = true
        }
    }


    // ============================================================
    // CAVA PARSER
    // ============================================================

    function processCavaFrame(line) {

        if (!line)
            return

        const parts =
            line.trim().split(/\s+/)

        const values = []

        for (const part of parts) {

            const number =
                Number(part)

            if (!Number.isNaN(number))
                values.push(number)
        }

        if (values.length < 2)
            return

        const normalized = []

        for (const value of values) {

            normalized.push(
                Math.max(
                    0,
                    Math.min(
                        1,
                        value / 1000
                    )
                )
            )
        }

        root.spectrum = normalized

        root.updateEnergy(normalized)
    }


    // ============================================================
    // AUDIO ENERGY
    // ============================================================

    function updateEnergy(values) {

        const count =
            values.length

        if (count === 0)
            return


        const bassEnd =
            Math.max(
                1,
                Math.floor(
                    count * 0.18
                )
            )


        const midEnd =
            Math.max(
                bassEnd + 1,
                Math.floor(
                    count * 0.62
                )
            )


        let bass = 0
        let mid = 0
        let high = 0


        for (
            let i = 0;
            i < bassEnd;
            ++i
        )
            bass += values[i]


        for (
            let i = bassEnd;
            i < midEnd;
            ++i
        )
            mid += values[i]


        for (
            let i = midEnd;
            i < count;
            ++i
        )
            high += values[i]


        bass /=
            bassEnd


        mid /=
            Math.max(
                1,
                midEnd - bassEnd
            )


        high /=
            Math.max(
                1,
                count - midEnd
            )


        // ========================================================
        // PERCEPTUAL BOOST
        // ========================================================

        bass =
            Math.min(
                1,
                Math.pow(
                    bass,
                    0.65
                ) *
                root.bassBoost
            )


        mid =
            Math.min(
                1,
                Math.pow(
                    mid,
                    0.78
                ) *
                root.midBoost
            )


        high =
            Math.min(
                1,
                Math.pow(
                    high,
                    0.72
                ) *
                root.highBoost
            )


        root.bassEnergy = bass
        root.midEnergy = mid
        root.highEnergy = high


        // ========================================================
        // TRANSIENT DETECTION
        // ========================================================

        const bassRise =
            Math.max(
                0,
                bass - root.previousBass
            )


        const midRise =
            Math.max(
                0,
                mid - root.previousMid
            )


        const highRise =
            Math.max(
                0,
                high - root.previousHigh
            )


        const transient =
            bassRise *
            root.bassTransientWeight +

            midRise *
            root.midTransientWeight +

            highRise *
            root.highTransientWeight


        if (
            transient >
            root.transientThreshold
        ) {

            root.beatPulse =
                Math.max(
                    root.beatPulse,
                    Math.min(
                        1,
                        transient *
                        root.transientMultiplier *
                        root.beatSensitivity
                    )
                )
        }


        root.previousBass = bass
        root.previousMid = mid
        root.previousHigh = high
    }


    // ============================================================
    // GET SPECTRUM VALUE
    // ============================================================

    function spectrumAt(position) {

        if (spectrum.length === 0)
            return 0


        position =
            Math.max(
                0,
                Math.min(
                    1,
                    position
                )
            )


        const p =
            position *
            (spectrum.length - 1)


        const a =
            Math.floor(p)


        const b =
            Math.min(
                spectrum.length - 1,
                a + 1
            )


        const t =
            p - a


        return (
            spectrum[a] *
            (1 - t) +

            spectrum[b] *
            t
        )
    }


    // ============================================================
    // MIRRORED VISUALIZER
    //
    // CENTER = BASS
    // OUTWARD = MID
    // EDGE = TREBLE
    // ============================================================

    function targetFor(index) {

        if (spectrum.length === 0)
            return 0


        const normalized =
            index /
            Math.max(
                1,
                barCount - 1
            )


        const distance =
            Math.abs(
                normalized - 0.5
            ) * 2


        const frequencyPosition =
            Math.pow(
                distance,
                root.frequencyCurve
            )


        let value =
            spectrumAt(
                frequencyPosition
            )


        // ========================================================
        // CENTER BASS
        // ========================================================

        const centerWeight =
            Math.pow(
                1 - distance,
                2.2
            )


        value *=
            1 +
            centerWeight *
            root.centerBassWeight


        value +=
            root.bassEnergy *
            centerWeight *
            root.centerBassEnergy


        // ========================================================
        // OUTER HIGH FREQUENCY
        // ========================================================

        const edgeWeight =
            Math.pow(
                distance,
                2
            )


        value *=
            1 +
            edgeWeight *
            (
                root.edgeHighWeight *
                (
                    root.highBoost - 1
                )
            )


        // ========================================================
        // RIDGE CONTRAST
        // ========================================================

        value =
            Math.pow(
                Math.max(
                    0,
                    value
                ),
                root.ridgeSharpness
            )


        // ========================================================
        // OVERALL RESPONSE
        // ========================================================

        const energy =
            root.bassEnergy * 0.50 +
            root.midEnergy * 0.30 +
            root.highEnergy * 0.20


        value *=
            root.sensitivity *
            (
                0.70 +
                energy * 0.45
            )


        // ========================================================
        // BEAT TRANSIENT
        // ========================================================

        value +=
            value *
            root.beatPulse *
            root.beatPulseStrength


        return Math.max(
            0,
            Math.min(
                1,
                value
            )
        )
    }


    // ============================================================
    // ANIMATION
    // ============================================================

    FrameAnimation {

        running: root.active

        onTriggered: {

            const old =
                root.rendered.length ===
                root.barCount

                    ? root.rendered

                    : Array.from(
                        {
                            length:
                                root.barCount
                        },
                        () => 0
                    )


            const next = []


            for (
                let i = 0;
                i < root.barCount;
                ++i
            ) {

                let target =
                    root.targetFor(i)


                // =================================================
                // CENTER PEAK
                // =================================================

                const normalized =
                    i /
                    Math.max(
                        1,
                        root.barCount - 1
                    )


                const distance =
                    Math.abs(
                        normalized - 0.5
                    ) * 2


                const centerInfluence =
                    Math.pow(
                        1 - distance,
                        4
                    )


                target +=
                    root.bassEnergy *
                    centerInfluence *
                    0.30


                // =================================================
                // WAVE SMOOTHING
                // =================================================

                if (
                    root.waveSmooth > 0
                ) {

                    const left =
                        root.targetFor(
                            Math.max(
                                0,
                                i - 1
                            )
                        )


                    const right =
                        root.targetFor(
                            Math.min(
                                root.barCount - 1,
                                i + 1
                            )
                        )


                    target =
                        target *
                        (
                            1 -
                            root.waveSmooth
                        ) +

                        (
                            (
                                left +
                                right
                            ) / 2
                        ) *
                        root.waveSmooth
                }


                target =
                    Math.max(
                        0,
                        Math.min(
                            1,
                            target
                        )
                    )


                // =================================================
                // ATTACK / DECAY
                // =================================================

                const rising =
                    target > old[i]


                const speed =
                    rising
                        ? root.smoothing
                        : root.decay


                const amount =
                    1 -
                    Math.exp(
                        -frameTime /
                        Math.max(
                            0.001,
                            speed
                        )
                    )


                let value =
                    old[i] +
                    (
                        target -
                        old[i]
                    ) *
                    amount


                if (
                    Math.abs(
                        value -
                        target
                    ) < 0.001
                )
                    value = target


                next.push(value)
            }


            // =====================================================
            // SINGLE CENTER PEAK
            // =====================================================

            if (
                root.barCount % 2 === 0 &&
                next.length >= 2
            ) {

                const leftCenter =
                    root.barCount / 2 - 1


                const rightCenter =
                    root.barCount / 2


                const center =
                    Math.max(
                        next[leftCenter],
                        next[rightCenter]
                    )


                next[leftCenter] =
                    center


                next[rightCenter] =
                    center
            }


            root.rendered =
                next


            // =====================================================
            // BEAT DECAY
            // =====================================================

            root.beatPulse *=
                Math.exp(
                    -frameTime /
                    Math.max(
                        0.001,
                        root.beatDecay
                    )
                )


            canvas.requestPaint()
        }
    }


    // ============================================================
    // DRAW WAVE
    // ============================================================

    Canvas {

        id: canvas

        anchors.fill: parent

        antialiasing: true

        renderStrategy:
            Canvas.Cooperative


        onPaint: {

            const ctx =
                getContext("2d")


            ctx.clearRect(
                0,
                0,
                width,
                height
            )


            if (
                !root.active ||
                root.rendered.length === 0
            )
                return


            const count =
                root.rendered.length


            const spacing =
                width /
                Math.max(
                    1,
                    count - 1
                )


            const points = []


            // =====================================================
            // TOP / BOTTOM DIRECTION
            // =====================================================

            const growsDown =
                root.config.position === "top"


            const baseline =
                growsDown
                    ? 0
                    : height


            // =====================================================
            // CREATE WAVE POINTS
            // =====================================================

            for (
                let i = 0;
                i < count;
                ++i
            ) {

                const value =
                    root.rendered[i]


                const x =
                    i * spacing


                const depth =
                    root.minimumHeight +
                    value *
                    root.maximumHeight


                const y =
                    growsDown
                        ? depth
                        : height - depth


                points.push({
                    x: x,
                    y: y
                })
            }


            ctx.fillStyle =
                root.color


            ctx.beginPath()


            // =====================================================
            // START
            // =====================================================

            ctx.moveTo(
                0,
                baseline
            )


            ctx.lineTo(
                points[0].x,
                points[0].y
            )


            // =====================================================
            // SMOOTH WAVE
            // =====================================================

            for (
                let i = 0;
                i < points.length - 1;
                ++i
            ) {

                const p0 =
                    points[
                        Math.max(
                            0,
                            i - 1
                        )
                    ]


                const p1 =
                    points[i]


                const p2 =
                    points[i + 1]


                const p3 =
                    points[
                        Math.min(
                            points.length - 1,
                            i + 2
                        )
                    ]


                const cp1x =
                    p1.x +
                    (
                        p2.x -
                        p0.x
                    ) / 6


                const cp1y =
                    p1.y +
                    (
                        p2.y -
                        p0.y
                    ) / 6


                const cp2x =
                    p2.x -
                    (
                        p3.x -
                        p1.x
                    ) / 6


                const cp2y =
                    p2.y -
                    (
                        p3.y -
                        p1.y
                    ) / 6


                ctx.bezierCurveTo(
                    cp1x,
                    cp1y,
                    cp2x,
                    cp2y,
                    p2.x,
                    p2.y
                )
            }


            // =====================================================
            // CLOSE
            // =====================================================

            ctx.lineTo(
                width,
                baseline
            )


            ctx.closePath()

            ctx.fill()
        }
    }


    // ============================================================
    // REDRAW
    // ============================================================

    onRenderedChanged:
        canvas.requestPaint()

    onWidthChanged:
        canvas.requestPaint()

    onHeightChanged:
        canvas.requestPaint()

    onColorChanged:
        canvas.requestPaint()
}
