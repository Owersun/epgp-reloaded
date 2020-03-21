local EPGPR = EPGPR

EPGPR.Messages = {
    ENCOUNTERWON = 1,
    ITEMDISTRIBUTED = 2,
}

-- When a message is received
function EPGPR:OnCommReceived(prefix, message, channel, sender)
    if sender == UnitName("player") then return end -- ignore messages from yourself
    local result, payload = self:Deserialize(message)
    if result then
        self:Print(prefix, payload[1], channel, sender)
    end
end

-- Send message to through the channel
function EPGPR:CommSend(message, payload, channel)
    self:SendCommMessage(self.Const.CommunicationPrefix, self:Serialize({message, payload}), channel)
end
