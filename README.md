SJCOverlayViewController
========================

A UIViewController subclass which display full screen with transparency. All the necessary behaviour is encapsulated, so all you need to do is subclass it, set its root view's background colour to something transparent, and then present it as normal.

The appearance and disappearance animations can be replaced by subclassing SJCAnimatedTransitioning and overriding the view controller's -animatedTransitioningClass method to return the class of your subclass. An example subclass which fakes iOS-like blurring is included, and the example Xcode project shows how easily it can be used.



