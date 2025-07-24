//
//  DiscountBannerView.m
//  SimpleAppObjectiveC
//
//  Created by Daehoon Kim on 7/24/25.
//

#import "DiscountBannerView.h"

@interface DiscountBannerView ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *timeRemainingLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) AppUserDiscount *discount;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation DiscountBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    // Container View
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor systemGreenColor];
    self.containerView.layer.cornerRadius = 12;
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.containerView.layer.shadowOffset = CGSizeMake(0, 2);
    self.containerView.layer.shadowOpacity = 0.1;
    self.containerView.layer.shadowRadius = 4;
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.containerView];
    
    // Title Label
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"🎉 Special Discount!";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.titleLabel];
    
    // Description Label
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.text = @"Limited time offer available for you!";
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.font = [UIFont systemFontOfSize:14];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.descriptionLabel];
    
    // Time Remaining Label
    self.timeRemainingLabel = [[UILabel alloc] init];
    self.timeRemainingLabel.textColor = [UIColor whiteColor];
    self.timeRemainingLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    self.timeRemainingLabel.textAlignment = NSTextAlignmentCenter;
    self.timeRemainingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.timeRemainingLabel];
    
    // Close Button
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.closeButton setTitle:@"✕" forState:UIControlStateNormal];
    [self.closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.closeButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.closeButton];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        // Container View
        [self.containerView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.containerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        [self.containerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        [self.containerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        
        // Close Button
        [self.closeButton.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:12],
        [self.closeButton.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-12],
        [self.closeButton.widthAnchor constraintEqualToConstant:24],
        [self.closeButton.heightAnchor constraintEqualToConstant:24],
        
        // Title Label
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:16],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:16],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.closeButton.leadingAnchor constant:-8],
        
        // Description Label
        [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8],
        [self.descriptionLabel.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:16],
        [self.descriptionLabel.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-16],
        
        // Time Remaining Label
        [self.timeRemainingLabel.topAnchor constraintEqualToAnchor:self.descriptionLabel.bottomAnchor constant:8],
        [self.timeRemainingLabel.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:16],
        [self.timeRemainingLabel.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-16],
        [self.timeRemainingLabel.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor constant:-16]
    ]];
}

#pragma mark - Public Methods

- (void)showDiscount:(AppUserDiscount *)discount {
    self.discount = discount;
    [self updateTimeRemaining];
    [self startTimer];
    
    // Animate in
    self.alpha = 0;
    self.transform = CGAffineTransformMakeTranslation(0, 50);
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)hideDiscount {
    [self stopTimer];
    
    // Animate out
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeTranslation(0, 50);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Private Methods

- (void)updateTimeRemaining {
    if (!self.discount) return;
    
    NSDate *now = [NSDate date];
    NSDate *endTime = self.discount.endedAt;
    NSTimeInterval timeRemaining = [endTime timeIntervalSinceDate:now];
    
    if (timeRemaining > 0) {
        NSInteger hours = (NSInteger)timeRemaining / 3600;
        NSInteger minutes = (NSInteger)timeRemaining % 3600 / 60;
        
        if (hours > 0) {
            self.timeRemainingLabel.text = [NSString stringWithFormat:@"⏰ %ldh %ldm remaining", (long)hours, (long)minutes];
        } else {
            self.timeRemainingLabel.text = [NSString stringWithFormat:@"⏰ %ldm remaining", (long)minutes];
        }
    } else {
        self.timeRemainingLabel.text = @"⏰ Expired";
        [self hideDiscount];
    }
}

- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateTimeRemaining) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Actions

- (void)closeButtonTapped {
    [self hideDiscount];
}

@end 