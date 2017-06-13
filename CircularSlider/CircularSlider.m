//
//  CircularSlider.m
//
//  Created by Vahag Sargsyan on 11/10/16.
//  Copyright © 2016 Vahag Sargsyan. All rights reserved.
//


 /*
  *******************************************************************************************************
  *******************************************************************************************************
  *******************************************************************************************************
  ****************************                Gradient Color                   **************************
  *******************************************************************************************************
  *******************************************************************************************************
  *******************************************************************************************************

 //Create a layer that holds your background image and add it as sublayer of your self.layer
 // Create the colors
 UIColor *topColor = [UIColor colorWithRed:0.0/255.0 green:188.0/255.0 blue:234.0/255.0 alpha:1.0];
 UIColor *center = [UIColor colorWithRed:255.0/255.0 green:127.0/255.0 blue:80.0/255.0 alpha:1.0];
 UIColor *bottomColor = [UIColor colorWithRed:245.0/255.0 green:54.0/255.0 blue:0.0/255.0 alpha:1.0];
 
 // Create the gradient
 CAGradientLayer *theViewGradient = [CAGradientLayer layer];
 theViewGradient.colors = [NSArray arrayWithObjects: (id)topColor.CGColor, (id)center.CGColor, (id)bottomColor.CGColor, nil];
 theViewGradient.frame = _circle.bounds;
 
 //Add gradient to view
 [_circle.layer insertSublayer:theViewGradient atIndex:0];
 */


#import "CircularSlider.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

#define kFontSize 14.0f;
#define ToRadian(degree) 		((M_PI * (degree)) / 180.0)
#define ToDegree(radian)		((180.0 * (radian)) / M_PI)

@interface CircularSlider()

@property (readonly, nonatomic) CGFloat radian;

@end

@implementation CircularSlider {
    int angle;
    int fixedAngle;
    NSMutableDictionary* labelsWithPercents;
    NSArray* labelsEvenSpacing;
}

- (void)defaultConfigs {
    _maxValue = 100.0f;
    _minValue = 0.0f;
    _currentValue = 0.0f;
    _lineWidth = 10;
    _circuleColor = [UIColor blackColor];
    angle = [self angleFromValue];
    self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultConfigs];
        
        [self setFrame:frame];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self=[super initWithCoder:aDecoder])){
        [self defaultConfigs];
    }
    
    return self;
}


#pragma mark - Setter/Getter

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    angle = [self angleFromValue];
}

- (CGFloat)radian {
    return self.frame.size.height/2 - _lineWidth/2 - ([self circleDiameter]-_lineWidth);
}

- (void)setCurrentValue:(float)currentValue {
    _currentValue=currentValue;
    
    if (_currentValue > _maxValue) {
        _currentValue = _maxValue;
    } else if (_currentValue < _minValue) {
        _currentValue = _minValue;
    }
    
    angle = [self angleFromValue];
    [self setNeedsLayout];
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setCurrentPoint:(CGPoint)currentPoint{
    _currentPoint = currentPoint;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - drawing methods

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Draw the unfilled circle
    CGContextAddArc(context, self.frame.size.width/2, self.frame.size.height/2, self.radian, 0, M_PI *2, 0);
    [_circuleColor setStroke];
    CGContextSetLineWidth(context, _lineWidth);
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextDrawPath(context, kCGPathStroke);
    
    
    //Draw the filled circle
    CGContextAddArc(context, self.frame.size.width/2  , self.frame.size.height/2, self.radian, 3*M_PI/2, 3*M_PI/2-ToRadian(angle), 0);
    
    [_activeColor setStroke];
    CGContextSetLineWidth(context, _lineWidth);
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextDrawPath(context, kCGPathStroke);
    
    //The draggable part
    [self drawHandle:context];
}

-(void) drawHandle:(CGContextRef)context{
    CGContextSaveGState(context);
    CGPoint handleCenter =  [self pointFromAngle:angle];
    
    /*
    // Shadow
    UIColor * shadowColor = [UIColor colorWithWhite:0.3 alpha:0.3];;
    CGContextSetFillColorWithColor(context, shadowColor.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(handleCenter.x-3, handleCenter.y-3, _lineWidth+4, _lineWidth+4));
    */
    
    [_thumbColor set];
    CGContextFillEllipseInRect(context, CGRectMake(handleCenter.x-2.5, handleCenter.y-2.5, _lineWidth+3, _lineWidth+3));

    CGContextRestoreGState(context);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint p1 = [self centerPoint];
    CGPoint p2 = point;
    CGFloat xDistance = (p2.x - p1.x);
    CGFloat yDistance = (p2.y - p1.y);
    double distance = sqrt(pow(xDistance, 2) + pow(yDistance, 2));
    return distance < self.radian + 11;
}

#pragma mark - UIControl functions

- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    [self sendActionsForControlEvents:UIControlEventTouchDown];

    return YES;
}

-(BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    [self moveHandle:[touch locationInView:self]];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

-(void)moveHandle:(CGPoint)point {
    CGPoint centerPoint;
    centerPoint = [self centerPoint];
    int currentAngle = floor(AngleFromNorth(centerPoint, point, NO));
    angle = 90 - currentAngle;
    _currentValue = [self valueFromAngle];
    [self setNeedsDisplay];
}

- (CGPoint)centerPoint {
    return CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

#pragma mark - helper functions

-(CGPoint)pointFromAngle:(int)angleInt{
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - _lineWidth/2, self.frame.size.height/2 - _lineWidth/2);
    
    CGPoint result;
    result.y = round(centerPoint.y + self.radian * sin(ToRadian(-angleInt-270)));
    result.x = round(centerPoint.x + self.radian * cos(ToRadian(-angleInt-270)));
    _currentPoint = result;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return result;
}

-(CGPoint)pointFromAngle:(int)angleInt withObjectSize:(CGSize)size{
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - size.width/2, self.frame.size.height/2 - size.height/2);
    
    CGPoint result;
    result.y = round(centerPoint.y + self.radian * sin(ToRadian(-angleInt-270))) ;
    result.x = round(centerPoint.x + self.radian * cos(ToRadian(-angleInt-270)));
    
    _currentPoint = result;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return result;
}

- (CGFloat)circleDiameter {
    return _lineWidth + 2.5;
}

static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    
    float vmag = sqrt(pow ((v.x), 2) + pow ((v.y), 2)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDegree(radians);

    return (result >=0  ? result : result + 360.0);
}

-(float) valueFromAngle {
    _currentValue = (angle < 0) ? -angle : 270 - angle + 90;
    fixedAngle = _currentValue;
    return (_currentValue * (_maxValue - _minValue))/360.0f + self.minValue;
}

- (float)angleFromValue {
    angle = 360 - ((_currentValue - self.minValue) * 360.0f/(_maxValue - _minValue));
    
    if(angle==360) {
        angle=0;
    }
    
    return angle;
}

- (CGFloat) widthOfString:(NSString *)string withFont:(UIFont*)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

- (CGFloat) heightOfString:(NSString *)string withFont:(UIFont*)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].height;
}

@end
