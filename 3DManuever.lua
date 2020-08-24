local player = game:GetService("Players").LocalPlayer
local serverstorage = game:GetService("ServerStorage")
local runservice = game:GetService("RunService")
local userinputservice = game:GetService("UserInputService")

local mouse = player:GetMouse()

local function checktype(argument)
	return typeof(argument)
end

local grapple = {
	
	_configuration = {
		
		_dotangle = 75;
			
	};
	
	_debounces = {};
	_connections = {};
	_isGrappling = false

	
} do
	
	-- Adding a proxy fpr private access
	
	function grapple.ChangeProxy(self, tab1)
		local external = newproxy(true)
		local meta = getmetatable(external)
		
		meta.__index = tab1
		meta.__call = function(external, paramater)
			
			if paramater then
				assert(typeof(paramater) == "table", "must be a table!")
			end
			
			paramater = paramater or {}
			
			local success, res = pcall(function()
				for index, value in ipairs(paramater) do
					local customindex
					
					if paramater[index] and typeof(paramater[index] ~= "function" or "RBXScriptSignal") then
						customindex = paramater[index]
					end					
				end				
			end)
		end
		
		return external
		
	end
	
	function grapple:checksignals(connection)
		local self = grapple
		connection = connection or "FALSE"
		
		if #self._connections == 0 then
					
			if connection ~= nil then
				table.insert(self._connections, connection)
			else
				for _, signal in next, self._connections do
						
					if typeof(signal) == "RBXScriptConnection" then
						signal:Disconnect()
					elseif connection == "FALSE" then
						table.remove(self._connections, signal)
					end
				end
			end
		end
	end
	
	-- After player finishes grappling, it will take awhile till they can use it again!
	
	function grapple:AddDebounces(player)
		if not self._debounces then
			self._debounces = {}
		end
		
		self._debounces[player] = {}
		
		return function()
			
			repeat runservice.Hearbeat:Wait() until self._debounces[player]
			
			self._debounces[player].boolean = true
			self._debounces[player].interval = 0
		end
	end
	
	-- Validates whether or not the player can grapple!
	
	function grapple:CheckDistance()
		local target
		
		target = mouse.Hit.p
	end
	
	-- Activates the grapple!
	
	function grapple:Activate(hitposition, connectionFPS)
		
		assert(typeof(hitposition) == "Vector3", "position must be 3D")
		assert(self._isGrappling == false, "player cannot be grappling to activate!")
		
		if self._debounces[player].boolearn == false then return end
		if connectionFPS > 60 then warn("Maximum FPS should be 60!") end
		
		local target = hitposition
			
		local part = Instance.new("Part") do
			
			part.Name = "OK"
			part.Color = Color3.fromRGB(0, 0, 0)
			part.Material = Enum["Material"].SmoothPlastic
			part.Anchored = true
			part.CanCollide = false
			
			if not self._garbage then
				
				self._garbage = {} do
					self._garbage[player] = {} do
					
						if checktype(part) == "Instance" then
							table.insert(self._garbage[player], part)
						end	
					end
				end
			end
			
			local updatespeed = 1 / connectionFPS
			
			local counter = 0
			
			local connection do
				
				local _backupTimer = os.time()
				
				connection = runservice.Heartbeat:Connect(function(deltaTime)
					if os.time() - _backupTimer >= 30 then
						
						grapple.checksignals(connection)
						
						delay(2, function()
							player:Kick("Sorry, you have been kicked for hacking!")
						end)
						
					elseif counter + deltaTime >= updatespeed then
						
						part.CFrame = CFrame.new(player.Character:WaitForChild("HumanoidRootPart").CFrame.p, hitposition)
						counter = 0
						
						if self._isGrappling == false then
							grapple.checksignals(connection)
						end
					else
						counter += deltaTime
					end
				end)
			end
			
			while connection == nil do
				runservice.Heartbeat:Wait()
				
				self._debounces[player].boolean = true
				if self._debounces[player].boolean == true then
					break
				end
			end
		end
	end
end

-- Prevents memomry leaks when player leaves!

local playerconnection
playerconnection = player.AncestryChanged:Connect(function()
	local self = grapple
	
	if player:IsDescendantOf(game) then return end
	playerconnection:Disconnect()
	
	return delay(2, function()
		if self[player]._garbage then
			
			for _, garbage in ipairs(self[player]._garbage) do
				if typeof(garbage) == "Instance" then
					garbage:Destroy()
				else
					warn("Garbage hasn't been collected!")
				end
			end
			
			if #self._connections > 0 then
				
				for _, connection in ipairs(self._connections) do
					if typeof(connection) == "RBXScriptConnection" then
						connection:Disconnect()
					end
				end
			end
		end
	end)
end)

return grapple
