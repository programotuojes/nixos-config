{
    home.file.".config/wireplumber/main.lua.d/51-device-rename.lua".text = ''
        local rule = {
            matches = {
                {
                    { "device.name", "equals", "alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic" },
                },
            },
            apply_properties = {
                ["device.description"] = "Laptop",
            },
        }

        table.insert(alsa_monitor.rules, rule)
    '';
}
