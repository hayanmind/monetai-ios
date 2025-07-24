//
//  DiscountBannerView.h
//  SimpleAppObjectiveC
//
//  Created by Daehoon Kim on 7/24/25.
//

#import <UIKit/UIKit.h>
#import <MonetaiSDK/MonetaiSDK-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface DiscountBannerView : UIView

- (void)showDiscount:(AppUserDiscount *)discount;
- (void)hideDiscount;

@end

NS_ASSUME_NONNULL_END 