MText {
	property real fill

	font.family: "Material Symbols Rounded"
	font.pointSize: 50
	font.variableAxes: ({
			FILL: fill.toFixed(1),
			opsz: fontInfo.pixelSize,
			wght: fontInfo.weight
		})
}
