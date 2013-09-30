
#import "JMStyledPathFactory.h"
#import "JMStyledPath.h"

@interface UIColor (HexUtilities)
+ (UIColor *)colorFromHexString:(NSString *)hexString;
@end

@implementation UIColor (HexUtilities)
+ (UIColor *)colorFromHexString:(NSString *)hexString;
{
    if (!hexString || [hexString isEqualToString:@"none"])
        return nil;
    
    unsigned int rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    scanner.scanLocation = 1;
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
                           green:((rgbValue & 0xFF00) >> 8)/255.0
                            blue:(rgbValue & 0xFF)/255.0
                           alpha:1.0];
}
@end

@interface NSDictionary (Utilities)
- (CGFloat)floatForKey:(NSString *)key;
- (UIColor *)strokeColorForKey:(NSString *)key;
- (UIColor *)fillColorForKey:(NSString *)key;
- (CGFloat)strokeWeightForKey:(NSString *)key;
- (NSArray *)dashArrayForKey:(NSString *)key;
- (CGLineJoin)lineJoinForKey:(NSString *)key;
- (CGLineCap)lineCapForKey:(NSString *)key;
- (CGFloat)miterLimitForKey:(NSString *)key;
@end

@implementation NSDictionary (Utilities)

- (CGFloat)floatForKey:(NSString *)key;
{
    NSString *value = [self valueForKey:key];
    return value ? [value floatValue] : 0.f;
}

- (UIColor *)strokeColorForKey:(NSString *)key;
{
    NSString *hexColor = [self valueForKey:key];
    return [UIColor colorFromHexString:hexColor];
}

- (UIColor *)fillColorForKey:(NSString *)key;
{
    NSString *hexColor = [self valueForKey:key] ?: @"#000000";
    return [UIColor colorFromHexString:hexColor];
}

- (NSArray *)dashArrayForKey:(NSString *)key;
{
    NSString *dashValues = [self valueForKey:key];
    if (!dashValues) return nil;

    NSMutableArray *floatValues =  NSMutableArray.new;
    NSArray *stringValues = [dashValues componentsSeparatedByString:@","];
    
    for (NSString *value in stringValues) {
        [floatValues addObject:@(value.floatValue)];
    }
    return floatValues;
}

- (CGFloat)strokeWeightForKey:(NSString *)key;
{
    NSString *value = [self valueForKey:key];
    return value ? value.floatValue : 1.f;
}

- (CGLineJoin)lineJoinForKey:(NSString *)key;
{
    NSString *value = [self valueForKey:key];
    if ([value isEqualToString:@"round"]) {
        return kCGLineJoinRound;
    }
    if ([value isEqualToString:@"square"]) {
        return kCGLineJoinBevel;
    }
    return kCGLineJoinMiter;
}

- (CGLineCap)lineCapForKey:(NSString *)key;
{
    NSString *value = [self valueForKey:key];
    if ([value isEqualToString:@"round"]) {
        return kCGLineCapRound;
    }
    if ([value isEqualToString:@"square"]) {
        return kCGLineCapSquare;
    }
    return kCGLineCapButt;
}

- (CGFloat)miterLimitForKey:(NSString *)key;
{
    NSString *miterLimit = [self valueForKey:key];
    return miterLimit ? miterLimit.floatValue : 10.f;
}

@end

@interface NSScanner (Utilities)
- (NSString *)initialCharacter;
- (NSString *)currentCharacter;
- (void)conditionallyIncrement;
- (BOOL)scanPoint:(CGPoint *)point;
@end

@implementation NSScanner (Utilities)

- (NSString *)initialCharacter;
{
    return [NSString stringWithFormat:@"%C", [self.string characterAtIndex:0]];
}

- (NSString *)currentCharacter;
{
    return [NSString stringWithFormat:@"%C", [self.string characterAtIndex:self.scanLocation]];
}

- (void)conditionallyIncrement;
{
    if (![self.currentCharacter isEqualToString:@"-"])
        self.scanLocation++;
}

- (BOOL)scanPoint:(CGPoint *)point;
{
    CGFloat xCoord;
    CGFloat yCoord;
    [self conditionallyIncrement];
    BOOL didScanX = [self scanFloat:&xCoord];
    [self conditionallyIncrement];
    BOOL didScanY = [self scanFloat:&yCoord];
    if (didScanX && didScanY) {
        *point = CGPointMake(xCoord, yCoord);
        return YES;
    }
    return NO;
}

@end

CGPoint CGPointAddPoints(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

CGPoint CGPointSubtractPoints(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

@interface JMStyledPathFactory ()
@property CGPoint previousControlPoint;
@end

@implementation JMStyledPathFactory

+ (JMStyledPath *)styledPathWithElementName:(NSString *)elementName attributes:(NSDictionary *)attributes;
{
    JMStyledPathFactory *factory = JMStyledPathFactory.new;
    if ([elementName isEqualToString:@"circle"]) {
        return [factory circleWithAttributes:attributes];
    }
    if ([elementName isEqualToString:@"ellipse"]) {
        return [factory ellipseWithAttributes:attributes];
    }
    if ([elementName isEqualToString:@"rect"]) {
        return [factory rectWithAttributes:attributes];
    }
    if ([elementName isEqualToString:@"path"]) {
        return [factory pathWithAttributes:attributes];
    }
    if ([elementName isEqualToString:@"polyline"]) {
        return [factory polylineWithAttributes:attributes];
    }
    if ([elementName isEqualToString:@"line"]) {
        return [factory lineWithAttributes:attributes];
    }
    return nil;
}

#pragma mark - Basic Element Factory Methods

- (JMStyledPath *)rectWithAttributes:(NSDictionary *)attributes;
{
    CGRect rect = CGRectMake([attributes floatForKey:@"x"],
                             [attributes floatForKey:@"y"],
                             [attributes floatForKey:@"width"],
                             [attributes floatForKey:@"height"]);
    JMStyledPath *styledPath = [JMStyledPath styledPathWithBezierPath:[UIBezierPath bezierPathWithRect:rect]
                                                            fillColor:[attributes fillColorForKey:@"fill"]
                                                          strokeColor:[attributes strokeColorForKey:@"stroke"]
                                                         strokeWeight:[attributes strokeWeightForKey:@"stroke-width"]
                                                            dashArray:[attributes dashArrayForKey:@"stroke-dasharray"]
                                                           miterLimit:[attributes miterLimitForKey:@"stroke-miterlimit"]
                                                         lineCapStyle:[attributes lineCapForKey:@"stroke-linecap"]
                                                        lineJoinStyle:[attributes lineJoinForKey:@"stroke-linejoin"]];
    return styledPath;
}

- (JMStyledPath *)ellipseWithAttributes:(NSDictionary *)attributes;
{
    CGRect rect = CGRectMake([attributes floatForKey:@"cx"] - [attributes floatForKey:@"rx"],
                             [attributes floatForKey:@"cy"] - [attributes floatForKey:@"ry"],
                             [attributes floatForKey:@"rx"] * 2.f,
                             [attributes floatForKey:@"ry"] * 2.f);
    JMStyledPath *styledPath = [JMStyledPath styledPathWithBezierPath:[UIBezierPath bezierPathWithOvalInRect:rect]
                                                            fillColor:[attributes fillColorForKey:@"fill"]
                                                          strokeColor:[attributes strokeColorForKey:@"stroke"]
                                                         strokeWeight:[attributes strokeWeightForKey:@"stroke-width"]
                                                            dashArray:[attributes dashArrayForKey:@"stroke-dasharray"]
                                                           miterLimit:[attributes miterLimitForKey:@"stroke-miterlimit"]
                                                         lineCapStyle:[attributes lineCapForKey:@"stroke-linecap"]
                                                        lineJoinStyle:[attributes lineJoinForKey:@"stroke-linejoin"]];
    return styledPath;
}

- (JMStyledPath *)circleWithAttributes:(NSDictionary *)attributes;
{
    NSMutableDictionary *newAttributes = attributes.mutableCopy;
    newAttributes[@"rx"] = attributes[@"r"];
    newAttributes[@"ry"] = attributes[@"r"];
    return [self ellipseWithAttributes:newAttributes];
}

- (JMStyledPath *)pathWithAttributes:(NSDictionary *)attributes;
{
    NSString *commandString = attributes[@"d"];
    NSArray *commandList = [self commandListForCommandString:commandString];
    UIBezierPath *commandListPath = [self bezierPathFromCommandList:commandList];
    JMStyledPath *styledPath = [JMStyledPath styledPathWithBezierPath:commandListPath
                                                            fillColor:[attributes fillColorForKey:@"fill"]
                                                          strokeColor:[attributes strokeColorForKey:@"stroke"]
                                                         strokeWeight:[attributes strokeWeightForKey:@"stroke-width"]
                                                            dashArray:[attributes dashArrayForKey:@"stroke-dasharray"]
                                                           miterLimit:[attributes miterLimitForKey:@"stroke-miterlimit"]
                                                         lineCapStyle:[attributes lineCapForKey:@"stroke-linecap"]
                                                        lineJoinStyle:[attributes lineJoinForKey:@"stroke-linejoin"]];

    return styledPath;
}

- (JMStyledPath *)polylineWithAttributes:(NSDictionary *)attributes;
{
    NSString *commandString = attributes[@"points"];
    NSArray *commandList = [self commandListForPolylineString:commandString];
    UIBezierPath *commandListPath = [self bezierPathFromCommandList:commandList];
    JMStyledPath *styledPath = [JMStyledPath styledPathWithBezierPath:commandListPath
                                                            fillColor:[attributes fillColorForKey:@"fill"]
                                                          strokeColor:[attributes strokeColorForKey:@"stroke"]
                                                         strokeWeight:[attributes strokeWeightForKey:@"stroke-width"]
                                                            dashArray:[attributes dashArrayForKey:@"stroke-dasharray"]
                                                           miterLimit:[attributes miterLimitForKey:@"stroke-miterlimit"]
                                                         lineCapStyle:[attributes lineCapForKey:@"stroke-linecap"]
                                                        lineJoinStyle:[attributes lineJoinForKey:@"stroke-linejoin"]];
    return styledPath;
}

- (JMStyledPath *)lineWithAttributes:(NSDictionary *)attributes;
{
    UIBezierPath *path = UIBezierPath.new;
    [path moveToPoint:CGPointMake([attributes floatForKey:@"x1"], [attributes floatForKey:@"y1"])];
    [path addLineToPoint:CGPointMake([attributes floatForKey:@"x2"], [attributes floatForKey:@"y2"])];

    JMStyledPath *styledPath = [JMStyledPath styledPathWithBezierPath:path
                                                            fillColor:[attributes fillColorForKey:@"fill"]
                                                          strokeColor:[attributes strokeColorForKey:@"stroke"]
                                                         strokeWeight:[attributes strokeWeightForKey:@"stroke-width"]
                                                            dashArray:[attributes dashArrayForKey:@"stroke-dasharray"]
                                                           miterLimit:[attributes miterLimitForKey:@"stroke-miterlimit"]
                                                         lineCapStyle:[attributes lineCapForKey:@"stroke-linecap"]
                                                        lineJoinStyle:[attributes lineJoinForKey:@"stroke-linejoin"]];
    return styledPath;
}

- (NSArray *)commandListForCommandString:(NSString *)commandString;
{
    NSScanner *commandScanner = [NSScanner scannerWithString:commandString];
    NSCharacterSet *knownCommands = [NSCharacterSet characterSetWithCharactersInString:@"MmLlCcVvHhAaSsQqTtZz"];
    NSMutableArray *commandList = NSMutableArray.new;
    
    NSString *command;
    NSUInteger lastLocation = 0;
    while (!commandScanner.isAtEnd) {
        [commandScanner scanUpToCharactersFromSet:knownCommands intoString:&command];
        NSString *fullCommand = [commandString substringWithRange:NSMakeRange(lastLocation, commandScanner.scanLocation - lastLocation)];
        if (![fullCommand isEqualToString:@""]) {
            [commandList addObject:fullCommand];
        };
        lastLocation = commandScanner.scanLocation;
        if (!commandScanner.isAtEnd) {
            commandScanner.scanLocation++;
        }
    }
    return commandList;
}

- (NSArray *)commandListForPolylineString:(NSString *)polylineString;
{
    NSMutableArray *commandList = NSMutableArray.new;
    NSArray *pairs = [polylineString componentsSeparatedByString:@" "];
    [pairs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([(NSString *)obj isEqualToString:@""]) {
            return;
        }
        if (commandList.count == 0) {
            [commandList addObject:[NSString stringWithFormat:@"M%@", obj]];
        } else {
            [commandList addObject:[NSString stringWithFormat:@"L%@", obj]];
        }
    }];
    return commandList;
}

- (UIBezierPath *)bezierPathFromCommandList:(NSArray *)commandList;
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (NSString *command in commandList) {
        NSScanner *commandScanner = [NSScanner scannerWithString:command];
        if ([@[@"M", @"m"] containsObject:commandScanner.currentCharacter]) {
            [self addMoveToPointFromCommandScanner:commandScanner toPath:path];
        }
        else if ([@[@"L", @"l"] containsObject:commandScanner.currentCharacter]) {
            [self addLineToPointFromCommandScanner:commandScanner toPath:path];
        }
        else if ([@[@"H", @"h"] containsObject:commandScanner.currentCharacter]) {
            [self addHorizontalLineToPointFromCommandScanner:commandScanner toPath:path];
        }
        else if ([@[@"V", @"v"] containsObject:commandScanner.currentCharacter]) {
            [self addVerticalLineToPointFromCommandScanner:commandScanner toPath:path];
        }
        else if ([@[@"C", @"c"] containsObject:commandScanner.currentCharacter]) {
            [self addCurveToPointFromCommandScanner:commandScanner toPath:path];
        }
        else if ([@[@"S", @"s"] containsObject:commandScanner.currentCharacter]) {
            [self addSmoothCurveToPointFromCommandScanner:commandScanner toPath:path];
        }
        else if ([@[@"Q", @"q"] containsObject:commandScanner.currentCharacter]) {
            [self addQuadCurveToPointFromCommandScanner:commandScanner toPath:path];
        }
        else if ([@[@"Z", @"z"] containsObject:commandScanner.currentCharacter]) {
            [path closePath];
        }
    }
    return path;
}

#pragma mark - Path Command Methods

- (void)addMoveToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    CGPoint moveToPoint;
    [commandScanner scanPoint:&moveToPoint];
    
    if ([commandScanner.initialCharacter isEqualToString:@"m"])
        moveToPoint = CGPointAddPoints(moveToPoint, path.currentPoint);
    [path moveToPoint:moveToPoint];
}

- (void)addLineToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    CGPoint lineToPoint;
    [commandScanner scanPoint:&lineToPoint];
    
    if ([commandScanner.initialCharacter isEqualToString:@"l"])
        lineToPoint = CGPointAddPoints(lineToPoint, path.currentPoint);
    [path addLineToPoint:lineToPoint];
}

- (void)addHorizontalLineToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    CGPoint horizontalLineToPoint;
    [commandScanner conditionallyIncrement];
    [commandScanner scanFloat:&horizontalLineToPoint.x];
    horizontalLineToPoint.y = path.currentPoint.y;
    
    if ([commandScanner.initialCharacter isEqualToString:@"h"])
        horizontalLineToPoint.x += path.currentPoint.x;
    [path addLineToPoint:horizontalLineToPoint];
}

- (void)addVerticalLineToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    CGPoint verticalLineToPoint;
    [commandScanner conditionallyIncrement];
    [commandScanner scanFloat:&verticalLineToPoint.y];
    verticalLineToPoint.x = path.currentPoint.x;
    
    if ([commandScanner.initialCharacter isEqualToString:@"v"])
        verticalLineToPoint.y += path.currentPoint.y;
    [path addLineToPoint:verticalLineToPoint];
}

- (void)addCurveToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    CGPoint curveToPoint;
    CGPoint controlPoint1;
    CGPoint controlPoint2;
    [commandScanner scanPoint:&controlPoint1];
    [commandScanner scanPoint:&controlPoint2];
    [commandScanner scanPoint:&curveToPoint];
    
    if ([commandScanner.initialCharacter isEqualToString:@"c"]) {
        curveToPoint = CGPointAddPoints(curveToPoint, path.currentPoint);
        controlPoint1 = CGPointAddPoints(controlPoint1, path.currentPoint);
        controlPoint2 = CGPointAddPoints(controlPoint2, path.currentPoint);
    }
    self.previousControlPoint = controlPoint2;
    [path addCurveToPoint:curveToPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
}

- (void)addSmoothCurveToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    CGPoint smoothedPrevious = CGPointSubtractPoints(path.currentPoint, self.previousControlPoint);
    CGPoint controlPoint1 = CGPointAddPoints(path.currentPoint, smoothedPrevious);
    CGPoint controlPoint2;
    CGPoint curveToPoint;
    [commandScanner scanPoint:&controlPoint2];
    [commandScanner scanPoint:&curveToPoint];
    
    if ([commandScanner.initialCharacter isEqualToString:@"s"]) {
        curveToPoint = CGPointAddPoints(curveToPoint, path.currentPoint);
        controlPoint2 = CGPointAddPoints(controlPoint2, path.currentPoint);
    }
    self.previousControlPoint = controlPoint2;
    [path addCurveToPoint:curveToPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
}

- (void)addQuadCurveToPointFromCommandScanner:(NSScanner *)commandScanner toPath:(UIBezierPath *)path;
{
    CGPoint controlPoint;
    CGPoint quadCurveToPoint;
    [commandScanner scanPoint:&controlPoint];
    [commandScanner scanPoint:&quadCurveToPoint];
    
    if ([commandScanner.initialCharacter isEqualToString:@"q"]) {
        controlPoint = CGPointAddPoints(controlPoint, path.currentPoint);
        quadCurveToPoint = CGPointAddPoints(quadCurveToPoint, path.currentPoint);
    }
    [path addQuadCurveToPoint:quadCurveToPoint controlPoint:controlPoint];
}

@end
