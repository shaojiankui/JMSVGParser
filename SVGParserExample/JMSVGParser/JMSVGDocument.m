/*
 
 Copyright (c) 2013 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "JMSVGDocument.h"
#import "JMSVGParser.h"
#import "JMStyledPath.h"

@interface JMSVGDocument ()
@property (nonatomic) NSArray *jmSVGShapes;
@property (nonatomic) CGSize size;
@end

@implementation JMSVGDocument

+ (JMSVGDocument *)documentNamed:(NSString *)documentName;
{
    JMSVGDocument *document = JMSVGDocument.new;
    JMSVGParser *parser = [JMSVGParser.alloc initWithSVGDocument:[NSBundle.mainBundle pathForResource:documentName ofType:@"svg"]];
    [parser parse];
    document.jmSVGShapes = parser.paths;
    document.size = parser.viewBox.size;
    return document;
}

- (void)drawInCurrentContext;
{
    for (JMStyledPath *styledPath in self.jmSVGShapes) {
        [styledPath drawStyledPath];
    }
}

- (UIImage *)image;
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.f);
    [self drawInCurrentContext];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
