//
//  ViewController.m
//  ObjectiveCExample
//
//  Created by Daehoon Kim on 7/24/25.
//

#import "ViewController.h"
#import "Constants.h"
#import <objc/runtime.h>
#import <MonetaiSDK/MonetaiSDK-Swift.h>
@import RevenueCat;

@interface ViewController ()

// UI
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *mainStack;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *storeKitLabel;
@property (nonatomic, strong) UIButton *getOfferButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UIView *offerResultContainer;
@property (nonatomic, strong) UILabel *offerResultLabel;
@property (nonatomic, strong) UILabel *subscriberStatusLabel;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UILabel *productsSectionLabel;
@property (nonatomic, strong) UIStackView *productsStack;
@property (nonatomic, strong) UILabel *customerInfoSectionLabel;
@property (nonatomic, strong) UIStackView *customerInfoStack;

// State
@property (nonatomic, assign) BOOL isInitialized;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) NSArray<RCPackage *> *packages;
@property (nonatomic, strong) RCCustomerInfo *customerInfo;
@property (nonatomic, strong) Offer *offer;
@property (nonatomic, strong) NSTimer *statusCheckTimer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.packages = @[];
    [self setupUI];
    [self setupNotifications];
    [self startSDKStatusCheck];

    // Log app launch event
    [[MonetaiSDK shared] logEventWithEventName:@"app_in" params:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.statusCheckTimer invalidate];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    // ScrollView
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];

    // Main StackView
    self.mainStack = [[UIStackView alloc] init];
    self.mainStack.axis = UILayoutConstraintAxisVertical;
    self.mainStack.spacing = 0;
    self.mainStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.mainStack];

    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.mainStack.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.mainStack.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.mainStack.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.mainStack.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.mainStack.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor]
    ]];

    [self setupHeaderSection];
    [self setupStoreKitInfoSection];
    [self setupOfferSection];
    [self setupProductsSection];
    [self setupCustomerInfoSection];
}

- (void)setupHeaderSection {
    UIView *container = [self createSectionContainer];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"Monetai Obj-C Example";
    self.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    self.titleLabel.textColor = [UIColor labelColor];

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"Connecting...";
    self.statusLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    self.statusLabel.textColor = [UIColor secondaryLabelColor];
    self.statusLabel.textAlignment = NSTextAlignmentRight;

    UIStackView *hStack = [[UIStackView alloc] initWithArrangedSubviews:@[self.titleLabel, self.statusLabel]];
    hStack.axis = UILayoutConstraintAxisHorizontal;
    hStack.distribution = UIStackViewDistributionFill;
    hStack.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:hStack];

    [NSLayoutConstraint activateConstraints:@[
        [hStack.topAnchor constraintEqualToAnchor:container.topAnchor constant:15],
        [hStack.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:20],
        [hStack.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-20],
        [hStack.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-15]
    ]];

    [self addSeparatorToView:container];
    [self.mainStack addArrangedSubview:container];
}

- (void)setupStoreKitInfoSection {
    UIView *container = [self createSectionContainer];
    container.backgroundColor = [UIColor systemGray6Color];

    self.storeKitLabel = [[UILabel alloc] init];
    self.storeKitLabel.font = [UIFont systemFontOfSize:14];
    self.storeKitLabel.textAlignment = NSTextAlignmentCenter;
    self.storeKitLabel.translatesAutoresizingMaskIntoConstraints = NO;

    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"StoreKit Version: "
                                                                             attributes:@{NSForegroundColorAttributeName: [UIColor secondaryLabelColor]}];
    [attr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"StoreKit %@", kUseStoreKit2 ? @"2" : @"1"]
                                                                attributes:@{NSForegroundColorAttributeName: [UIColor systemBlueColor],
                                                                             NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold]}]];
    self.storeKitLabel.attributedText = attr;

    [container addSubview:self.storeKitLabel];
    [NSLayoutConstraint activateConstraints:@[
        [self.storeKitLabel.topAnchor constraintEqualToAnchor:container.topAnchor constant:8],
        [self.storeKitLabel.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:20],
        [self.storeKitLabel.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-20],
        [self.storeKitLabel.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-8]
    ]];

    [self addSeparatorToView:container];
    [self.mainStack addArrangedSubview:container];
}

- (void)setupOfferSection {
    UIView *container = [self createSectionContainer];

    UIStackView *vStack = [[UIStackView alloc] init];
    vStack.axis = UILayoutConstraintAxisVertical;
    vStack.spacing = 12;
    vStack.translatesAutoresizingMaskIntoConstraints = NO;

    // Get Offer button
    self.getOfferButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.getOfferButton setTitle:@"Get Offer" forState:UIControlStateNormal];
    self.getOfferButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.getOfferButton.backgroundColor = [UIColor systemBlueColor];
    [self.getOfferButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.getOfferButton.layer.cornerRadius = 8;
    self.getOfferButton.enabled = NO;
    self.getOfferButton.alpha = 0.5;
    [self.getOfferButton addTarget:self action:@selector(getOfferButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.getOfferButton.heightAnchor constraintEqualToConstant:44].active = YES;

    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingIndicator.color = [UIColor whiteColor];
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.getOfferButton addSubview:self.loadingIndicator];
    [NSLayoutConstraint activateConstraints:@[
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.getOfferButton.centerYAnchor],
        [self.loadingIndicator.leadingAnchor constraintEqualToAnchor:self.getOfferButton.leadingAnchor constant:20]
    ]];

    [vStack addArrangedSubview:self.getOfferButton];

    // Offer result container (hidden by default)
    self.offerResultContainer = [[UIView alloc] init];
    self.offerResultContainer.backgroundColor = [UIColor colorWithRed:0.91 green:0.96 blue:0.91 alpha:1.0];
    self.offerResultContainer.layer.cornerRadius = 8;
    self.offerResultContainer.layer.masksToBounds = YES;
    self.offerResultContainer.hidden = YES;

    self.offerResultLabel = [[UILabel alloc] init];
    self.offerResultLabel.font = [UIFont systemFontOfSize:13];
    self.offerResultLabel.numberOfLines = 0;
    self.offerResultLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.offerResultContainer addSubview:self.offerResultLabel];
    [NSLayoutConstraint activateConstraints:@[
        [self.offerResultLabel.topAnchor constraintEqualToAnchor:self.offerResultContainer.topAnchor constant:10],
        [self.offerResultLabel.bottomAnchor constraintEqualToAnchor:self.offerResultContainer.bottomAnchor constant:-10],
        [self.offerResultLabel.leadingAnchor constraintEqualToAnchor:self.offerResultContainer.leadingAnchor constant:12],
        [self.offerResultLabel.trailingAnchor constraintEqualToAnchor:self.offerResultContainer.trailingAnchor constant:-12]
    ]];

    [vStack addArrangedSubview:self.offerResultContainer];

    // Subscriber status
    self.subscriberStatusLabel = [[UILabel alloc] init];
    self.subscriberStatusLabel.text = @"Subscriber Status: Not Subscribed";
    self.subscriberStatusLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.subscriberStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.subscriberStatusLabel.backgroundColor = [UIColor systemGray6Color];
    self.subscriberStatusLabel.layer.cornerRadius = 8;
    self.subscriberStatusLabel.layer.masksToBounds = YES;
    self.subscriberStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.subscriberStatusLabel.heightAnchor constraintEqualToConstant:38].active = YES;
    [vStack addArrangedSubview:self.subscriberStatusLabel];

    // Error label (hidden by default)
    self.errorLabel = [[UILabel alloc] init];
    self.errorLabel.font = [UIFont systemFontOfSize:12];
    self.errorLabel.textColor = [UIColor systemRedColor];
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.hidden = YES;
    [vStack addArrangedSubview:self.errorLabel];

    [container addSubview:vStack];
    [NSLayoutConstraint activateConstraints:@[
        [vStack.topAnchor constraintEqualToAnchor:container.topAnchor constant:15],
        [vStack.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:20],
        [vStack.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-20],
        [vStack.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-15]
    ]];

    [self addSeparatorToView:container];
    [self.mainStack addArrangedSubview:container];
}

- (void)setupProductsSection {
    UIView *container = [self createSectionContainer];

    UIStackView *vStack = [[UIStackView alloc] init];
    vStack.axis = UILayoutConstraintAxisVertical;
    vStack.spacing = 12;
    vStack.translatesAutoresizingMaskIntoConstraints = NO;

    self.productsSectionLabel = [[UILabel alloc] init];
    self.productsSectionLabel.text = @"Available Products";
    self.productsSectionLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    self.productsSectionLabel.textColor = [UIColor labelColor];
    [vStack addArrangedSubview:self.productsSectionLabel];

    self.productsStack = [[UIStackView alloc] init];
    self.productsStack.axis = UILayoutConstraintAxisVertical;
    self.productsStack.spacing = 8;
    [vStack addArrangedSubview:self.productsStack];

    [container addSubview:vStack];
    [NSLayoutConstraint activateConstraints:@[
        [vStack.topAnchor constraintEqualToAnchor:container.topAnchor constant:20],
        [vStack.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:20],
        [vStack.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-20],
        [vStack.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-20]
    ]];

    [self.mainStack addArrangedSubview:container];

    // Show loading initially
    [self showProductsLoading];
}

- (void)setupCustomerInfoSection {
    UIView *container = [self createSectionContainer];

    UIStackView *vStack = [[UIStackView alloc] init];
    vStack.axis = UILayoutConstraintAxisVertical;
    vStack.spacing = 12;
    vStack.translatesAutoresizingMaskIntoConstraints = NO;

    self.customerInfoSectionLabel = [[UILabel alloc] init];
    self.customerInfoSectionLabel.text = @"Customer Information";
    self.customerInfoSectionLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    self.customerInfoSectionLabel.textColor = [UIColor labelColor];
    [vStack addArrangedSubview:self.customerInfoSectionLabel];

    self.customerInfoStack = [[UIStackView alloc] init];
    self.customerInfoStack.axis = UILayoutConstraintAxisVertical;
    self.customerInfoStack.spacing = 8;
    [vStack addArrangedSubview:self.customerInfoStack];

    [container addSubview:vStack];
    [NSLayoutConstraint activateConstraints:@[
        [vStack.topAnchor constraintEqualToAnchor:container.topAnchor constant:20],
        [vStack.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:20],
        [vStack.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-20],
        [vStack.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-20]
    ]];

    [self.mainStack addArrangedSubview:container];

    [self updateCustomerInfoUI];
}

#pragma mark - Notifications

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sdkInitialized)
                                                 name:kMonetaiSDKInitializedNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sdkInitializationFailed:)
                                                 name:kMonetaiSDKInitializationFailedNotification
                                               object:nil];
}

- (void)sdkInitialized {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.statusCheckTimer invalidate];
        self.statusCheckTimer = nil;
        self.isInitialized = YES;
        [self updateSDKStatus];
        [self loadProducts];
        [self loadCustomerInfo];
    });
}

- (void)sdkInitializationFailed:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isInitialized = NO;
        [self updateSDKStatus];
        NSError *error = notification.object;
        if (error) {
            self.errorLabel.text = [NSString stringWithFormat:@"Initialization failed: %@", error.localizedDescription];
            self.errorLabel.hidden = NO;
        }
    });
}

#pragma mark - SDK Status

- (void)startSDKStatusCheck {
    [self updateSDKStatus];
    self.statusCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             target:self
                                                           selector:@selector(checkSDKStatus)
                                                           userInfo:nil
                                                            repeats:YES];
}

- (void)checkSDKStatus {
    if (self.isInitialized) {
        [self.statusCheckTimer invalidate];
        self.statusCheckTimer = nil;
        return;
    }
    BOOL initialized = [[MonetaiSDK shared] getInitialized];
    if (initialized) {
        self.isInitialized = YES;
        [self updateSDKStatus];
        [self loadProducts];
        [self loadCustomerInfo];
        [self.statusCheckTimer invalidate];
        self.statusCheckTimer = nil;
    }
}

- (void)updateSDKStatus {
    self.statusLabel.text = self.isInitialized ? @"Connected" : @"Connecting...";
    self.statusLabel.textColor = self.isInitialized ? [UIColor systemBlueColor] : [UIColor systemRedColor];
    self.getOfferButton.enabled = self.isInitialized;
    self.getOfferButton.alpha = self.isInitialized ? 1.0 : 0.5;
}

#pragma mark - RevenueCat

- (void)loadProducts {
    [[RCPurchases sharedPurchases] getOfferingsWithCompletion:^(RCOfferings * _Nullable offerings, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Failed to load products: %@", error.localizedDescription);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (offerings.current) {
                self.packages = offerings.current.availablePackages;
            } else {
                NSMutableArray *allPackages = [NSMutableArray array];
                for (RCOffering *offering in offerings.all.allValues) {
                    [allPackages addObjectsFromArray:offering.availablePackages];
                }
                self.packages = [allPackages copy];
            }
            [self updateProductsUI];
        });
    }];
}

- (void)loadCustomerInfo {
    [[RCPurchases sharedPurchases] getCustomerInfoWithCompletion:^(RCCustomerInfo * _Nullable customerInfo, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Failed to load customer info: %@", error.localizedDescription);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.customerInfo = customerInfo;
            [self updateSubscriberStatus];
            [self updateCustomerInfoUI];
        });
    }];
}

- (void)purchasePackage:(RCPackage *)package {
    [[RCPurchases sharedPurchases] purchasePackage:package withCompletion:^(RCStoreTransaction * _Nullable transaction, RCCustomerInfo * _Nullable customerInfo, NSError * _Nullable error, BOOL userCancelled) {
        if (userCancelled) return;
        if (error) {
            NSLog(@"Purchase failed: %@", error.localizedDescription);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.customerInfo = customerInfo;
            [self updateSubscriberStatus];
            [self updateCustomerInfoUI];
        });

        [[MonetaiSDK shared] logEventWithEventName:@"purchase_completed" params:@{
            @"product_id": package.storeProduct.productIdentifier,
            @"price": package.storeProduct.price,
            @"currency": package.storeProduct.currencyCode ?: @"USD"
        }];
    }];
}

#pragma mark - Get Offer

- (void)getOfferButtonTapped {
    self.isLoading = YES;
    self.getOfferButton.enabled = NO;
    [self.loadingIndicator startAnimating];

    [[MonetaiSDK shared] getOfferWithPlacement:kPlacement completion:^(Offer * _Nullable offer, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = NO;
            self.getOfferButton.enabled = YES;
            [self.loadingIndicator stopAnimating];

            if (error) {
                self.errorLabel.text = [NSString stringWithFormat:@"Get offer failed: %@", error.localizedDescription];
                self.errorLabel.hidden = NO;
                return;
            }

            self.offer = offer;
            [self updateOfferUI];
            [self updateProductsUI];

            // Log viewProductItem for offer products
            if (offer) {
                [self logViewProductItemsForOffer:offer];
            }
        });
    }];
}

- (void)logViewProductItemsForOffer:(Offer *)offer {
    RCPackage *basePackage = [self basePackage];
    if (!basePackage) return;

    for (OfferProduct *offerProduct in offer.products) {
        RCPackage *pkg = nil;
        for (RCPackage *p in self.packages) {
            if ([p.storeProduct.productIdentifier isEqualToString:offerProduct.sku]) {
                pkg = p;
                break;
            }
        }
        if (!pkg) continue;

        NSNumber *month = nil;
        if (pkg.storeProduct.subscriptionPeriod != nil &&
            pkg.storeProduct.subscriptionPeriod.unit == RCSubscriptionPeriodUnitYear) {
            month = @12;
        }

        ViewProductItemParams *params = [[ViewProductItemParams alloc]
            initWithPlacement:kPlacement
                    productId:pkg.storeProduct.productIdentifier
                        price:pkg.storeProduct.price.doubleValue
                 regularPrice:basePackage.storeProduct.price.doubleValue
                 currencyCode:pkg.storeProduct.currencyCode ?: @"USD"
                        month:month];

        [[MonetaiSDK shared] logViewProductItemWithParams:params];
    }
}

#pragma mark - UI Updates

- (void)updateOfferUI {
    if (self.offer) {
        // Agent name (semibold)
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]
            initWithString:[NSString stringWithFormat:@"Agent: %@", self.offer.agentName]
                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold],
                             NSForegroundColorAttributeName: [UIColor colorWithRed:0.18 green:0.49 blue:0.2 alpha:1.0]}];

        // Product lines (caption)
        for (OfferProduct *product in self.offer.products) {
            NSString *line = [NSString stringWithFormat:@"\n%@: %d%% off", product.name, (int)(product.discountRate * 100)];
            [attr appendAttributedString:[[NSAttributedString alloc]
                initWithString:line
                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0.22 green:0.56 blue:0.24 alpha:1.0]}]];
        }

        self.offerResultLabel.attributedText = attr;
        self.offerResultContainer.hidden = NO;
    } else {
        self.offerResultContainer.hidden = YES;
    }
}

- (void)updateSubscriberStatus {
    BOOL isSubscribed = self.customerInfo && self.customerInfo.entitlements.active.count > 0;
    self.subscriberStatusLabel.text = isSubscribed ? @"Subscriber Status: Subscribed" : @"Subscriber Status: Not Subscribed";
}

- (void)showProductsLoading {
    // Clear existing
    for (UIView *subview in self.productsStack.arrangedSubviews) {
        [subview removeFromSuperview];
    }

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    [spinner startAnimating];

    UILabel *loadingLabel = [[UILabel alloc] init];
    loadingLabel.text = @"Loading products...";
    loadingLabel.font = [UIFont systemFontOfSize:12];
    loadingLabel.textColor = [UIColor secondaryLabelColor];
    loadingLabel.textAlignment = NSTextAlignmentCenter;

    UIStackView *loadingStack = [[UIStackView alloc] initWithArrangedSubviews:@[spinner, loadingLabel]];
    loadingStack.axis = UILayoutConstraintAxisVertical;
    loadingStack.spacing = 8;
    loadingStack.alignment = UIStackViewAlignmentCenter;

    [self.productsStack addArrangedSubview:loadingStack];
}

- (void)updateProductsUI {
    // Clear existing
    for (UIView *subview in self.productsStack.arrangedSubviews) {
        [subview removeFromSuperview];
    }

    NSArray<RCPackage *> *displayedPackages = [self displayedPackages];
    if (displayedPackages.count == 0) {
        [self showProductsLoading];
        return;
    }

    for (RCPackage *package in displayedPackages) {
        OfferProduct *offerProduct = nil;
        if (self.offer) {
            for (OfferProduct *op in self.offer.products) {
                if ([op.sku isEqualToString:package.storeProduct.productIdentifier]) {
                    offerProduct = op;
                    break;
                }
            }
        }
        UIView *row = [self createProductRowForPackage:package offerProduct:offerProduct];
        [self.productsStack addArrangedSubview:row];
    }
}

- (void)updateCustomerInfoUI {
    // Clear existing
    for (UIView *subview in self.customerInfoStack.arrangedSubviews) {
        [subview removeFromSuperview];
    }

    if (self.customerInfo && self.customerInfo.entitlements.active.count > 0) {
        UILabel *activeLabel = [[UILabel alloc] init];
        activeLabel.text = @"Active Entitlements";
        activeLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        [self.customerInfoStack addArrangedSubview:activeLabel];

        for (NSString *key in self.customerInfo.entitlements.active) {
            RCEntitlementInfo *entitlement = self.customerInfo.entitlements.active[key];
            UIView *row = [self createEntitlementRowForKey:key entitlement:entitlement];
            [self.customerInfoStack addArrangedSubview:row];
        }
    } else {
        UILabel *noSubLabel = [[UILabel alloc] init];
        noSubLabel.text = @"No active subscriptions found";
        noSubLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        noSubLabel.textColor = [UIColor secondaryLabelColor];
        noSubLabel.textAlignment = NSTextAlignmentCenter;
        [self.customerInfoStack addArrangedSubview:noSubLabel];

        UILabel *hintLabel = [[UILabel alloc] init];
        hintLabel.text = @"Purchase a product to see your subscription details here";
        hintLabel.font = [UIFont systemFontOfSize:12];
        hintLabel.textColor = [UIColor secondaryLabelColor];
        hintLabel.textAlignment = NSTextAlignmentCenter;
        hintLabel.numberOfLines = 0;
        [self.customerInfoStack addArrangedSubview:hintLabel];
    }
}

#pragma mark - Product Row

- (UIView *)createProductRowForPackage:(RCPackage *)package offerProduct:(OfferProduct * _Nullable)offerProduct {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor systemBackgroundColor];
    card.layer.cornerRadius = 12;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOpacity = 0.05;
    card.layer.shadowRadius = 3;
    card.layer.shadowOffset = CGSizeMake(0, 2);

    // Product info
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = package.storeProduct.localizedTitle;
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];

    UIStackView *priceStack = [[UIStackView alloc] init];
    priceStack.axis = UILayoutConstraintAxisHorizontal;
    priceStack.spacing = 8;

    if (offerProduct) {
        RCPackage *basePackage = [self basePackage];

        // Strikethrough original price
        if (basePackage) {
            UILabel *originalPriceLabel = [[UILabel alloc] init];
            NSMutableAttributedString *strikethrough = [[NSMutableAttributedString alloc] initWithString:basePackage.localizedPriceString
                                                                                             attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle),
                                                                                                          NSForegroundColorAttributeName: [UIColor grayColor],
                                                                                                          NSFontAttributeName: [UIFont systemFontOfSize:12]}];
            originalPriceLabel.attributedText = strikethrough;
            [priceStack addArrangedSubview:originalPriceLabel];
        }

        // Discounted price
        UILabel *discountPriceLabel = [[UILabel alloc] init];
        discountPriceLabel.text = package.localizedPriceString;
        discountPriceLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        discountPriceLabel.textColor = [UIColor systemRedColor];
        [priceStack addArrangedSubview:discountPriceLabel];

        // Discount badge - use a container view for padding
        UIView *badgeContainer = [[UIView alloc] init];
        badgeContainer.backgroundColor = [[UIColor systemRedColor] colorWithAlphaComponent:0.1];
        badgeContainer.layer.cornerRadius = 4;
        badgeContainer.layer.masksToBounds = YES;

        UILabel *badgeLabel = [[UILabel alloc] init];
        badgeLabel.text = [NSString stringWithFormat:@"-%d%%", (int)(offerProduct.discountRate * 100)];
        badgeLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold];
        badgeLabel.textColor = [UIColor systemRedColor];
        badgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [badgeContainer addSubview:badgeLabel];
        [NSLayoutConstraint activateConstraints:@[
            [badgeLabel.topAnchor constraintEqualToAnchor:badgeContainer.topAnchor constant:2],
            [badgeLabel.bottomAnchor constraintEqualToAnchor:badgeContainer.bottomAnchor constant:-2],
            [badgeLabel.leadingAnchor constraintEqualToAnchor:badgeContainer.leadingAnchor constant:6],
            [badgeLabel.trailingAnchor constraintEqualToAnchor:badgeContainer.trailingAnchor constant:-6]
        ]];

        [badgeContainer setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [badgeContainer setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [priceStack addArrangedSubview:badgeContainer];
    } else {
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.text = package.localizedPriceString;
        priceLabel.font = [UIFont systemFontOfSize:12];
        priceLabel.textColor = [UIColor secondaryLabelColor];
        [priceStack addArrangedSubview:priceLabel];
    }

    UIStackView *infoStack = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, priceStack]];
    infoStack.axis = UILayoutConstraintAxisVertical;
    infoStack.spacing = 6;

    // Buy button
    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
    buyButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    buyButton.backgroundColor = [UIColor systemBlueColor];
    [buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buyButton.layer.cornerRadius = 8;
    [buyButton.widthAnchor constraintEqualToConstant:60].active = YES;
    [buyButton.heightAnchor constraintEqualToConstant:32].active = YES;

    // Store package reference for button action
    objc_setAssociatedObject(buyButton, "package", package, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *hStack = [[UIStackView alloc] initWithArrangedSubviews:@[infoStack, buyButton]];
    hStack.axis = UILayoutConstraintAxisHorizontal;
    hStack.alignment = UIStackViewAlignmentCenter;
    hStack.spacing = 12;
    hStack.translatesAutoresizingMaskIntoConstraints = NO;

    [card addSubview:hStack];
    [NSLayoutConstraint activateConstraints:@[
        [hStack.topAnchor constraintEqualToAnchor:card.topAnchor constant:16],
        [hStack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [hStack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
        [hStack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-16]
    ]];

    return card;
}

- (void)buyButtonTapped:(UIButton *)sender {
    RCPackage *package = objc_getAssociatedObject(sender, "package");
    if (package) {
        [self purchasePackage:package];
    }
}

#pragma mark - Entitlement Row

- (UIView *)createEntitlementRowForKey:(NSString *)key entitlement:(RCEntitlementInfo *)entitlement {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor systemGray6Color];
    card.layer.cornerRadius = 8;

    UILabel *keyLabel = [[UILabel alloc] init];
    keyLabel.text = key;
    keyLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    keyLabel.textColor = [UIColor systemBlueColor];
    keyLabel.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.1];
    keyLabel.layer.cornerRadius = 4;
    keyLabel.layer.masksToBounds = YES;
    keyLabel.textAlignment = NSTextAlignmentCenter;

    NSString *expirationText = @"Lifetime";
    if (entitlement.expirationDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        expirationText = [formatter stringFromDate:entitlement.expirationDate];
    }

    UILabel *expirationLabel = [[UILabel alloc] init];
    expirationLabel.text = [NSString stringWithFormat:@"Expiration: %@", expirationText];
    expirationLabel.font = [UIFont systemFontOfSize:12];
    expirationLabel.textColor = [UIColor secondaryLabelColor];

    UIStackView *vStack = [[UIStackView alloc] initWithArrangedSubviews:@[keyLabel, expirationLabel]];
    vStack.axis = UILayoutConstraintAxisVertical;
    vStack.spacing = 4;
    vStack.alignment = UIStackViewAlignmentLeading;
    vStack.translatesAutoresizingMaskIntoConstraints = NO;

    [card addSubview:vStack];
    [NSLayoutConstraint activateConstraints:@[
        [vStack.topAnchor constraintEqualToAnchor:card.topAnchor constant:12],
        [vStack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:12],
        [vStack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-12],
        [vStack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-12]
    ]];

    return card;
}

#pragma mark - Helpers

- (RCPackage * _Nullable)basePackage {
    for (RCPackage *p in self.packages) {
        if ([p.storeProduct.productIdentifier isEqualToString:kDefaultProductId]) {
            return p;
        }
    }
    return nil;
}

- (NSSet<NSString *> *)offerSkuSet {
    if (!self.offer) return [NSSet set];
    NSMutableSet *set = [NSMutableSet set];
    for (OfferProduct *p in self.offer.products) {
        [set addObject:p.sku];
    }
    return [set copy];
}

- (NSArray<RCPackage *> *)displayedPackages {
    RCPackage *base = [self basePackage];
    if (!base) return @[];
    if (!self.offer) return @[base];

    NSSet<NSString *> *skus = [self offerSkuSet];
    NSMutableArray *result = [NSMutableArray arrayWithObject:base];
    for (RCPackage *p in self.packages) {
        if ([skus containsObject:p.storeProduct.productIdentifier] &&
            ![p.storeProduct.productIdentifier isEqualToString:kDefaultProductId]) {
            [result addObject:p];
        }
    }
    return [result copy];
}

- (UIView *)createSectionContainer {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor systemBackgroundColor];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

- (void)addSeparatorToView:(UIView *)view {
    UIView *separator = [[UIView alloc] init];
    separator.backgroundColor = [UIColor systemGray5Color];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:separator];
    [NSLayoutConstraint activateConstraints:@[
        [separator.heightAnchor constraintEqualToConstant:1],
        [separator.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [separator.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
        [separator.bottomAnchor constraintEqualToAnchor:view.bottomAnchor]
    ]];
}

@end
