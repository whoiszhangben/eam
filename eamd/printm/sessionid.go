package printm

import "sync"
import "context"

var sessionId *SessionId

var SessionInfosLock sync.RWMutex
var sessionInfos map[int64]SessionInfo

type SessionId struct {
	SessionLock sync.RWMutex
	SessionId   int64
}

func (this *SessionId) GetSessionId() int64 {
	this.SessionLock.Lock()
	defer this.SessionLock.Unlock()
	this.SessionId = this.SessionId + 1
	return this.SessionId
}

type SessionInfo struct {
	Cancel  context.CancelFunc
	Bresult bool
	Err     string
	Datas   map[string]interface{}
}

func RemoveSessionInfos(sessionid int64) {
	SessionInfosLock.Lock()
	defer SessionInfosLock.Unlock()
	delete(sessionInfos, sessionid)
}

func GetSessionInfos(sessionId int64) *SessionInfo {
	SessionInfosLock.Lock()
	defer SessionInfosLock.Unlock()

	if info, ok := sessionInfos[sessionId]; ok {
		return &info
	}
	return nil
}

func AddSessionInfos(sessionId int64, info SessionInfo) {
	SessionInfosLock.Lock()
	defer SessionInfosLock.Unlock()
	sessionInfos[sessionId] = info
}
