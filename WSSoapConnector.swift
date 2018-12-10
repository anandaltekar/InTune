
import Foundation
import UIKit

class WSSoapConnector : NSObject, NSURLConnectionDataDelegate
{
    private var mutableData:NSMutableData = NSMutableData()
    var apiObj:_IFaceAPI?
    
    func callAPI(soapRequest:_IFaceAPI)
    {
        if Reachability.isConnectedToNetwork() == true
        {
            apiObj=soapRequest
            print("######API Call Sending for method name\(apiObj?.methodName)")
            //        var url = NSURL(string : "http://192.168.40.150/intune/service.asmx")
            let url = NSURL(string: Const.serviceURL)
            let theRequest = NSMutableURLRequest(URL:url!)
            let session = NSURLSession.sharedSession()
            //var soapEnvp : String = soapRequest.soapEnv
            let msgLength = String(soapRequest.soapEnv.characters.count)
            theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            theRequest.addValue(msgLength, forHTTPHeaderField: "Content-Length")
            theRequest.HTTPMethod = "POST"
            theRequest.HTTPBody = soapRequest.soapEnv.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
//            let connection = NSURLConnection(request: theRequest, delegate: self, startImmediately: true)
//            connection!.start()
//            if (connection == true)
//            {
//                //var mutableData : Void = NSMutableData.initialize()
//            }
            mutableData.length = 0;
            let task = session.dataTaskWithRequest(theRequest, completionHandler: {data, response, error -> Void in
                self.mutableData.appendData(data!)
                dispatch_async(dispatch_get_main_queue(), {
                    self.apiObj!.response(response: self.mutableData)
                })
                
                //print("Response: \(data)")
            })
            
            task.resume()
        }
        else
        {
            //if coming from song selection enable user interaction
            soapRequest.pageTarget?.serviceResponse(soapRequest)
            //display connection alert
            let alertController = UIAlertController(title: "Oops!", message: "connection is not active, try again later", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Damnit!", style: .Default, handler: {Void in alertController.dismissViewControllerAnimated(false, completion: nil)}
                ))

            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
//    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse)
//    {
//        mutableData.length = 0;
//    }
//    
//    func connection(connection: NSURLConnection, didReceiveData data: NSData)
//    {
//        mutableData.appendData(data)
//    }
//    
//    func connectionDidFinishLoading(connection: NSURLConnection)
//    {
//        apiObj!.response(response: mutableData)
//        print("######API Call received from server for method name\(apiObj?.methodName)")
//    }
    
}
