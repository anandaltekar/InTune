
import Foundation

class DisplayListOfConcerts: NSObject, NSXMLParserDelegate, _IFaceAPI {
    var methodName: String = "DisplayListOfConcerts"
    var pageTarget: _IFaceCallTarget?
    var soapEnv: String = ""
    var respCode: Int = 10
    var showList:[structConcertDetails] = Array<structConcertDetails>()
    
    func request(params:[String])
    {
        self.soapEnv = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><DisplayListOfConcerts xmlns='http://tempuri.org/'><suidSession>\(params[0])</suidSession></DisplayListOfConcerts></soap:Body></soap:Envelope>"
    }
    
    func response(response responseData: NSMutableData)
    {
        do {
            let xmlDoc = try AEXMLDocument(xmlData: responseData)
            respCode=Int(xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_jResponseCode"].value!)!
            
            let dictData:AEXMLElement = xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_objResponse"]["_ConcertInfo"]

            for var index:Int = 0; index < dictData.children.count; ++index {
                let item:AEXMLElement = dictData.children[index]
                var showStrct:structConcertDetails = structConcertDetails()
                showStrct.id = Utility.suidToInt(item["suidConcert"].value!)
                showStrct.sConcertName = item["sConcertName"].value!
                showStrct.sConcertVenue = item["sConcertVenue"].value!
                showStrct.sConcertOrganiserName = item["sConcertOrganiserName"].value!
                showStrct.status = Int(item["nConcertStatus"].value!)!
                showStrct.isUserVerified = Int(item["isUserAlreadyVerified"].value!)!
                self.showList.append(showStrct)
            }
            pageTarget?.serviceResponse(self)
        } catch _ {
        }
    }

}