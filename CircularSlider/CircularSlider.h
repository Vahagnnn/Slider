//
//  CircularSlider.h
//
//  Created by Vahag Sargsyan on 11/10/16.
//  Copyright © 2016 Vahag Sargsyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircularSlider : UIControl

@property (nonatomic) float minValue;
@property (nonatomic) float maxValue;
@property (nonatomic) float currentValue;
@property (nonatomic) CGPoint currentPoint;

@property (nonatomic) int lineWidth;
@property (nonatomic, strong) UIColor *circuleColor;
@property (nonatomic, strong) UIColor *activeColor;
@property (nonatomic, strong) UIColor *thumbColor;

@end
