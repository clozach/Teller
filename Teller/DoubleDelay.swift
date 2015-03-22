import Foundation

extension Double {
   public func secondsFromNowDo( action: () -> () ) {
      let delayInSeconds = self
      let popTime = dispatch_time(DISPATCH_TIME_NOW,
         Int64(delayInSeconds * Double(NSEC_PER_SEC))
      )
      dispatch_after(popTime, dispatch_get_main_queue()) {
         action()
      }
   }
}