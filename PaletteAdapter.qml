import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    required property QtObject config

    property var colors: []


    // ================================================================
    // PATH
    // ================================================================

    function expandPath(path) {
        if (!path)
            return ""

        if (path.startsWith("~")) {
            const home = Quickshell.env("HOME")
            return home + path.substring(1)
        }

        return path
    }


    // ================================================================
    // PALETTE FILE
    // ================================================================

    property FileView paletteFile: FileView {
        id: paletteFile

        path: root.expandPath(root.config.paletteFile)

        watchChanges: root.config.usePalette
        blockLoading: true

        onFileChanged: {
            console.log("AudioFrame: palette file changed")
            reload()
        }

        onLoaded: {
            console.log("AudioFrame: palette loaded")
            root.reloadPalette()
        }
    }


    // ================================================================
    // RELOAD PALETTE
    // ================================================================

    function reloadPalette() {
        if (!root.config.usePalette) {
            root.colors = []
            return
        }

        if (!paletteFile.loaded) {
            root.colors = []
            return
        }

        const text = paletteFile.text()

        if (!text) {
            root.colors = []
            return
        }

        try {
            const json = JSON.parse(text)
            let extracted = []

            // --------------------------------------------------------
            // First try configured/common palette locations.
            // --------------------------------------------------------
            extracted = findPaletteArray(json)

            // --------------------------------------------------------
            // If no structured palette was found,
            // recursively collect any valid colors.
            // --------------------------------------------------------
            if (extracted.length === 0) {
                extracted = collectColors(json)
            }

            root.colors = normalizeColors(extracted)

            console.log(
                "AudioFrame: loaded",
                root.colors.length,
                "palette colors"
            )

        } catch (error) {
            console.warn(
                "AudioFrame: failed to parse palette:",
                error
            )
            root.colors = []
        }
    }


    // ================================================================
    // STRUCTURED PALETTE DETECTION
    // ================================================================

    function findPaletteArray(json) {
        // Direct Array
        if (Array.isArray(json))
            return collectColors(json)

        if (!json || typeof json !== "object")
            return []

        // Explicit palette array
        if (json.palette !== undefined) {
            const result = collectColors(json.palette)
            if (result.length > 0)
                return result
        }

        // ============================================================
        // COLORS / COLOURS OBJECT
        // Checks both American ("colors") and British ("colours") spellings.
        // ============================================================
        const colorsObj = json.colors || json.colours

        if (
            colorsObj &&
            typeof colorsObj === "object" &&
            !Array.isArray(colorsObj)
        ) {
            const schemes = [
                "default",
                "dark",
                "light"
            ]

            for (const scheme of schemes) {
                if (colorsObj[scheme]) {
                    const result = collectConfiguredColors(colorsObj[scheme])
                    if (result.length > 0)
                        return result
                }
            }

            const result = collectConfiguredColors(colorsObj)
            if (result.length > 0)
                return result
        }

        // ============================================================
        // OTHER STRUCTURED PALETTE OBJECTS
        // ============================================================
        const otherKeys = [
            "colorPalette",
            "colourPalette",
            "palette"
        ]

        for (const key of otherKeys) {
            if (json[key] !== undefined) {
                const result = collectConfiguredColors(json[key])
                if (result.length > 0)
                    return result
            }
        }

        // ============================================================
        // GENERIC NESTED OBJECTS
        // ============================================================
        const preferredKeys = [
            "theme",
            "default",
            "dark",
            "light"
        ]

        for (const key of preferredKeys) {
            if (json[key] !== undefined) {
                const result = findPaletteArray(json[key])
                if (result.length > 0)
                    return result
            }
        }

        return []
    }


    // ================================================================
    // CONFIGURED COLOR EXTRACTION
    // ================================================================

    function collectConfiguredColors(object) {
        if (!object || typeof object !== "object")
            return []

        const result = []
        const keys = root.config.paletteKeys || []

        // First use explicitly configured keys.
        for (const key of keys) {
            if (object[key] === undefined)
                continue

            const value = object[key]

            if (isColor(value))
                result.push(value)
        }

        // If configured keys produced colors, use those instead.
        if (result.length > 0)
            return result

        // Otherwise recursively search this object.
        return collectColors(object)
    }


    // ================================================================
    // GENERIC COLOR EXTRACTION
    // ================================================================

    function collectColors(value) {
        const result = []

        if (isColor(value)) {
            result.push(value)
            return result
        }

        if (Array.isArray(value)) {
            for (const item of value) {
                const found = collectColors(item)
                result.push(...found)
            }
            return result
        }

        if (value && typeof value === "object") {
            const keys = root.config.paletteKeys || []

            // Prefer configured keys first.
            for (const key of keys) {
                if (value[key] !== undefined) {
                    const found = collectColors(value[key])
                    result.push(...found)
                }
            }

            // Then inspect everything else.
            for (const key of Object.keys(value)) {
                if (keys.includes(key))
                    continue

                const found = collectColors(value[key])
                result.push(...found)
            }
        }

        return result
    }


    // ================================================================
    // COLOR VALIDATION
    // Accepts hex strings WITH or WITHOUT a leading '#'
    // ================================================================

    function isColor(value) {
        if (typeof value !== "string")
            return false

        const valueTrimmed = value.trim()

        // Match optional '#' followed by 3, 4, 6, or 8 hex characters
        if (/^#?([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(valueTrimmed))
            return true

        // rgb(), rgba(), hsl(), hsla()
        if (/^(rgb|rgba|hsl|hsla)\(/i.test(valueTrimmed))
            return true

        return false
    }


    // ================================================================
    // NORMALIZATION
    // Prepends missing '#' and removes duplicates.
    // ================================================================

    function normalizeColors(input) {
        const result = []
        const seen = {}

        for (const value of input) {
            if (!isColor(value))
                continue

            let color = value.trim()

            // Prepend missing '#' if it's a naked hex value
            if (!color.startsWith("#") && !color.includes("(")) {
                color = "#" + color
            }

            const key = color.toLowerCase()

            if (seen[key])
                continue

            seen[key] = true
            result.push(color)
        }

        return result
    }
}
