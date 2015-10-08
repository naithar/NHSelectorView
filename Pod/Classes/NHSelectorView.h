//
//  NHSelectorView.h
//  Pods
//
//  Created by Sergey Minakov on 08.10.15.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NHSelectorViewSelectionStyle) {
    NHSelectorViewSelectionStyleDefault,
    NHSelectorViewSelectionStyleLine,
};

NS_ASSUME_NONNULL_BEGIN

@class NHSelectorView;

@protocol NHSelectorViewDelegate <NSObject>

@end

@interface NHSelectorView : UIView

@property (nonatomic, weak) id<NHSelectorViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *separatorView;

@property (nonatomic, strong, null_resettable) UIFont *font;
@property (nonatomic, assign, readonly) NSInteger selectedIndex;

@property (nonatomic, assign) NHSelectorViewSelectionStyle selectionStyle;

- (void)setItems:(nullable NSArray *)items;
- (void)setColor:(UIColor *)color forState:(UIControlState)state;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END