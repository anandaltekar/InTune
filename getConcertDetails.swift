//
//  getConcertDetails.swift
//  in-tune
//
//  Created by Anand Altekar on 28/07/15.
//  Copyright (c) 2015 FDS Infotech Pvt Ltd. All rights reserved.
//

import Foundation

class GetConcertDetails: NSObject, NSXMLParserDelegate, _IFaceAPI
{
    
    var methodName: String = "GetConcertDetails"
    var pageTarget: _IFaceCallTarget?
    var soapEnv: String = ""
    var respCode: Int = 10
    var ConcertDetails:structConcertDetails = structConcertDetails()
    
    func request(params:[String])
    {
        self.soapEnv = "<?xml version='1.0' encoding='utf-8'?> <soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><GetConcertDetails xmlns='http://tempuri.org/'><suidSession>\(params[0])</suidSession><suidConcert>\(params[1])</suidConcert></GetConcertDetails></soap:Body></soap:Envelope>"
        ConcertDetails.id = Utility.suidToInt(params[1])
    }
    
    func response(response responseData: NSMutableData)
    {
        do {
            let xmlDoc = try AEXMLDocument(xmlData: responseData)
            respCode=Int(xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_jResponseCode"].value!)!
            //ConcertDetails = structConcertDetails()
            let dictData:AEXMLElement = xmlDoc.root["soap:Body"]["\(methodName)Response"]["\(methodName)Result"]["_objResponse"]["_structConcertDetails"]
            ConcertDetails.sConcertName = dictData["sConcertName"].value!
            ConcertDetails.sConcertOrganiserName = dictData["sConcertOrganiserName"].value!
            ConcertDetails.sConcertVenue = dictData["sConcertVenue"].value!
            ConcertDetails.sPlaylistCreatedBy = dictData["sPlaylistCreatedBy"].value!
            ConcertDetails.sPlaylistName = dictData["sPlaylistName"].value!
            let songList:AEXMLElement = dictData["aStructSongDetails"]
            for var i:Int = 0; i < songList.children.count; i++
            {
                let songXML:AEXMLElement = songList.children[i]
                var structSong:structSongDetails = structSongDetails()
                structSong.sSongsName       = songXML["sSongsName"].value!
                structSong.id               = Utility.suidToInt(songXML["suidSong"].value!)
                structSong.sSongArtist      = songXML["sSongArtist"].value!
                structSong.nTotalReqFound   = Int(songXML["nTotalReqFound"].value!)!
                structSong.nMatchesFound    = Int(songXML["nMatchesFound"].value!)!
                structSong.nKilledStatus    = Int(songXML["nKilledStatus"].value!)!
                structSong.nRequestedStatus    = Int(songXML["nRequestedStatus"].value!)!
                structSong.nConsertID = ConcertDetails.id
                
                ConcertDetails.SongList.append(structSong)
            }
            DBChats.addSongs(ConcertDetails.SongList)
            pageTarget?.serviceResponse(self)
        } catch _ {
        }
    }
    
}




