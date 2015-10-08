//
//  NHSelectorView.m
//  Pods
//
//  Created by Sergey Minakov on 08.10.15.
//
//

#import "NHSelectorView.h"

#define kNHSelectorDefaultFont \
[UIFont systemFontOfSize:17]

#define kNHSelectorDefaultNormalColor \
[UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1]

#define kNHSelectorDefaultSelectedColor \
[UIColor colorWithRed:0 green:0 blue:0 alpha:1]

static CGFloat const kNHSelectorSelectionDefaultHeight = 1.5;

@interface NHSelectorView ()

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSArray<UIButton *> *buttonArray;

@property (nonatomic, strong) NSMutableDictionary *buttonProperties;

@property (nonatomic, strong) UIView *selectionView;
@property (nonatomic, strong) UIView *separatorView;

@end

@implementation NHSelectorView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self nhCommonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self nhCommonInit];
    }
    
    return self;
}

- (void)dealloc {
    [self removeFromSuperview];
    [self clearButtonArray];
    self.buttonProperties = nil;
}

- (void)nhCommonInit {
    self.font = kNHSelectorDefaultFont;
    self.tintColor = kNHSelectorDefaultNormalColor;
    self.buttonProperties = [NSMutableDictionary new];
    self.buttonProperties[@(UIControlStateNormal)] = kNHSelectorDefaultNormalColor;
    self.buttonProperties[@(UIControlStateSelected)] = kNHSelectorDefaultSelectedColor;
    
    self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 0.5, self.bounds.size.width, 0.5)];
    self.separatorView.autoresizingMask = ~UIViewAutoresizingNone;
    self.separatorView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:self.separatorView];
    
    self.selectionView = [[UIView alloc] init];
    self.selectionView.backgroundColor = kNHSelectorDefaultNormalColor;
    self.selectionView.autoresizingMask = ~UIViewAutoresizingNone;
    [self addSubview:self.selectionView];

    [self sendSubviewToBack:self.selectionView];
    [self sendSubviewToBack:self.separatorView];
    
    self.selectionSize = CGSizeZero;
}

- (void)clearButtonArray {
    [self.buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj,
                                                   NSUInteger idx,
                                                   BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    self.buttonArray = nil;
}

- (void)setItems:(nullable NSArray *)items {
    [self clearButtonArray];
    
    self.selectedIndex = 0;
    
    UIButton *(^createButton)(void) = ^UIButton *{
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:self.buttonProperties[@(UIControlStateNormal)] forState:UIControlStateNormal];
        [button setTitleColor:self.buttonProperties[@(UIControlStateSelected)] forState:UIControlStateSelected];
        [button setTitleColor:self.buttonProperties[@(UIControlStateDisabled)] forState:UIControlStateDisabled];
        [button setTitleColor:self.buttonProperties[@(UIControlStateHighlighted)] forState:UIControlStateHighlighted];
        button.backgroundColor = [UIColor clearColor];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        button.tintColor = self.tintColor;
        [button addTarget:self
                   action:@selector(buttonTouchAction:)
         forControlEvents:UIControlEventTouchUpInside];
        
        return button;
    };
    
    NSMutableArray<UIButton *> *mutableButtonArray = [NSMutableArray new];
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj,
                                        NSUInteger idx,
                                        BOOL * _Nonnull stop) {
        UIButton *button;
        if ([obj isKindOfClass:[NSString class]]) {
            button = createButton();
            [button setTitle:obj forState:UIControlStateNormal];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
            button.titleLabel.minimumScaleFactor = 0.8;
            button.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            
            [mutableButtonArray addObject:button];
        }
        else if ([obj isKindOfClass:[UIImage class]]) {
            button = createButton();
            [button setImage:obj forState:UIControlStateNormal];
            button.imageView.contentMode = UIViewContentModeCenter;
            
            [mutableButtonArray addObject:button];
        }
    }];
    
    self.buttonArray = mutableButtonArray;
    
    CGFloat singleButtonWidth = self.bounds.size.width / self.buttonArray.count;
    
    [self.buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj,
                                                   NSUInteger idx,
                                                   BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(idx * singleButtonWidth, 0, singleButtonWidth, self.bounds.size.height);
        obj.autoresizingMask = ~UIViewAutoresizingNone;
        [self addSubview:obj];
    }];
    
    self.buttonArray.firstObject.selected = YES;
    
    [self resetSelectionView];
}

- (void)resetSelectionView {
    if (!self.buttonArray.count) {
        self.selectionView.frame = CGRectZero;
        return;
    }
    
    CGFloat singleButtonWidth = self.bounds.size.width / self.buttonArray.count;

    CGFloat xOffset = self.selectionSize.width;
    CGFloat yOffset = self.selectionSize.height;
    
    CGRect selectionViewRect = CGRectMake(singleButtonWidth * self.selectedIndex + xOffset / 2,
                                          0,
                                          singleButtonWidth - xOffset,
                                          0);

    switch (self.selectionStyle) {
        case NHSelectorViewSelectionStyleDefault:
            selectionViewRect.origin.y = yOffset / 2;
            selectionViewRect.size.height = self.bounds.size.height - yOffset;
            break;
        case NHSelectorViewSelectionStyleLine: {
            CGFloat lineHeight = (yOffset <= 0 ? kNHSelectorSelectionDefaultHeight : yOffset);
            selectionViewRect.origin.y = self.bounds.size.height - lineHeight;
            selectionViewRect.size.height = lineHeight;
        } break;
        default:
            break;
    }
    
    self.selectionView.frame = selectionViewRect;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    if (self.buttonArray.count <= selectedIndex) {
        return;
    }
    
    self.buttonArray[self.selectedIndex].selected = NO;
    self.buttonArray[selectedIndex].selected = YES;
    
    self.selectedIndex = selectedIndex;
    
    [UIView animateWithDuration:animated ? 0.3 : 0 animations:^{
        [self resetSelectionView];
    }];
}

- (void)setColor:(UIColor *)color forState:(UIControlState)state {
    if (color) {
        self.buttonProperties[@(state)] = color;
    }
    else {
        switch (state) {
            case UIControlStateNormal:
                self.buttonProperties[@(state)] = kNHSelectorDefaultNormalColor;
                break;
            case UIControlStateSelected:
                self.buttonProperties[@(state)] = kNHSelectorDefaultSelectedColor;
                break;
            default:
                [self.buttonProperties removeObjectForKey:@(state)];
                break;
        }
    }
    
    [self.buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj,
                                                   NSUInteger idx,
                                                   BOOL * _Nonnull stop) {
        [obj setTitleColor:self.buttonProperties[@(state)]
                  forState:state];
    }];
}

- (void)setFont:(UIFont *)font {
    [self willChangeValueForKey:@"font"];
    if (font) {
        _font = font;
    }
    else {
        _font = kNHSelectorDefaultFont;
    }
    
    [self.buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj,
                                                   NSUInteger idx,
                                                   BOOL * _Nonnull stop) {
        obj.titleLabel.font = _font;
    }];
    [self didChangeValueForKey:@"font"];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    [self.buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj,
                                                   NSUInteger idx,
                                                   BOOL * _Nonnull stop) {
        obj.tintColor = self.tintColor;
    }];
}

- (void)setSelectionStyle:(NHSelectorViewSelectionStyle)selectionStyle {
    [self willChangeValueForKey:@"selectionStyle"];
    _selectionStyle = selectionStyle;
    
    [self resetSelectionView];
    [self didChangeValueForKey:@"selectionStyle"];
}

- (void)setSelectionSize:(CGSize)selectionSize {
    [self willChangeValueForKey:@"selectionSize"];
    _selectionSize = selectionSize;
    
    [self resetSelectionView];
    [self didChangeValueForKey:@"selectionSize"];
}

- (void)buttonTouchAction:(UIButton *)button {
    NSInteger newIndex = [self.buttonArray indexOfObject:button];
    
    if (newIndex != NSNotFound) {
        [self setSelectedIndex:newIndex animated:YES];
        
        if ([self.delegate respondsToSelector:@selector(nhSelectorView:didChangeIndexTo:)]) {
            [self.delegate nhSelectorView:self didChangeIndexTo:newIndex];
        }
    }
}

@end
