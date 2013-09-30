
#import "JMStyledPath.h"

@interface JMStyledPath ()
@property (nonatomic) UIBezierPath *path;
@property (nonatomic) UIColor *fillColor;
@property (nonatomic) UIColor *strokeColor;
@end

@implementation JMStyledPath

+ (JMStyledPath *)styledPathWithBezierPath:(UIBezierPath *)bezierPath fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor strokeWeight:(CGFloat)strokeWeight dashArray:(NSArray *)dashArray miterLimit:(CGFloat)miterLimit lineCapStyle:(CGLineCap)lineCapStyle lineJoinStyle:(CGLineJoin)lineJoinStyle;
{
    JMStyledPath *styledPath = JMStyledPath.new;
    styledPath.fillColor = fillColor;
    styledPath.strokeColor = strokeColor;
    
    styledPath.path = bezierPath;
    styledPath.path.lineWidth = strokeWeight;
    styledPath.path.miterLimit = miterLimit;
    styledPath.path.lineJoinStyle = lineJoinStyle;
    styledPath.path.lineCapStyle = lineCapStyle;
    if (dashArray) {
        CGFloat values[dashArray.count];
        for (int i = 0; i < dashArray.count; i++) {
            values[i] = [dashArray[i] floatValue];
        }
        [styledPath.path setLineDash:values count:dashArray.count phase:0.f];
    }
    return styledPath;
}

- (void)drawStyledPath;
{
    if (self.fillColor) {
        [self.fillColor setFill];
        [self.path fill];
    }
    if (self.strokeColor && self.path.lineWidth > 0.f) {
        [self.strokeColor setStroke];
        [self.path stroke];
    }
}

@end
