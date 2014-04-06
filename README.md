Update: I've moved most of this to a new and better project that's easier to use and just makes more sense. Check it out here:

https://github.com/jmenter/JAMSVGImage

JMSVGParser
===========

A simple SVG parser/document wrapper for iOS

Supported shapes/features:

Shape Primitives:
- Circle
- Ellipse
- Rectangle
- Line
- Polyline
- Bezier Path

Shape Appearance:
- Fill Color (in hex "#xxxxxx" format)
- Stroke Color (in hex "#xxxxxx" format)
- Stroke Weight
- Line Dashes
- Line Join/Cap (Butt/Round/Miter)

SVG Document Properties:
- viewBox

To use:

1. JMSVGDocument *svgDocument = [JMSVGDocument documentNamed:@"awesome_tiger"] to get a new JMSVGDocument.
2. [svgDocument drawInCurrentContext] or [svgDocument image] to use.
3. There is no step 3.

Grab the example to see how it works. Cheers!
