MText {
	property real fill: 0

	font.family: "Material Symbols Rounded"
	font.pointSize: 50
	font.variableAxes: ({
			FILL: fill.toFixed(1),
			opsz: Math.max(fontInfo.pixelSize, 1),
			wght: fontInfo.weight
		})
}
