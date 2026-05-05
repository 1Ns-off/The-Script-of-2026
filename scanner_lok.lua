--scanner v1

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function scanRemotes(parent, indent)
    indent = indent or ""
    for _, obj in ipairs(parent:GetChildren()) do
        if obj:IsA("RemoteEvent") then
            print(indent .. "[RemoteEvent] " .. obj:GetFullName())
        elseif obj:IsA("RemoteFunction") then
            print(indent .. "[RemoteFunction] " .. obj:GetFullName())
        elseif obj:IsA("Folder") or obj:IsA("Model") then
            print(indent .. "[Folder] " .. obj.Name)
            scanRemotes(obj, indent .. "  ")
        end
    end
end

print("=== Remote Scanner ===")
scanRemotes(ReplicatedStorage)
print("=== Done ===")