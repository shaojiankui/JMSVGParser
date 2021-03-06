
#import "JMExampleView.h"
#import "JMSVGDocument.h"
#import "JMSVGParser.h"
#import "JMStyledPath.h"

@interface JMExampleView ()
@property (nonatomic) JMSVGDocument *svgDocument;
@end

@implementation JMExampleView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    
    self.svgDocument = [JMSVGDocument documentNamed:@"awesome_tiger"];
    self.scale = 1.f;
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), self.shouldAntialias);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), self.scale, self.scale);
    
    [self.svgDocument drawInCurrentContext];
}

@end
