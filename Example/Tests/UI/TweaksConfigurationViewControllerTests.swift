
import XCTest
@testable import JustTweak

class ConfigurationViewControllerTests: XCTestCase {
    
    var viewController: TweaksConfigurationViewController!
    
    override func setUp() {
        super.setUp()
        buildViewControllerWithConfigurationFromFileNamed("test_configuration")
    }
    
    override func tearDown() {
        viewController.configurationsCoordinator?.topCustomizableConfiguration()?.deleteValue(forTweakWithIdentifier: "display_yellow_view")
        viewController = nil
        super.tearDown()
    }
    
    // MARK: Generic Data Display
    
    func testDisplaysNoDataIfConfigurationWasNotSet() {
        let viewController = TweaksConfigurationViewController()
        XCTAssertEqual(0, viewController.numberOfSections(in: viewController.tableView))
    }
    
    func testDisplaysCorrectDataIfConfigurationCoordinatorIsSetAfterInitialization() {
        let otherViewController = TweaksConfigurationViewController()
        XCTAssertEqual(0, otherViewController.numberOfSections(in: viewController.tableView))
        otherViewController.configurationsCoordinator = viewController.configurationsCoordinator
        XCTAssertEqual(otherViewController.numberOfSections(in: viewController.tableView),
                       viewController.numberOfSections(in: viewController.tableView))
    }
    
    func testHasExpectedNumberOfSections() {
        XCTAssertEqual(3, viewController.numberOfSections(in: viewController.tableView))
    }
    
    func testHasExpectedNumberOfSectionsWhenNoDisplayableTweakIsUngrouped() {
        buildViewControllerWithConfigurationFromFileNamed("test_configuration_no_displayable_ungrouped")
        XCTAssertEqual(2, viewController.numberOfSections(in: viewController.tableView))
    }
    
    func testUngroupedTweaksAreDisplayedUnderOneSection() {
        XCTAssertEqual(4, viewController.tableView(viewController.tableView, numberOfRowsInSection: 2))
        XCTAssertEqual("UI", viewController.tableView(viewController.tableView, titleForHeaderInSection: 2))
    }
    
    func testGroupedTweaksAreDisplayedInTheirOwnSections() {
        XCTAssertEqual(1, viewController.tableView(viewController.tableView, numberOfRowsInSection: 0))
        XCTAssertEqual("General", viewController.tableView(viewController.tableView, titleForHeaderInSection: 0))
        XCTAssertEqual(1, viewController.tableView(viewController.tableView, numberOfRowsInSection: 1))
        XCTAssertEqual("Other", viewController.tableView(viewController.tableView, titleForHeaderInSection: 1))
    }
    
    // MARK: Convenience Methods
    
    func testReturnsCorrectIndexPathForTweak_WhenTweakFound() {
        let indexPath = viewController.indexPathForTweakWithIdentifier("display_yellow_view")
        let expectedIndexPath = IndexPath(row: 2, section: 2)
        XCTAssertEqual(indexPath, expectedIndexPath)
    }
    
    func testReturnsCorrectIndexPathForTweak_WhenTweakFound_2() {
        let indexPath = viewController.indexPathForTweakWithIdentifier("display_red_view")
        let expectedIndexPath = IndexPath(row: 1, section: 2)
        XCTAssertEqual(indexPath, expectedIndexPath)
    }
    
    // MARK: Tweak Cells Display
    
    func testReturnsCorrectIndexPathForTweak_WhenTweakNotFound() {
        let indexPath = viewController.indexPathForTweakWithIdentifier("some_nonexisting_tweak")
        XCTAssertNil(indexPath)
    }
    
    func testDisplaysTweakOn_IfEnabled() {
        let indexPath = viewController.indexPathForTweakWithIdentifier("display_yellow_view")!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath) as! BooleanTweakTableViewCell
        XCTAssertFalse(cell.switchControl.isOn)
    }
    
    func testDisplaysTweakOff_IfDisabled() {
        let indexPath = viewController.indexPathForTweakWithIdentifier("display_red_view")!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath) as! BooleanTweakTableViewCell
        XCTAssertTrue(cell.switchControl.isOn)
    }
    
    func testDisplaysTweakTitle_ForTweakThatHaveIt() {
        let indexPath = viewController.indexPathForTweakWithIdentifier("display_red_view")!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath)
        XCTAssertEqual(cell.textLabel?.text, "Display Red View")
        XCTAssertEqual((cell as! TweaksConfigurationViewControllerCell).title, "Display Red View")
    }
    
    func testDisplaysTweakIdentifier_ForTweakThatDoNotHaveATitle() {
        let indexPath = viewController.indexPathForTweakWithIdentifier("tap_to_change_color_enabled")!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath)
        XCTAssertEqual(cell.textLabel?.text, "tap_to_change_color_enabled")
        XCTAssertEqual((cell as! TweaksConfigurationViewControllerCell).title, "tap_to_change_color_enabled")
    }
    
    func testDisplaysNumericTweaksCorrectly() {
        let indexPath = viewController.indexPathForTweakWithIdentifier("red_view_alpha_component")!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath) as? NumericTweakTableViewCell
        XCTAssertEqual(cell?.title, "Red View Alpha Component")
        XCTAssertEqual(cell?.textField.text, "1.0")
    }
    
    func testDisplaysTextTweaksCorrectly() {
        let indexPath = viewController.indexPathForTweakWithIdentifier("change_tweaks_button_label_text")!
        let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath)  as? TextTweakTableViewCell
        XCTAssertEqual(cell?.title, "Change Tweaks Button Label Text")
        XCTAssertEqual(cell?.textField.text, "Change Configuration")
    }
    
    // MARK: Cells Actions
    
    func testUpdatesValueOfTweak_WhenUserTooglesSwitchOnBooleanCell() {
        
        viewController.beginAppearanceTransition(true, animated: false)
        viewController.endAppearanceTransition()
        
        let indexPath = viewController.indexPathForTweakWithIdentifier("display_yellow_view")!
        let cell = viewController.tableView.cellForRow(at: indexPath) as! BooleanTweakTableViewCell
        cell.switchControl.isOn = true
        cell.switchControl.sendActions(for: .valueChanged)
        XCTAssertTrue(viewController.configurationsCoordinator!.valueForTweakWith(identifier: "display_yellow_view") as! Bool)
    }
    
    // MARK: No configuration view
    
    func testDoesNotShowMessageWhenPresentedWithConfigurationsCoordinator_Plain() {
        let coordinator = viewController.configurationsCoordinator!
        let vc = TweaksConfigurationViewController(style: .plain, configurationsCoordinator: coordinator)
        let backgroundView = vc.tableView.backgroundView as! TweaksErrorView
        XCTAssertTrue(backgroundView.isHidden)
    }
    
    func testDoesNotShowMessageWhenPresentedWithConfigurationsCoordinator_Grouped() {
        let coordinator = viewController.configurationsCoordinator!
        let vc = TweaksConfigurationViewController(style: .plain, configurationsCoordinator: coordinator)
        let backgroundView = vc.tableView.backgroundView as! TweaksErrorView
        XCTAssertTrue(backgroundView.isHidden)
    }
    
    func testShowsMessageWhenPresentedWithoutConfigurationsCoordinator_Plain() {
        let vc = TweaksConfigurationViewController(style: .plain)
        let backgroundView = vc.tableView.backgroundView as! TweaksErrorView
        XCTAssertEqual(backgroundView.text, "No Mutable Configurations Found")
        XCTAssertFalse(backgroundView.isHidden)
    }
    
    func testShowsMessageWhenPresentedWithoutConfigurationsCoordinator_Grouped() {
        let vc = TweaksConfigurationViewController(style: .grouped)
        let backgroundView = vc.tableView.backgroundView as! TweaksErrorView
        XCTAssertEqual(backgroundView.text, "No Mutable Configurations Found")
        XCTAssertFalse(backgroundView.isHidden)
    }
    
    // MARK: Other Actions
    
    func testHasBarButtonToGetDismissed() {
        let _ = viewController.view // force loading view (iOS 8 compatible)
        let button = viewController.navigationItem.rightBarButtonItem
        XCTAssertEqual(button?.style, .done)
        XCTAssertEqual(button?.target as? NSObject, viewController)
        XCTAssertEqual(button?.action, #selector(viewController.dismissViewController))
    }
    
    func testAsksToBeDismissedWhenDoneButtonIsTapped() {
        class FakeViewController: TweaksConfigurationViewController {
            fileprivate let mockPresentingViewController = MockPresentingViewController()
            override var presentingViewController: UIViewController? {
                get {
                    return mockPresentingViewController
                }
            }
        }
        let vc = FakeViewController()
        vc.dismissViewController()
        XCTAssertTrue(vc.mockPresentingViewController.didCallDismissal)
    }
    
    // MARK: Helpers
    
    private func buildViewControllerWithConfigurationFromFileNamed(_ fileName: String) {
        let bundle = Bundle(for: ConfigurationViewControllerTests.self)
        let jsonURL = bundle.url(forResource: fileName, withExtension: "json")
        let jsonConfiguration = JSONTweaksConfiguration(defaultValuesFromJSONAtURL: jsonURL!)!
        let userDefaults = UserDefaults(suiteName: "com.JustTweaks.Tests\(NSDate.timeIntervalSinceReferenceDate)")
        let userDefaultsConfiguration = UserDefaultsTweaksConfiguration(userDefaults: userDefaults!,
                                                                        fallbackConfiguration: jsonConfiguration)
        let configurations: [TweaksConfiguration] = [jsonConfiguration, userDefaultsConfiguration]
        let configurationsCoordinator = TweaksConfigurationsCoordinator(configurations: configurations)!
        viewController = TweaksConfigurationViewController(style: .plain, configurationsCoordinator: configurationsCoordinator)
    }
    
}
