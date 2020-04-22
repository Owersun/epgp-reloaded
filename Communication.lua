local EPGPR, UnitName = EPGPR, UnitName

-- this is a "safe-list" of functions exposed to be externally called.
-- they are proxied through this table, to prevent exploits that can be possible if everything is exposed for RPC
local communitaction = {
    SaveHistoryRow = function(...) EPGPR:SaveHistoryRow(...) end,
    Print = function(...) EPGPR:Print(...) end
}

-- local wrapper function, required for proper vararg handling of deserialization result
local function remoteProcedureCall(result, method, ...)
    if result then pcall(communitaction[method], ...) end
end

-- When a message is received, deserialize it and pass to the wrapper function
function EPGPR:OnCommReceived(prefix, message, _, sender)
    if sender == UnitName("player") or prefix ~= self.Const.CommunicationPrefix then return end -- ignore messages not from the app or from yourself
    remoteProcedureCall(self:Deserialize(message))
end

-- Effectively this is RPC to apps that other guild members run. It's going to call the method on self with given arguments
function EPGPR:Broadcast(method, ...)
    self:SendCommMessage(self.Const.CommunicationPrefix, self:Serialize(method, ...), "GUILD")
end
