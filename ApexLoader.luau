--hero there

local games = {
    [137422132461457] = {
    Name = "Guess The Flag",     
    Url = "https://raw.githubusercontent.com/panchito-beep1/CodeHosting/refs/heads/main/GuessTheflagApex.luau"
  },
    [3398014311] = {
    Name = "Restaurant Tycoon 2",     
    Url = "https://raw.githubusercontent.com/panchito-beep1/CodeHosting/refs/heads/main/RestaurantTycoon2Apex.luau"
  },
    [537413528] = {
    Name = "Build A Boat For Treasure",     
    Url = "https://raw.githubusercontent.com/panchito-beep1/CodeHosting/refs/heads/main/BuildABoatApex.luau"
  },
    [6516141723] = {
    Name = "DOORS",     
    Url = "https://raw.githubusercontent.com/panchito-beep1/CodeHosting/refs/heads/main/DoorsApex.luau"
  },
}

local placeId = game.PlaceId
local gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
print("PlaceId:", placeId, "| Game:", gameName)

local entry = games[placeId]

if entry then
    print("Matched:", entry.Name)
    loadstring(game:HttpGet(entry.Url))()
else
    warn("Unsupported game:", gameName, "| PlaceId:", placeId)
end
