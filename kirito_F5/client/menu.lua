ESX = nil



local Rperso = {
    ItemSelected = {},
    ItemSelected2 = {},
    WeaponData = {},
}  
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()

end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:setfaction')
AddEventHandler('esx:setfaction', function(faction)
	ESX.PlayerData.faction = faction
end)


RegisterNetEvent('es:activateMoney')
AddEventHandler('es:activateMoney', function(money)
      ESX.PlayerData.money = money
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
    for i=1, #ESX.PlayerData.accounts, 1 do
        if ESX.PlayerData.accounts[i].name == account.name then
            ESX.PlayerData.accounts[i] = account
        end
    end
end)

local function kPersonalmenuKeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Citizen.Wait(0)
    end
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult() 
        Citizen.Wait(500) 
        blockinput = false
        return result 
    else
        Citizen.Wait(500) 
        blockinput = false 
        return nil 
    end
end

local Personalmenu = RageUI.CreateMenu("~u~NYG", "Interaction") -- Création du menu principale

-- Inventaire
local inventaire = RageUI.CreateSubMenu(Personalmenu, "~u~inventaire","Interaction")
local inventaire2 = RageUI.CreateSubMenu(Personalmenu, "~u~inventaire","Interaction")

-- Portefeuille 
local F5WalletMenu = RageUI.CreateSubMenu(Personalmenu,"~u~Voici votre portefeuille","Interaction")
local F5WalletDrop = RageUI.CreateSubMenu(Personalmenu,"~u~Drop","Interaction")
local F5WalletDropSaleMenu = RageUI.CreateSubMenu(Personalmenu,"Drop Sale","Interaction")
local Billing = RageUI.CreateSubMenu(Personalmenu,"~u~Factures","Interaction")

-- Vetements
local Vetements  = RageUI.CreateSubMenu(Personalmenu, "~u~Vetements","Interaction")

--Vehicules
local Vehicules  = RageUI.CreateSubMenu(Personalmenu, "~u~Vehicules","Interaction")
local limiteur,porte,window = 1,1,1
-- Divers
local Divers  = RageUI.CreateSubMenu(Personalmenu, "~u~Diverss","Interaction")


local F5 = false -- permet de dire si oui ou non le menu est ouvert

Personalmenu.Closed = function() 
    F5 = false 
end 

function Kirito_F5() -- Function qui fait l'entièreté du menu
    if F5 then 
        F5 = false 
            RageUI.Visible(Personalmenu, false) 
        return 
    else 
        F5 = true 
            RageUI.Visible(Personalmenu, true)
            CreateThread(function()
                while F5 do 
                    RageUI.IsVisible(Personalmenu, function()
                        players = {}
				for _, player in ipairs(GetActivePlayers()) do
					local ped = GetPlayerPed(player)
					table.insert( players, player )
				end
				RageUI.Separator('Joueurs en ligne : ~r~'..#players..'~s~/64')
                        RageUI.Separator('Votre Steam : ~b~'..GetPlayerName(PlayerId()))
                        RageUI.Separator('Votre ID : ~b~'..GetPlayerServerId(PlayerId()))
                        RageUI.Button("Inventaire", "Inventaire", {RightLabel = "→→"}, true, {
                            },inventaire)
                        RageUI.Button("Portefeuille", "Portefeuille", {RightLabel = "→→"}, true, {
                            },F5WalletMenu)
                            RageUI.Button("Vetements", "Vetements", {RightLabel = "→→"}, true, {
                            },Vetements)
                            
                            if IsPedSittingInAnyVehicle(PlayerPedId()) then
                                RageUI.Button("Vehicules", nil, {RightLabel = "→→"}, true,{
                                    onSelected = function()
                                    end 
                                },Vehicules)
                            end
                           
                         if Config.Emplacement.Factures == "Main" then
                            RageUI.Button("Factures", "Factures", {RightLabel = "→→"}, true, {
                            onSelected = function()
                                
                            end
                        }, Billing)
                    end


                    
                    
                   
                    RageUI.Button("Divers", "Divers", {RightLabel = "→→"}, true, {}, Divers)                
                end)

                RageUI.IsVisible(inventaire, function()
                    ESX.TriggerServerCallback('kirito:getWeight', function(playerWeight)
                        weight = playerWeight
                    end)
                    RageUI.Separator('~b~↓ Votre Inventaire ↓')
                    RageUI.Separator("~b~Poids : ~r~"..weight..'Kg ~s~/ ~r~'..ESX.PlayerData.maxWeight..'Kg')
                    ESX.PlayerData = ESX.GetPlayerData()
                    for i = 1, #ESX.PlayerData.inventory do
                        if ESX.PlayerData.inventory[i].count > 0 then

                    RageUI.Button('[' ..ESX.PlayerData.inventory[i].count.. '] - ~s~' ..ESX.PlayerData.inventory[i].label, nil, {RightLabel = "→"}, true, {
                        onSelected = function()
                            Rperso.ItemSelected = ESX.PlayerData.inventory[i]
                         
                         end
                    
                
                    },inventaire2)

                end
            end
                    
                end) 
                RageUI.IsVisible(inventaire2,function()
                    RageUI.Button("Utiliser", nil, {RightBadge = RageUI.BadgeStyle.Heart}, true, {
                        onSelected = function()
                         if Rperso.ItemSelected.usable then
                             TriggerServerEvent('esx:useItem', Rperso.ItemSelected.name)
                            else
                                ESX.ShowNotification('l\'items n\'est pas utilisable', Rperso.ItemSelected.label)
                            end
                        end 
                        })
                        
                    
                    RageUI.Button("Jeter", nil, {RightBadge = RageUI.BadgeStyle.Alert}, true, {
                        onSelected = function()
                            if Rperso.ItemSelected.canRemove then
                                local quantity = kPersonalmenuKeyboardInput("Nombres d'items que vous voulez jeter", '', 25)
                                if tonumber(quantity) then
                                    if not IsPedSittingInAnyVehicle(PlayerPedId()) then
                                        TriggerServerEvent('esx:removeInventoryItem', 'item_standard', Rperso.ItemSelected.name, tonumber(quantity))
                                    else
                                        ESX.ShowNotification("Vous ne pouvez pas faire ceci dans un véhicule !")
                                    end
                                else
                                    ESX.ShowNotification("Nombres d'items invalid !")
                                end
                            end
                        end
                            })
                        
                    RageUI.Button("Donner", nil, {RightBadge = RageUI.BadgeStyle.Tick}, true, {
                        onSelected = function()
                            local quantity = kPersonalmenuKeyboardInput("Nombres d'items que vous voulez donner", "", 25)
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                            local pPed = GetPlayerPed(-1)
                            local coords = GetEntityCoords(pPed)
                            local x,y,z = table.unpack(coords)
                            DrawMarker(2, x, y, z+1.5, 0, 0, 0, 180.0,nil,nil, 0.5, 0.5, 0.5, 0, 0, 255, 120, true, true, p19, true)
                            if tonumber(quantity) then
                                if closestDistance ~= -1 and closestDistance <= 3 then
                                    local closestPed = GetPlayerPed(closestPlayer)
        
                                    if IsPedOnFoot(closestPed) then
                                            TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_standard', Rperso.ItemSelected.name, tonumber(quantity))
                                        else
                                            ESX.ShowNotification("Nombres d'items invalid !")
                                        end
                                else
                                    ESX.ShowNotification("Aucun joueur ~r~Proche~n~ !")
                                end
                            end
                        end
                            })
                            
                        end)  
                    

                RageUI.IsVisible(F5WalletMenu, function()
                    RageUI.Separator("~r~↓ ~g~Portefeuille ~r~↓")
                        for i = 1, #ESX.PlayerData.accounts, 1 do
						
						if ESX.PlayerData.accounts[i].name == 'money' then
                            RageUI.Button('Argent : ', nil, {RightLabel = "~b~$"..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money).."~s~ →"}, true, {},F5WalletDrop)  
                        end
                        if ESX.PlayerData.accounts[i].name == 'bank' then
                            RageUI.Button('Banque : ', nil, {RightLabel = "~b~$"..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money).."~s~ →"}, true, {})  
                        end
                        if ESX.PlayerData.accounts[i].name == 'black_money' then
                            RageUI.Button('Argent Sale : ', nil, {RightLabel = "~r~$"..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money).."~s~ →"}, true, {}, F5WalletDropSaleMenu)  
                        end
                    end
                    RageUI.Button("~b~→→ ~s~Facture", nil, {RighLabel = "→→"}, true, {}, Billing)
                    RageUI.Button("~b~→→ ~s~Regarder sa ~g~carte d\'identité", nil, {RighLabel = "→"}, true, {
                        onSelected = function()
                            TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
                        end
                    })
                    RageUI.Button("~b~→→ ~s~Montrer sa ~g~Carte d\'identité", nil, {RighLabel = "→"}, true, {
                        onSelected = function()
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                            if closestDistance ~= -1 and closestDistance <= 3.0 then
                                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer))
                            else
                                ESX.ShowNotification('Aucun joueur ~r~proche !')
                            end
                        end
                    })
                    RageUI.Button("~b~>> ~s~Regarder son  ~o~Permis de conduire", nil, {RighLabel = "→"}, true, {
                        onSelected = function()
                            TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
                        end
                    })

                    RageUI.Button("~b~>> ~s~Montrer son  ~o~Permis de conduire", nil, {RighLabel = "→"}, true, {
                        onSelected = function()
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                            if closestDistance ~= -1 and closestDistance <= 3.0 then
                                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'driver')
                            else
                                ESX.ShowNotification('Aucun joueur ~r~proche !')
                            end
                        
                        end
                    })
                    RageUI.Button("~b~>> ~s~Regarder son  ~r~Permis de port d\'armes", nil, {RighLabel = "→"}, true, {
                        onSelected = function()
                            TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
                        end
                    }) 

                    RageUI.Button("~b~>> ~s~Montrer son  ~r~Permis de port d\'armes", nil, {RighLabel = "→"}, true, {
                        onSelected = function()
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                            if closestDistance ~= -1 and closestDistance <= 3.0 then
                                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'weapon')
                            else
                                ESX.ShowNotification('Aucun joueur ~r~proche !')
                            end
                        end
                    }) 
                end)

                RageUI.IsVisible(Billing, function()

                    if #Billing == 0 then
                        RageUI.Button("Aucune facture", nil, { RightLabel = "" }, true,{} )
                    end
                        
                    for i = 1, #Billing, 1 do
                        RageUI.Button(billing[i].label, nil, {RightLabel = '[~b~$' .. ESX.Math.GroupDigits(billing[i].amount.."~s~] →")}, true, {
                            onSelected = function()
                                ESX.TriggerServerCallback('esx_billing:payBill', function()
                                    ESX.TriggerServerCallback('kF5:Bill_getBills', function(bills) billing = bills end)
                                end, billing[i].id)
                            end
                        })
                    end
                    RageUI.Separator("~g~Facture")
                end)
                    
              

                

                RageUI.IsVisible(Vetements, function()
                    RageUI.Button("Haut", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                            TriggerEvent('kPersonalmenu:actionhaut')  
                        end
                    })

                    RageUI.Button("Pantalon", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                            TriggerEvent('kPersonalmenu:actionpantalon')  
                        end
                    })

                    RageUI.Button("Chaussure", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                            TriggerEvent('kPersonalmenu:actionchaussure')  
                        end
                    })

                    RageUI.Button("Sac", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                            TriggerEvent('kPersonalmenu:actionsac')  
                        end
                    })

                    RageUI.Button("Gilet par balle", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                            TriggerEvent('kPersonalmenu:actiongiletparballe')  
                        end
                    })
                    
                    RageUI.Separator('~y~ ↓ Accessoires ↓')

                    RageUI.Button("Masque", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                            TriggerEvent('kPersonalmenu:masque')  
                        end
                    })
                    
                end)    
               
   

                RageUI.IsVisible(Vehicules, function()
                    RageUI.Checkbox("Éteindre le moteur", nil, moteur, {}, {
                        onChecked = function()
                            moteur = true 
                            SetVehicleEngineOn(GetVehiclePedIsIn(PlayerPedId()), false, false, true)
                            SetVehicleUndriveable(GetVehiclePedIsIn(PlayerPedId()), false)
                        end,
                        onUnChecked = function()
                            moteur = false
                            SetVehicleEngineOn(GetVehiclePedIsIn(PlayerPedId()), true, false, true)
                            SetVehicleUndriveable(GetVehiclePedIsIn(PlayerPedId()), true)
                        end
                    })
                    RageUI.Checkbox("Ouvrir/Fermer Capot", nil, capot, {}, {
                        onChecked = function()
                            capot = true
                            SetVehicleDoorOpen(GetVehiclePedIsIn(PlayerPedId()), 4, false, false)
                        end,
                        onUnChecked = function()
                            capot = false
                            SetVehicleDoorShut(GetVehiclePedIsIn(PlayerPedId()), 4, false, false)
                        end
                    })
                    RageUI.Checkbox("Ouvrir/Fermer Coffre", nil, coffre, {}, {
                        onChecked = function()
                            coffre = true
                            SetVehicleDoorOpen(GetVehiclePedIsIn(PlayerPedId()), 5, false, false)
                        end,
                        onUnChecked = function()
                            coffre = false
                            SetVehicleDoorShut(GetVehiclePedIsIn(PlayerPedId()), 5, false, false)
                        end
                    })
                    RageUI.List("Ouvrir/Fermer Porte", {"Avant Gauche", "Avant Droite","Arrière Gauche","Arrière Droite"}, porte, nil, {}, true, {
                        onListChange = function(list) porte = list end,
                        onSelected = function(list)
                            if list == 1 then
                                if not one then
                                    one = true
                                    SetVehicleDoorOpen(GetVehiclePedIsIn(PlayerPedId()), 0, false, false)
                                elseif one then
                                    one = false
                                    SetVehicleDoorShut(GetVehiclePedIsIn(PlayerPedId()), 0, false, false)
                                end
                            elseif list == 2 then
                                if not two then
                                    two = true
                                    SetVehicleDoorOpen(GetVehiclePedIsIn(PlayerPedId()), 1, false, false)
                                elseif two then
                                    two = false
                                    SetVehicleDoorShut(GetVehiclePedIsIn(PlayerPedId()), 1, false, false)
                                end
                            elseif list == 3 then
                                if not three then
                                    three = true
                                    SetVehicleDoorOpen(GetVehiclePedIsIn(PlayerPedId()), 2, false, false)
                                elseif three then
                                    three = false
                                    SetVehicleDoorShut(GetVehiclePedIsIn(PlayerPedId()), 2, false, false)
                                end
                            elseif list == 4 then
                                if not four then
                                    four = true
                                    SetVehicleDoorOpen(GetVehiclePedIsIn(PlayerPedId()), 3, false, false)
                                elseif four then
                                    four = false
                                    SetVehicleDoorShut(GetVehiclePedIsIn(PlayerPedId()), 3, false, false)
                                end
                            end
                        end
                    })
                    RageUI.List("Ouvrir/Fermer Fenêtre", {"Avant Gauche", "Avant Droite","Arrière Gauche","Arrière Droite"}, window, nil, {}, true, {
                        onListChange = function(list) window = list end,
                        onSelected = function(list)
                            if list == 1 then
                                if not ag then
                                    ag = true
                                    RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 0) 
                                elseif ag then
                                    ag = false
                                    RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 0) 
                                end
                            elseif list == 2 then
                                if not ad then
                                    ad = true
                                    RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 1) 
                                elseif ad then
                                    ad = false
                                    RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 1) 
                                end
                            elseif list == 3 then
                                if not arg then
                                    arg = true
                                    RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 2) 
                                elseif arg then
                                    arg = false
                                    RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 2) 
                                end
                            elseif list == 4 then
                                if not ard then
                                    ard = true
                                    RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 3) 
                                elseif ard then
                                    ard = false
                                    RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 3) 
                                end
                            end
                        end
                    })
                    RageUI.List("Limitateur", {"Personnaliser", "30","50","80","120","Désactiver"}, limiteur, nil, {}, true, {
                        onListChange = function(list) limiteur = list end,
                        onSelected = function(list)
                            if list == 1 then
                                local perso = KeyboardInput("Choisissez votre vitesse :", "", 3)
                                if perso == nil then
                                    ESX.ShowNotification("Vitesse Invalide")
                                else
                                    SetVehicleMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), perso / 3.701)
                                end
                            elseif list == 2 then
                                SetVehicleMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 8.1)
                            elseif list == 3 then
                                SetVehicleMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 13.7)
                            elseif list == 4 then
                                SetVehicleMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 22.0)
                            elseif list == 5 then
                                SetVehicleMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 33.2)
                            elseif list == 6 then
                                SetVehicleMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 0.0)
                            end
                        end
                    })
                    
                end)


                            
                RageUI.IsVisible(Divers, function()

                    RageUI.Separator("~g~Actions Diverses")
                    RageUI.Checkbox("~b~→→  ~s~Afficher / Désactiver la map", nil, menumap, {RighLabel = ""}, { 
                        onChecked = function()
                            menumap = true
                            DisplayRadar(true)
                        end,
                        onUnChecked = function()
                            menumap = false
                            DisplayRadar(false)
                        end
                    })

                    RageUI.Button("~b~→→ ~s~Tomber", "Ragdoll", {RightLabel = "→→"}, true, {
                        onSelected = function()
                            ragdolling = not ragdolling
                            RageUI.CloseAll()
                            isMenuOpen = false
                            while ragdolling do
                                Wait(0)
                                local myPed = GetPlayerPed(-1)
                                SetPedToRagdoll(myPed, 1000, 1000, 0, 0, 0, 0)
                                ResetPedRagdollTimer(myPed)
                                AddTextEntry(GetCurrentResourceName(), ('Appuyez sur ~INPUT_JUMP~ pour vous ~b~Réveillé'))
                                DisplayHelpTextThisFrame(GetCurrentResourceName(), false)
                                ResetPedRagdollTimer(myPed)
                                if IsControlJustPressed(0, 22) then 
                                    ragdolling = false
                                end
                            end
                        end
                    }) 

                    RageUI.Button("~b~→→  ~s~Faire un Tweet", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                            tweetraison = kPersonalmenuKeyboardInput("Ecrire votre message dans twitter", "", 200)
                            TriggerServerEvent("twt:send", tweetraison, GetPlayerName(PlayerId()))
						 
                        end
                    })


                    RageUI.Button("~b~→→  ~s~Voir ton ID", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                            ESX.ShowAdvancedNotification('~g~NYG', '~r~ID', 'Ton ID : '.. GetPlayerServerId(PlayerId()), 'CHAR_TREVOR', 3)
                        end
                    })

                

                RageUI.Button("~b~→→  ~s~Notre Discord", nil, {RightLabel = "→→"}, true, {
                    onSelected = function()
                        ESX.ShowAdvancedNotification('~g~NYG', '~p~Discord', 'dsc.gg/qzm7ryd9Yk : ', 'CHAR_TREVOR', 3)
                    end
                })

            end)

                RageUI.IsVisible(F5WalletDrop, function()
    RageUI.Separator("~r~------------------------------------")
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestDistance ~= -1 and closestDistance <= 3 then
        RageUI.Button("Donner", nil, {RightLabel = "→→"}, true, {
            onSelected = function() 
                local quantity = Keyboardput("Somme d'argent que vous voulez donner", '', 25)
                if tonumber(quantity) then
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                    if closestDistance ~= -1 and closestDistance <= 3 then
                        local closestPed = GetPlayerPed(closestPlayer)
                        if not IsPedSittingInAnyVehicle(closestPed) then
                            TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_money', 'rien', tonumber(quantity))
                        else
                            ESX.ShowNotification('Vous ne pouvez pas donner de l\'argent dans un véhicles')
                        end
                    else
                        ESX.ShowNotification('Aucun joueur proche !')
                    end
                else
                    ESX.ShowNotification('Somme invalid')
                end
            end
        })
    else
        RageUI.Button("Donner", nil, {RightBadge = RageUI.BadgeStyle.Lock}, false, {})
    end
end)

RageUI.IsVisible(F5WalletDropSaleMenu, function()
    RageUI.Separator("~r~------------------------------------")
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestDistance ~= -1 and closestDistance <= 3 then
    RageUI.Button("Donner", nil, {RightLabel = "→→"}, true, {
        onSelected = function() 
            local quantity = Keyboardput("Somme d'argent que vous voulez donner", '', 25)
            if tonumber(quantity) then
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                if closestDistance ~= -1 and closestDistance <= 3 then
                    local closestPed = GetPlayerPed(closestPlayer)
                    if not IsPedSittingInAnyVehicle(closestPed) then
                        TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_account', 'black_money', tonumber(quantity))
                    else
                        ESX.ShowNotification('Vous ne pouvez pas donner de l\'argent dans un véhicles')
                    end
                else
                    ESX.ShowNotification('Aucun joueur proche !')
                end
            else
                ESX.ShowNotification('Somme invalid')
            end
        end
    })
    else
        RageUI.Button("Donner", nil, {RightBadge = RageUI.BadgeStyle.Lock}, false, {})
    end
end)

                        
                  Wait(0)
                end
            end)
    end
end




-- pour les Vétements Mettre/Enlever

RegisterNetEvent('kPersonalmenu:actionhaut')
AddEventHandler('kPersonalmenu:actionhaut', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())

            if skina.torso_1 ~= skinb.torso_1 then
                vethaut = true
                TriggerEvent('skinchanger:loadClothes', skinb, {['torso_1'] = skina.torso_1, ['torso_2'] = skina.torso_2, ['tshirt_1'] = skina.tshirt_1, ['tshirt_2'] = skina.tshirt_2, ['arms'] = skina.arms})
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['torso_1'] = 15, ['torso_2'] = 0, ['tshirt_1'] = 15, ['tshirt_2'] = 0, ['arms'] = 15})
                vethaut = false
            end
        end)
    end)
end)

RegisterNetEvent('kPersonalmenu:actionpantalon')
AddEventHandler('kPersonalmenu:actionpantalon', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtrousers', 'try_trousers_neutral_c'

            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())

            if skina.pants_1 ~= skinb.pants_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = skina.pants_1, ['pants_2'] = skina.pants_2})
                vetbas = true
            else
                vetbas = false
                if skina.sex == 1 then
                    TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = 15, ['pants_2'] = 0})
                else
                    TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = 61, ['pants_2'] = 1})
                end
            end
        end)
    end)
end)


RegisterNetEvent('kPersonalmenu:actionchaussure')
AddEventHandler('kPersonalmenu:actionchaussure', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingshoes', 'try_shoes_positive_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.shoes_1 ~= skinb.shoes_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = skina.shoes_1, ['shoes_2'] = skina.shoes_2})
                vetch = true
            else
                vetch = false
                if skina.sex == 1 then
                    TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = 35, ['shoes_2'] = 0})
                else
                    TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = 34, ['shoes_2'] = 0})
                end
            end
        end)
    end)
end)

RegisterNetEvent('kPersonalmenu:actionsac')
AddEventHandler('kPersonalmenu:actionsac', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.bags_1 ~= skinb.bags_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['bags_1'] = skina.bags_1, ['bags_2'] = skina.bags_2})
                vetsac = true
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['bags_1'] = 0, ['bags_2'] = 0})
                vetsac = false
            end
        end)
    end)
end)


RegisterNetEvent('kPersonalmenu:actiongiletparballe')
AddEventHandler('kPersonalmenu:actiongiletparballe', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.bproof_1 ~= skinb.bproof_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['bproof_1'] = skina.bproof_1, ['bproof_2'] = skina.bproof_2})
                vetgilet = true
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['bproof_1'] = 0, ['bproof_2'] = 0})
                vetgilet = false
            end
        end)
    end)
end)

RegisterNetEvent('kPersonalmenu:masque')
AddEventHandler('kPersonalmenu:masque', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.mask_1 ~= skinb.mask_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['mask_1'] = skina.mask_1, ['mask_2'] = skina.mask_2})
                vetmask = true
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['mask_1'] = 0, ['mask_2'] = 0})
                vetmask = false
            end
        end)
    end)
end)


--doigt 

local mp_pointing = false
local keyPressed = false

local function startPointing()
    local ped = GetPlayerPed(-1)
    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Wait(0)
    end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")
end

local function stopPointing()
    local ped = GetPlayerPed(-1)
    Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
    ClearPedSecondaryTask(PlayerPedId())
end

local once = true
local oldval = false
local oldvalped = false

Citizen.CreateThread(function()
    while true do
        Wait(0)

        if once then
            once = false
        end

        if not keyPressed then
            if IsControlPressed(0, 29) and not mp_pointing and IsPedOnFoot(PlayerPedId()) then
                Wait(200)
                if not IsControlPressed(0, 29) then
                    keyPressed = true
                    startPointing()
                    mp_pointing = true
                else
                    keyPressed = true
                    while IsControlPressed(0, 29) do
                        Wait(50)
                    end
                end
            elseif (IsControlPressed(0, 29) and mp_pointing) or (not IsPedOnFoot(PlayerPedId()) and mp_pointing) then
                keyPressed = true
                mp_pointing = false
                stopPointing()
            end
        end

        if keyPressed then
            if not IsControlPressed(0, 29) then
                keyPressed = false
            end
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) and not mp_pointing then
            stopPointing()
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) then
            if not IsPedOnFoot(PlayerPedId()) then
                stopPointing()
            else
                local ped = GetPlayerPed(-1)
                local camPitch = GetGameplayCamRelativePitch()
                if camPitch < -70.0 then
                    camPitch = -70.0
                elseif camPitch > 42.0 then
                    camPitch = 42.0
                end
                camPitch = (camPitch + 70.0) / 112.0

                local camHeading = GetGameplayCamRelativeHeading()
                local cosCamHeading = Cos(camHeading)
                local sinCamHeading = Sin(camHeading)
                if camHeading < -180.0 then
                    camHeading = -180.0
                elseif camHeading > 180.0 then
                    camHeading = 180.0
                end
                camHeading = (camHeading + 180.0) / 360.0

                local blocked = 0
                local nn = 0

                local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
                local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7);
                nn,blocked,coords,coords = GetRaycastResult(ray)

                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)

            end
        end
    end
end)
-- doigt fin

--levermain
Citizen.CreateThread(function()
    local dict = "missminuteman_1ig_2"
    
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(100)
	end
    local handsup = false
	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(1, 243) then --Start holding X
            if not handsup then
                TaskPlayAnim(GetPlayerPed(-1), dict, "handsup_enter", 8.0, 8.0, -1, 50, 0, false, false, false)
                handsup = true
            else
                handsup = false
                ClearPedTasks(GetPlayerPed(-1))
            end
        end
    end
end)

--levermain fin 




Citizen.CreateThread(function()
    while true do
        if IsControlJustPressed(1,166) then

            ESX.TriggerServerCallback('kirito:getWeight', function(playerWeight)
                print(playerWeight)
                weight = playerWeight
            end)

            Kirito_F5()
        end

        Citizen.Wait(0)
    end
end)


