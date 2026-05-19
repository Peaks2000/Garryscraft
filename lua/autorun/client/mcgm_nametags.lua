hook.Add("PostDrawTranslucentRenderables", "MCGM_MinecraftProxyNametags", function()
    local eyeAngles = EyeAngles()
    local angle = Angle(0, eyeAngles.y - 90, 90)

    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent:GetNWBool("MCGM_MinecraftProxy", false) then
            local name = ent:GetNWString("MCGM_Name", "Minecraft")
            local pos = ent:LocalToWorld(ent:OBBCenter()) + Vector(0, 0, ent:OBBMaxs().z + 14)

            cam.Start3D2D(pos, angle, 0.14)
                draw.SimpleTextOutlined(name, "DermaLarge", 0, 0, Color(120, 210, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 220))
            cam.End3D2D()
        end
    end
end)
