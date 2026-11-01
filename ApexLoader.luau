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
    [6839171747] = {
    Name = "DOORS",     
    Url = "https://raw.githubusercontent.com/panchito-beep1/CodeHosting/refs/heads/main/DoorsApex.luau"
  },
    [5865858426] = {
    Name = "Retail Tycoon 2",     
    Url = "https://raw.githubusercontent.com/panchito-beep1/CodeHosting/refs/heads/main/APEXRetailTycoon2"
  },
    [9772878203] = {
    Name = "raise a floppa 2",     
    Url = "https://raw.githubusercontent.com/panchito-beep1/CodeHosting/refs/heads/main/ApexRaiseAFlopp.luau"
  },
    [140317247681516] = {
    Name = "Jump Clicker",     
    Url = "https://raw.githubusercontent.com/panchito-beep1/CodeHosting/refs/heads/main/APEXJumpClicker.luau"
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

----------------===================|for readers|===================----------------
-- please for the love of god make sure your restaurant is loaded for the Restaurant Tycoon 2 script to work... I even added a check to tell if your restaurant is loaded; please don't make that mistake
--
--APEX v2.3 FULLY keyless.
