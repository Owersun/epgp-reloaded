local EPGPR, UnitName = EPGPR, UnitName

-- When a message is received, try to call the method with arguments
function EPGPR:OnCommReceived(prefix, message, _, sender)
    if sender == UnitName("player") or prefix ~= self.Const.CommunicationPrefix then return end -- ignore messages not from the app or from yourself
    local result, method, arguments = self:Deserialize(message)
    if result then pcall(self[method], self, unpack(arguments)) end
end

-- Effectively this is RPC to apps that other guild members run. It's going to call the method on self with given arguments
function EPGPR:Broadcast(method, arguments)
    self:SendCommMessage(self.Const.CommunicationPrefix, self:Serialize(method, arguments), "GUILD")
end
