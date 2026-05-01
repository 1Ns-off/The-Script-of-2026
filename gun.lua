-- Gun Visual Loader v7 - Pistola Spooky (único asset) + weld + InsertService
-- Asset: https://create.roblox.com/store/asset/126688557258516/Spookys-Pistol-Sidearm-Model-Gun-Silent-Reload
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")

local player = Players.LocalPlayer

local GUN_ASSET_ID = 126688557258516

-- Remove GUI antiga do seletor (v6), se ainda existir
task.defer(function()
	local pg = player:WaitForChild("PlayerGui", 60)
	if pg then
		local old = pg:FindFirstChild("GunPickerGui")
		if old then
			old:Distrid
		end
	end
end)

local character = nil
local humanoidRootPart = nil
local humanoid = nil
local humanoidDiedConn = nil

local gunModel = nil
local gunWeld = nil
local isEquipped = false

local ATTACH_CFRAME = CFrame.new(0, -0.3, -1.2) * CFrame.Angles(0, math.rad(180), 0)

-- ============================================
-- Estado equipado
-- ============================================
local function clearEquippedState(destroyModel)
	if gunWeld then
		if gunWeld.Parent then
			gunWeld:Destroy()
		end
		gunWeld = nil
	end
	if destroyModel and gunModel and gunModel.Parent then
		gunModel:Destroy()
	end
	gunModel = nil
	isEquipped = false
end

local function findPrimaryPart(model)
	if model.PrimaryPart then
		return model.PrimaryPart
	end

	local commonNames = { "Handle", "Body", "Main", "Gun", "Receiver", "Base", "Root" }
	for _, name in ipairs(commonNames) do
		local found = model:FindFirstChild(name, true)
		if found and found:IsA("BasePart") then
			print("[GUN] PrimaryPart por nome: " .. name)
			model.PrimaryPart = found
			return found
		end
	end

	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then
			print("[GUN] PrimaryPart automática: " .. desc.Name)
			model.PrimaryPart = desc
			return desc
		end
	end

	return nil
end

local function prepareVisualParts(model)
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then
			desc.CanCollide = false
			desc.Massless = true
			desc.Anchored = false
		end
	end
end

local function getRightHand(char)
	return char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
end

-- ============================================
-- Carregar modelo
-- ============================================
local function loadGun()
	print("[GUN] Carregando ID: " .. tostring(GUN_ASSET_ID))

	local success, container = pcall(function()
		return InsertService:LoadAsset(GUN_ASSET_ID)
	end)

	if not success or not container then
		print("[GUN] Erro LoadAsset: " .. tostring(container))
		return nil
	end

	local source = nil
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("Model") then
			source = child
			break
		end
	end
	if not source then
		source = container:GetChildren()[1]
	end
	if not source then
		print("[GUN] Asset sem conteúdo utilizável")
		container:Destroy()
		return nil
	end

	local clone = source:Clone()
	container:Destroy()

	for _, desc in ipairs(clone:GetDescendants()) do
		if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
			desc:Destroy()
		end
	end

	local primaryPart = findPrimaryPart(clone)
	if primaryPart then
		print("[GUN] PrimaryPart: " .. primaryPart.Name)
	else
		print("[GUN] Modelo sem BasePart válida")
		clone:Destroy()
		return nil
	end

	prepareVisualParts(clone)
	return clone
end

-- ============================================
-- Equipar / desquipar
-- ============================================
local function unequipGun()
	if not isEquipped and not gunModel and not gunWeld then
		return
	end
	clearEquippedState(true)
	print("[GUN] Removida!")
end

local function equipGun()
	if isEquipped or not character then
		return
	end
	if not humanoidRootPart or not humanoidRootPart.Parent then
		return
	end

	gunModel = loadGun()
	if not gunModel then
		return
	end

	local primaryPart = gunModel.PrimaryPart
	if not primaryPart then
		clearEquippedState(true)
		return
	end

	local hand = getRightHand(character)
	gunModel.Parent = character

	if hand then
		gunModel:SetPrimaryPartCFrame(hand.CFrame * ATTACH_CFRAME)
		print("[GUN] Anexado à: " .. hand.Name)
	else
		gunModel:SetPrimaryPartCFrame(humanoidRootPart.CFrame * CFrame.new(1.5, 0, -1))
	end

	local attachPart = hand or humanoidRootPart
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = attachPart
	weld.Part1 = primaryPart
	weld.Parent = primaryPart
	gunWeld = weld

	isEquipped = true
	print("[GUN] Equipada (Pistola Spooky)")

	gunModel.Destroying:Once(function()
		gunWeld = nil
		gunModel = nil
		isEquipped = false
	end)
end

-- ============================================
-- Personagem
-- ============================================
local function onCharacterAdded(newCharacter)
	clearEquippedState(true)

	if humanoidDiedConn then
		humanoidDiedConn:Disconnect()
		humanoidDiedConn = nil
	end

	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	humanoidDiedConn = humanoid.Died:Connect(unequipGun)
end

if player.Character then
	onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- ============================================
-- Input G
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.G then
		if isEquipped then
			unequipGun()
		else
			equipGun()
		end
	end
end)

print("[GUN] Pistola Spooky — pressione G para equipar / remover.")
