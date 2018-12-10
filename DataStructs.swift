
import Foundation

struct structConcertDetails
{
    var id:Int                              = 0
    var sConcertName:String                 = ""
    var sConcertOrganiserName:String        = ""
    var sConcertVenue:String                = ""
    var sPlaylistName:String                = ""
    var sPlaylistCreatedBy:String           = ""
    var isUserVerified:Int                  = Const.USER_UNVERIFIED
    var SongList:[structSongDetails]        = Array<structSongDetails>()
    var status:Int                          = Const.CONCERT_ACTIVE
}

struct structSongDetails
{
    var id:Int                              = 0
    var sSongsName:String                   = ""
    var sSongArtist:String                  = ""
    var checkValue:Int                      = 0
    var nMatchesFound:Int                   = 0
    var nTotalReqFound:Int                  = 0
    var nKilledStatus:Int                   = 0
    var nRequestedStatus:Int                = Const.NOT_REQUESTED
    var nConsertID:Int                      = 0
}

struct structChatMsgGroup
{
    var id:Int                              = 0
    var name:String                         = ""
    var lastMsg:String                      = ""
    var userList:[structChatMsgUser]        = Array<structChatMsgUser>()
    var userCount:Int                       = 0
    var date:String                         = ""
    var newMsgFlag:Int                      = 0
    var type:Int                            = 0
    var lastMsgID:Int                       = 0
    var imgPath:String                      = ""
    var badgeCount:Int                      = 0
    var status:Int                          = Const.ACTIVE
}

struct structChatMsg
{
    var id:Int                              = 0
    var text:String                         = ""
    var user:structChatMsgUser               = structChatMsgUser()
    var date:String                         = ""
    var type:Int                            = Const.OTHER_MSG
    var groupID:Int                         = 0
    var readUnread:Int                      = 0
    //var msgUsrType:Int                      = Const.GUEST_USER
}

struct structChatMsgUser
{
    var id:Int                              = 0
    var name:String                         = ""
    var imgPath:String                      = ""
    var fbProfUrl:String                    = ""
    var status:Int                          = Const.INACTIVE
}

struct structConcert
{
    var id:Int                              = 0
    var name:String                         = ""
}

struct structNotification
{
    var id:Int = 0
    var type:Int = Const.NOTIF_MATCH_FOUND
    var idUser:Int = 0
    var message:String = ""
    var other:String = ""   
    var groupId:Int = 0                     // usedOnly for chat msg
    var messageId:Int = 0                   // usedOnly for chat msg
    var messageType:Int = Const.OTHER_MSG   // usedOnly for chat msg
    var date:String = ""
    var status:Int = Const.UNREAD
}