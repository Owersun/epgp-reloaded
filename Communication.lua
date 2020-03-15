local EPGPR = EPGPR

-- When a message is received
function EPGPR:OnCommReceived(payload)
    local message = self:Deserialize(payload)
    self:Print(message.type)
end

-- Send message to through the channel
function EPGPR:CommSend(payload, channel)
    self:SendCommMessage(self.const.CommunicationPrefix, self:Serialaze(payload), channel)
end
