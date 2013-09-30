JMSVGParser
===========

A simple SVG parser for iOS

Supported shapes/features:

• Circle
• Ellipse
• Rectangle
• Line
• Polyline
• Bezier Path

• Fill Color (in hex "#xxxxxx" format)
• Stroke Color (in hex "#xxxxxx" format)
• Stroke Weight
• Line Dashes
• Line Join/Cap (Butt/Round/Miter)

To use:

1. Send an SVG document to the parser and get back an array of shapes.
2. Draw each shape in your view's drawRect method.
3. There is no step 3.

Grab the example to see how it works. Cheers!
