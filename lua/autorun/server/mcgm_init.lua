if SERVER then
    MC_GM = MC_GM or {}

    include("mcgm/config.lua")
    include("mcgm/protocol.lua")
    include("mcgm/bridge.lua")

    hook.Add("Initialize", "MCGM_Start", function()
        timer.Simple(1, function()
            if MC_GM and MC_GM.Start then
                MC_GM.Start()
            end
        end)
    end)

    hook.Add("ShutDown", "MCGM_Stop", function()
        if MC_GM and MC_GM.Stop then
            MC_GM.Stop()
        end
    end)
end
