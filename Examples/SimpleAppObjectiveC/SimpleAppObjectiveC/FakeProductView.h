//
//  FakeProductView.h
//  SimpleAppObjectiveC
//
//  Created by Daehoon Kim on 7/24/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FakeProductView : UIView

// Configure display texts
- (void)configureWithTitle:(NSString *)title
             regularPrice:(NSString *)regularPrice
            discountPrice:(NSString *)discountPrice
               description:(NSString *)descriptionText;

// Called when view is attached to a window (optional)
@property (nonatomic, copy, nullable) void (^onAppear)(void);

@end

NS_ASSUME_NONNULL_END

