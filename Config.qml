
import QtQuick

QtObject {

    // ============================================================
    // POSITION
    // ============================================================

    // "top"
    // "bottom"
    //
    // TOP    = waveform grows DOWN
    // BOTTOM = waveform grows UP
    
    readonly property string position: "bottom"

    // "start"
    // "center"
    // "end"
    
    readonly property string alignment: "center"

    // Distance from the screen edge.
    
    readonly property int margin: 0
    

    // ============================================================
    // SIZE
    // ============================================================

    // Width of the visualizer.
    
    readonly property int visualizerWidth: 700

    // Maximum visualizer area.
    
    readonly property int visualizerHeight: 100

    // Maximum audio peak height.
    //
    // Lower = shorter peaks.
    // Higher = taller peaks.
    
    readonly property real maximumHeight: 50

    // Minimum height when audio is quiet.
    
    readonly property real minimumHeight: 0


    // ============================================================
    // COLOR
    // ============================================================

    readonly property color visualizerColor: "#ffffff"


    // ============================================================
    // SPECTRUM
    // ============================================================

    // Number of visual ridges.
    //
    // 32 = chunky
    // 64 = detailed
    // 96 = very detailed
    // 128 = extremely detailed
    
    readonly property int barCount: 96


    // ============================================================
    // OVERALL AUDIO SENSITIVITY
    // ============================================================

    // Overall multiplier.
    //
    // 0.5 = subtle
    // 1.0 = normal
    // 1.5 = strong
    // 2.0 = very reactive
    
    readonly property real sensitivity: 1.5


    // ============================================================
    // AUDIO RESPONSE
    // ============================================================

    // How quickly the waveform reacts when sound increases.
    //
    // Lower = faster.
    // Higher = slower.
    //
    // For trap / fast hats:
    // 0.015 - 0.035
    
    readonly property real attack: 0.035


    // How quickly peaks fall.
    //
    // Lower = sharper / snappier.
    // Higher = longer trails.
    
    readonly property real decay: 0.10


    // Existing smoothing used by the animation.
    //
    // Lower = more raw/reactive.
    // Higher = smoother.
    
    readonly property real smoothing: 0.035


    // ============================================================
    // FREQUENCY BALANCE
    // ============================================================

    // Bass / kick / sub-bass.
    
    readonly property real bassBoost: 1.70

    // Mid frequencies.
    
    readonly property real midBoost: 1.00

    // Treble / hi-hats / high frequency percussion.
    
    readonly property real highBoost: 1.70


    // ============================================================
    // RIDGES / WAVE SHAPE
    // ============================================================

    // Higher = sharper peaks and more visible ridges.
    //
    // 1.0 = soft
    // 1.5 = balanced
    // 2.0 = sharp
    // 2.5 = very sharp
    
    readonly property real ridgeSharpness: 1.70


    // Blends neighboring bars.
    //
    // 0.00 = maximum individual ridge detail
    // 0.04 = balanced
    // 0.10 = smooth
    // 0.20 = very smooth
    
    readonly property real waveSmooth: 0.04


    // ============================================================
    // TRANSIENT / BEAT REACTION
    // ============================================================

    // How strongly sudden audio changes affect the waveform.
    //
    // Higher = stronger reaction to kicks, snares and hats.
    
    readonly property real beatSensitivity: 1.00

    // How quickly the transient boost disappears.
    //
    // Lower = extremely snappy.
    // Higher = longer beat pulse.
    
    readonly property real beatDecay: 0.11


    // ============================================================
    // SPECTRUM MAPPING
    // ============================================================

    // Controls how quickly frequencies move from center -> edge.
    //
    // Lower = more bass area.
    // Higher = more even distribution.
    
    readonly property real frequencyCurve: 0.82


    // How strongly bass affects the center.
    
    readonly property real centerBassWeight: 0.45

    // Extra bass energy added directly to the center.
    
    readonly property real centerBassEnergy: 0.35


    // How strongly treble is emphasized at the edges.
    
    readonly property real edgeHighWeight: 1.00


    // ============================================================
    // TRANSIENT FREQUENCY WEIGHTS
    // ============================================================

    // Kick / bass transient contribution.
    readonly property real bassTransientWeight: 1.50

    // Snare / clap / mids contribution.
    readonly property real midTransientWeight: 1.20

    // Hats / treble contribution.
    readonly property real highTransientWeight: 0.90


    // Minimum transient required to trigger the pulse.
    readonly property real transientThreshold: 0.018

    // Strength of transient amplification.
    readonly property real transientMultiplier: 7.50

    // How much beatPulse increases the actual waveform.
    readonly property real beatPulseStrength: 0.65
}
